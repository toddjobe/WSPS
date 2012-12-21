#!/bin/sh
# Simple bash client for recording sermons
# Author: Todd Jobe
# Todo: It's better to simply encode the mp4 locally, then let the
# server encode the mp3 server-side
videoStream=udp://localhost:1234
audioDevice=default
localFolderBase="/AudioFiles"
itoffset=0
user=terry
host=

dt=`date +%Y-%m-%d`

# Parse the file suffix
case `date +%u` in
7)
  case `date +%H` in
  09) suffix=acs ;;
  10) suffix=ser ;;
  *) suffix=oth ;;
  esac
;;
3) suffix=wed ;;
*) suffix=oth ;;
esac

fileName=$dt$suffix

# The commands
soxCmd="sox -t coreaudio ${audioDevice} remix - highpass 100 compand 0.05,0.2 6:-54,-90,-36,-36,-24,-24,0,-12 0 -90 0.1"

ffmpegAudioCmd="ffmpeg -i - channel 1 -acodec mp3 -b:a 64k -f mp3 -"

ffmpegVideoCmd="ffmpeg -i ${videoStream} -itoffset ${itoffset} -i -i -acodec libvo_aacenc -b:a 64k -f mp4 -"

sshCmd="ssh ${user}:${host} \"bash -c 'cat >${remoteFolder}/${fileName}"

sshAudioCmd="${sshCmd}.mp3'\""

sshVideoCmd="${sshCmd}.mp4'\""

# The plumbing
soxCmd | tee >(${ffmpegAudioCmd} | tee ${localFolder}/${fileName}.mp3 | ${sshAudioCmd}) | 
>(ffmpeg -i - -channel 1 -acodec mp3 -b:a 64k -f mp3 - \
${localFolder}/$fileName}) \
ffmpeg -i $videoStream -itoffset $itoffset -i - -acodec libvo_aacenc -b:a 64k -f mp4 - \
| \
tee "$localFolder/$fileName" \
| \
ssh $user@$hostname "bash -c 'cat | tee $remoteFolder/$file_name'"
