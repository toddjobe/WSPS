#!/bin/sh
# Simple bash client for recording sermons
# Author: Todd Jobe
# Todo: It's better to simply encode the mp4 locally, then let the
# server encode the mp3 server-side
# Note: There doesn't seem to be a way to cause video recording to start
# if the stream is not present.  So, if there's no video stream
# it just won't create a video file

videoStream=udp://localhost:1234
audioDevice=default
#localFolderBase="/AudioFiles"
localFolderBase="/Users/toddjobe/Documents/AudioFiles"
remoteFolder="/Users/toddjobe/Documents/AudioFiles/remote"
itsoffset=0
#user=terry
user=toddjobe
#host=peopleforjesus.org
host=localhost

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
if [ -e ${localVideoFile} ] || [ -e ${localAudioFile} ] || [ -z `ssh ${user}@${host} "ls ${remoteVideoFile} ${remoteAudioFile} 2>/dev/null"` ]; then
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
  [[ ! -z "$ffmpeg_audio_pid" ]] && kill -9 "${ffmpeg_audio_pid}"
  [[ ! -z "$sox_pid" ]] && kill -9 "${sox_pid}"
}

trap "cleanup" EXIT INT

# plumbing though named pipes 
audioFifo=/tmp/sox.wav
ffmpegAudioFifo=/tmp/ffmpeg.mp3
ffmpegVideoFifo=/tmp/ffmpeg.mp4
audioLocalFifo=/tmp/local.mp3
videoLocalFifo=/tmp/local.mp4
audioRemoteFifo=/tmp/remote.mp3
videoRemoteFifo=/tmp/remote.mp4

for fifo in "${audioFifo}" "${ffmpegAudioFifo}" "${ffmpegVideoFifo}" "${audioLocalFifo}" "${videoLocalFifo}" "${audioRemoteFifo}" "${videoRemoteFifo}" ; do
  rm -f "$fifo"
  mkfifo "$fifo"
done

# log errors to separate places
audioLog=/tmp/audio.log
ffmpegAudioLog=/tmp/ffmpegAudio.log
ffmpegVideoLog=/tmp/ffmpegVideo.log
audioLocalLog=/tmp/audioLocal.log
videoLocalLog=/tmp/videoLocal.log
audioRemoteLog=/tmp/audioRemote.log
videoRemoteLog=/tmp/videoRemote.log

# audio recording command
#sox -q -c 1 -t coreaudio "${audioDevice}" -t wav "${audioFifo}" remix - highpass 100 compand 0.05,0.2 6:-54,-90,-36,-36,-24,-24,0,-12 0 -90 0.1 &
sox -q -t coreaudio "${audioDevice}" -t wav "${audioFifo}" channels 1 remix - highpass 100 compand 0.05,0.2 6:-54,-90,-36,-36,-24,-24,0,-12 0 -90 0.1 2>${audioLog} &
sox_pid=$!

# audio conversion command 
#ffmpeg -threads 0 -i "${audioFifo}" -acodec mp3 -b:a 64k -y "${ffmpegAudioFifo}" & 
ffmpeg -i "${audioFifo}" -acodec mp3 -b:a 64k -y "${ffmpegAudioFifo}" & 
ffmpeg_audio_pid=$!

# video recording command
ffmpeg -f mpegts -i "${videoStream}" -itsoffset ${itsoffset} -f mp3 -i "${ffmpegAudioFifo}" -y -f mp4 -frag_duration 3600 "${ffmpegVideoFifo}" &
ffmpeg_video_pid=$!

# audio piping command
tee ${audioLocalFifo} ${audioRemoteFifo} <${ffmpegAudioFifo} &
audio_tee_pid=$!

# video piping command 
tee ${videoLocalFifo} ${videoRemoteFifo} <${ffmpegVideoFifo} &
video_tee_pid=$!

# audio ssh command
ssh ${user}@${host} bash -c 'cat > "${remoteAudioFile}"' <${audioRemoteFifo} &
audio_ssh_pid=$!

# video ssh command
ssh ${user}@${host} bash -c 'cat > "${remoteVideoFile}"' <${videoRemoteFifo} &
video_ssh_pid=$!

# audio local command
cat <${audioLocalFifo} >${localAudioFile} &
audio_local_pid=$!

# video local command
cat <${videoLocalFifo} >${localVideoFile} &
video_local_pid=$!

# wait for kill signal to stop recording
wait ${sox_pid} ${ffmpeg_audio_pid} ${ffmpeg_video_pid} ${audio_tee_pid} ${video_tee_pid}\
${audio_ssh_pid} ${video_ssh_pid} ${audio_local_pid} ${video_local_pid}

# remove the named pipes
for fifo in "${audioFifo}" "${ffmpegAudioFifo}" "${ffmpegVideoFifo}" "${audioLocalFifo}" "${videoLocalFifo}" "${audioRemoteFifo}" "${videoRemoteFifo}" ; do
  rm -f "$fifo"
done

exit
