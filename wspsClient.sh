#!/bin/sh
# Simple bash client for recording sermons
# Author: Todd Jobe
# Todo: It's better to simply encode the mp4 locally, then let the
# server encode the mp3 server-side

videoStream=udp://localhost:1234
audioDevice=default
#localFolderBase="/AudioFiles"
localFolderBase="/Users/toddjobe/Documents/AudioFiles"
remoteFolder="/home/toddjobe/Documents/AudioFiles/remote"
itoffset=0
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
if [ -e $localVideoFile ] || [ -e ${localAudioFile} ] || [ -z `ssh ${user}@${host} 'ls ${removeVideoFile} ${remoteAudioFile} 2>/dev/null'` ]; then
  read -p 'One or more of the files already exist, do you want to overwrite?(y/N):' a
  if [[ $a == [Nn] || $a == "" ]]; then
    echo Exiting.
    exit
  fi
fi

# The commands
soxCmd="sox -t coreaudio ${audioDevice} -p remix - highpass 100 compand 0.05,0.2 6:-54,-90,-36,-36,-24,-24,0,-12 0 -90 0.1"

ffmpegAudioCmd="ffmpeg -i - channels 1 -acodec mp3 -b:a 64k -f mp3 -"

ffmpegVideoCmd="ffmpeg -i ${videoStream} -itoffset ${itoffset} -i -i -acodec libvo_aacenc -b:a 64k -f mp4 -"

sshCmd="ssh ${user}@${host} \"bash -c 'cat >"

sshAudioCmd="${sshCmd}\\\"${remoteAudioFile}\\\"'"

sshVideoCmd="${sshCmd}\\\"${remoteVideoFile}\\\"'"

# The plumbing
eval ${soxCmd} | tee >(${ffmpegAudioCmd} | tee ${localAudioFile} | ${sshAudioCmd}) | ${ffmpegVideoCmd} | tee ${localVideoFile} | ${sshVideoCmd} &

# now wait for user input to exit
finished=0 
while [ "$finished" -ne "1" ]; do
  read -p "(Q)uit:" q
  if [[ $q == [Qq] ]]; then
    finished=1
  fi
done

# Send SIGINT to all necessary processes
killall -INT sox
killall -INT ffmpeg
killall -INT tee

exit
