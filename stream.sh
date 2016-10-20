#!/bin/sh

ffmpeg \
  -i videos/1.m4v  \
  -c:a aac -ar 44100 -ab 128k -ac 2 -strict -2 -c:v libx264 -vb 500k -r 30 \
  -s 640x480 -ss 00.000 -f flv \
  rtmp://localhost:3001/live/1
