#!/bin/bash
# Simple bash client for recording sermons
# Author: Todd Jobe
# Todo: It's better to simply encode the mp4 locally, then let the
# server encode the mp3 server-side
# Todo: Use ducksboard.com to develop a near realtime dashboard for monitoring
# Note: There doesn't seem to be a way to cause video recording to start
# if the stream is not present.  So, if there's no video stream
# it just won't create a video file

# Parse command line options
while getopts "yvarl" opt; do
  case $opt in
  y)
    y=1
  ;;
  v)
    v=1
  ;;
  a)
    v=0
  ;;
  r)
    r=1
  ;;
  l)
    r=0
  ;;
  \?)
    Usage: $0 [-yva]
  ;;
  esac
done
# defaults for flags
forceOverwrite=${y-1}
videoAndAudio=${v-1}
remoteSync=${r-1}

# Shift all processed options away
shift $((OPTIND-1))
configFile=${1-wspsDefaults.cfg}
source "$configFile"

# name that ffmpeg process will have on the windows side so you can kill it.
basenameFfmpegExeRemote=`basename "${ffmpegExeRemote//\\\\//}"`

# formatted date for file names
dt=`date +%Y-%m-%d`

# Get the local ip address
# The Linux version assume that you're on the same subnet as the stream server
os=`uname`
localIP=""
case $os in
  Linux) localIP=`ifconfig | grep 'inet addr:' | grep ${streamHost:0:7}| cut -d: -f2 | awk '{print $1}'`;;
  Darwin|FreeBSD|OpenBSD) localIP=`ifconfig | grep -E 'inet.[0-9]' | grep -v '127.0.0.1' | awk '{ print $2}'` ;;
esac

# Choose the right audio driver
audioDriver=""
case $os in
  Linux|FreeBSD|OpenBSD) audioDriver=alsa ;;
  Darwin) audioDriver=coreaudio ;;
esac

# Parse the file suffix
case `date +%u` in
7)
  case `date +%H` in
  09)
    suffix=acs
    localFolder="${localFolderBase}/Adult Class Sunday"
    ;;
  10)
    suffix=ser
    localFolder="${localFoderBase}/Sunday Morning Sermon"
    ;;
  *)
    suffix=oth
    localFolder="${localFolderBase}"
    ;;
  esac
;;
3)
  suffix=wed
  localFolder="${localFolderBase}/Wednesday Night Class"
;;
*) 
  suffix=oth
  localFolder="${localFolderBase}"
;;
esac

fileName=$dt$suffix
videoFile="${fileName}.mp4"
audioFile="${fileName}.mp3"
localVideoFile="${localFolder}/${videoFile}"
localAudioFile="${localFolder}/${audioFile}"
remoteVideoFile="${remoteFolder}/${videoFile}"
remoteAudioFile="${remoteFolder}/${audioFile}"

# Check for existence of files and ask if you want to overwrite
if [[ ( ! ${forceOverwrite} -eq 0 ) && ( -e ${localVideoFile} || -e ${localAudioFile} || -z `ssh ${webUser}@${webHost} "ls ${remoteVideoFile} ${remoteAudioFile} 2>/dev/null"` ) ]]; then
  read -p 'One or more of the files already exist, do you want to overwrite?(y/N):' a
  if [[ $a == [Nn] || $a == "" ]]; then
    echo Exiting.
    exit
  fi
fi

# This is called when you ^C or an app quits. It kills all the processes and deletes the FIFOs.
function cleanup() {
  trap "" EXIT INT
  # back to front
  if (( $videoAndAudio )); then
    [[ ! -z "$ffmpeg_video_pid" ]] && kill -9 "${ffmpeg_video_pid}"
    ssh ${streamUser}@${streamHost} "cmd /c taskkill /im \"${basenameFfmpegExeRemote}\" /f" 2>&1 >>${streamLog}
    [[ ! -z "$stream_pid" ]] && kill -9 "${stream_pid}"
  fi
  [[ ! -z "$lame_audio_pid" ]] && kill -9 "${lame_audio_pid}"
  [[ ! -z "$sox_pid" ]] && kill -9 "${sox_pid}"
}

trap "cleanup" EXIT INT

