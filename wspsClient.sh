#!/bin/sh
# Simple bash client for recording sermons
# Author: Todd Jobe
# Todo: It's better to simply encode the mp4 locally, then let the
# server encode the mp3 server-side
# Todo: Use ducksboard.com to develop a near realtime dashboard for monitoring
# Note: There doesn't seem to be a way to cause video recording to start
# if the stream is not present.  So, if there's no video stream
# it just won't create a video file

streamPort=1234
streamHost=192.168.56.1
streamUser=toddjobe
audioDevice=default
#localFolderBase="/AudioFiles"
localFolderBase="${HOME}/Documents/AudioFiles"
remoteFolder="${HOME}/Documents/AudioFiles/remote"
itsoffset=0
#webUser=terry
webUser=tjobe
#webHost=peopleforjesus.org
webHost=localhost
ffmpegExe = ""

# Parse command line options
while getopts "y" opt; do
  case $opt in
  y)
    forceOverwrite=1
  ;;
  \?)
    Usage: $0 [-y]
  ;;
  esac 
done

dt=`date +%Y-%m-%d`

# Get the local ip address
os=`uname`
localIP=""
case $os in
  Linux) localIP=`ifconfig | grep 'inet addr:' | grep -v '127.0.0.1' | grep '192' | cut -d: -f2 | awk '{print $1}'`;;
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
if [[ ( ! ${forceOverwrite} ) && ( -e ${localVideoFile} || -e ${localAudioFile} || -z `ssh ${webUser}@${webHost} "ls ${remoteVideoFile} ${remoteAudioFile} 2>/dev/null"` ) ]]; then
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
  [[ ! -z "$ffmpeg_video_pid" ]] && kill -9 "${ffmpeg_video_pid}"
  [[ ! -z "$lame_audio_pid" ]] && kill -9 "${lame_audio_pid}"
  [[ ! -z "$sox_pid" ]] && kill -9 "${sox_pid}"
  ssh ${streamUser}@${streamHost} "cmd /c taskkill /im \"ffmpeg.exe\" /f" 2>&1 >>${streamLog}
  [[ ! -z "$stream_pid" ]] && kill -9 "${stream_pid}"
}

trap "cleanup" EXIT INT

# plumbing though named pipes 
soxFifo=/tmp/sox.wav
lameFifo=/tmp/ffmpeg.mp3
ffmpegVideoFifo=/tmp/ffmpeg.mp4
audioLocalFifo=/tmp/local.mp3
videoLocalFifo=/tmp/local.mp4
audioRemoteFifo=/tmp/remote.mp3
videoRemoteFifo=/tmp/remote.mp4

for fifo in "${soxFifo}" "${lameFifo}" "${ffmpegVideoFifo}" "${audioLocalFifo}" "${videoLocalFifo}" "${audioRemoteFifo}" "${videoRemoteFifo}" ; do
  rm -f "$fifo"
  mkfifo "$fifo"
done

# log errors to separate places
streamLog=/tmp/stream.log
soxLog=/tmp/sox.log
lameLog=/tmp/lame.log
ffmpegVideoLog=/tmp/ffmpegVideo.log
audioLocalLog=/tmp/audioLocal.log
videoLocalLog=/tmp/videoLocal.log
audioRemoteLog=/tmp/audioRemote.log
videoRemoteLog=/tmp/videoRemote.log

# video streaming command
ssh ${streamUser}@${streamHost} "cmd /c \"C:\\Program Files\\ffmpeg\\bin\\ffmpeg.exe\" -y -f dshow -t 3600 -i video=UScreenCapture -vcodec libx264 -vprofile high -preset slow -b:v 50k -maxrate 500k -bufsize 0k -vf scale=426:320 -pix_fmt yuv420p -metadata comment=trial -f mpegts udp://${localIP}:${streamPort}" 2>&1 >${streamLog} &
stream_pid=$!

# audio recording command
#sox -q -c 1 -t "${audioDriver}" "${audioDevice}" -t wav "${soxFifo}" remix - highpass 100 compand 0.05,0.2 6:-54,-90,-36,-36,-24,-24,0,-12 0 -90 0.1 &
sox -t "${audioDriver}" "${audioDevice}" -t wav "${soxFifo}" compand 0.2,0.20 5:-60,-40,-10 -5 -90 0.1 2>${soxLog} &
sox_pid=$!

# audio conversion command 
#ffmpeg -threads 0 -i "${soxFifo}" -acodec mp3 -b:a 64k -y "${lameFifo}" & 
#ffmpeg -i "${soxFifo}" -acodec mp3 -b:a 64k -y "${lameFifo}" 2>${ffmpegAudioLog} & 
lame -m s -a -q 7 -V 6 "${soxFifo}" "${lameFifo}" 2>${lameLog} & 

lame_audio_pid=$!

# video recording command
ffmpeg -f mpegts -i "udp://localhost:${streamPort}" -itsoffset ${itsoffset} -f mp3 -i "${lameFifo}" -y -f mp4 -frag_duration 3600 "${ffmpegVideoFifo}" 2>${ffmpegVideoLog} &
ffmpeg_video_pid=$!

# audio piping command
tee ${audioLocalFifo} >${audioRemoteFifo} <${lameFifo} &
audio_tee_pid=$!

# video piping command 
tee ${videoLocalFifo} >${videoRemoteFifo} <${ffmpegVideoFifo} &
video_tee_pid=$!

# audio ssh command
ssh ${webUser}@${webHost} "bash -c 'cat > \"${remoteAudioFile}\"'" <${audioRemoteFifo} &
audio_ssh_pid=$!

# video ssh command
ssh ${webUser}@${webHost} "bash -c 'cat > \"${remoteVideoFile}\"'" <${videoRemoteFifo} &
video_ssh_pid=$!

# audio local command
cat <${audioLocalFifo} >${localAudioFile} &
audio_local_pid=$!

# video local command
cat <${videoLocalFifo} >${localVideoFile} &
video_local_pid=$!

# wait for kill signal to stop recording
wait ${stream_pid} ${sox_pid} ${lame_audio_pid} ${ffmpeg_video_pid} ${audio_tee_pid} ${video_tee_pid}\
${audio_ssh_pid} ${video_ssh_pid} ${audio_local_pid} ${video_local_pid}

# remove the named pipes
for fifo in "${soxFifo}" "${lameFifo}" "${ffmpegVideoFifo}" "${audioLocalFifo}" "${videoLocalFifo}" "${audioRemoteFifo}" "${videoRemoteFifo}" ; do
  rm -f "$fifo"
done

exit
