#!/bin/bash

ffmpeg -i $1 -f lavfi -i color=d=${3}:size=426x320 -i $2 \
-filter_complex '[0:0] [1:0] [2:0] concat=n=3:v=1:a=0 [v]' \
-map '[v]' new.mp4 