# plumbing though named pipes
soxFifo=/tmp/sox.wav
lameFifo=/tmp/lame.mp3
ffmpegVideoFifo=/tmp/ffmpeg.mp4
audioToVideoFifo=/tmp/audioToVideo.mp3
audioToFileFifo=/tmp/audioToFile.mp3
audioRemoteFifo=/tmp/remote.mp3
videoRemoteFifo=/tmp/remote.mp4

for fifo in "${soxFifo}" "${lameFifo}" "${ffmpegVideoFifo}" "${audioToVideoFifo}" "${audioToFileFifo}" "${audioRemoteFifo}" "${videoRemoteFifo}" ; do
  rm -f "$fifo"
  mkfifo "$fifo"
done

# log errors to separate places
streamLog=/tmp/stream.log
soxLog=/tmp/sox.log
lameLog=/tmp/lame.log
ffmpegVideoLog=/tmp/ffmpegVideo.log
audioRemoteLog=/tmp/audioRemote.log
videoRemoteLog=/tmp/videoRemote.log

# video streaming command
# TODO: This path to ffmpeg is hard coded here, but set in a variable elsewhere
if (( $videoAndAudio)); then
  ssh ${streamUser}@${streamHost} "cmd /c \"C:\\Program Files\\ffmpeg\\bin\\ffmpeg.exe\" -y -f dshow -t 3600 -i video=UScreenCapture -vcodec libx264 -vprofile high -preset slow -b:v 50k -maxrate 500k -bufsize 0k -vf scale=426:320 -pix_fmt yuv420p -metadata comment=trial -f mpegts udp://${localIP}:${streamPort}" 2>&1 >${streamLog} &
  stream_pid=$!
fi

# audio recording command
sox -t "${audioDriver}" "${audioDevice}" -t wav "${soxFifo}" compand 0.2,0.20 5:-60,-40,-10 -5 -90 0.1 2>"${soxLog}" &
sox_pid=$!

# audio conversion command
lame -m s -a -q 7 -V 6 "${soxFifo}" "${lameFifo}" 2>"${lameLog}" &
lame_audio_pid=$!

if (( $videoAndAudio )); then
  # audio to video piping command
  tee "${audioToFileFifo}" >"${audioToVideoFifo}" <"${lameFifo}" &
  audioToVideo_tee_pid=$!

  # video recording command
  "${ffmpegExeLocal}" -loglevel verbose -f mpegts -i "udp://localhost:${streamPort}" -itsoffset ${itsoffset} -f mp3 -i "${audioToVideoFifo}" -y -c:v libx264 -f mp4 -movflags frag_keyframe+empty_moov "${ffmpegVideoFifo}" 2>${ffmpegVideoLog} &
  ffmpeg_video_pid=$!
else
  tee "${audioToFileFifo}" <"${lameFifo}"
fi

if (( $remoteSync )); then
  # audio piping command
  tee "${localAudioFile}" >"${audioRemoteFifo}" <"${audioToFileFifo}" &
  audio_tee_pid=$!

  # audio ssh command
  ssh ${webUser}@${webHost} "bash -c 'cat > \"${remoteAudioFile}\"'" <"${audioRemoteFifo}" &
  audio_ssh_pid=$!

  if (( $videoAndAudio )); then

    # video piping command
    tee "${localVideoFile}" >"${videoRemoteFifo}" <"${ffmpegVideoFifo}" &
    video_tee_pid=$!

    # video ssh command
    ssh ${webUser}@${webHost} "bash -c 'cat > \"${remoteVideoFile}\"'" <"${videoRemoteFifo}" &
    video_ssh_pid=$!

  fi

else

  # audio piping command
  cat "${localAudioFile}" <"${audioToFileFifo}" &
  audio_tee_pid=$!

  if (( $remoteSync )); then
    cat "${localVideoFile}" <"${ffmpegVideoFifo}" 
  fi

fi

# wait for kill signal to stop recording
wait ${stream_pid} ${sox_pid} ${lame_audio_pid} ${ffmpeg_video_pid} ${audioToVideo_tee_pid} ${audio_tee_pid} ${video_tee_pid}\
${audio_ssh_pid} ${video_ssh_pid}

# remove the named pipes
for ff in "${soxFifo}" "${lameFifo}" "${ffmpegVideoFifo}" "${audioToVideoFifo}" "${audioToFileFifo}" "${audioLocalFifo}" "${videoLocalFifo}" "${audioRemoteFifo}" "${videoRemoteFifo}" ; do
  rm -f "${ff}"
done

exit
