#!/bin/bash
echo "Enter the filename (without extension)"
read id

mkdir ./src/"$id"

ffmpeg -y -i src/"$id".mp4 -c:a aac -ac 2 -ab 256k -ar 48000 \
  -c:v libx264 -x264opts 'keyint=24:min-keyint=24:no-scenecut' -b:v 1500k -bufsize 1000k -vf "scale=720:-1" \
  src/"$id"/720.mp4
ffmpeg -y -i src/"$id".mp4 -c:a aac -ac 2 -ab 128k -ar 44100 \
  -c:v libx264 -x264opts 'keyint=24:min-keyint=24:no-scenecut' -b:v 800k -bufsize 500k -vf "scale=540:-1" \
  src/"$id"/540.mp4
ffmpeg -y -i src/"$id".mp4 -c:a aac -ac 2 -ab 64k -ar 22050 \
  -c:v libx264 -x264opts 'keyint=24:min-keyint=24:no-scenecut' -b:v 400k -bufsize 400k -vf "scale=360:-1" \
  src/"$id"/360.mp4

mkdir ./dest/"$id"

packager \
  input=src/"$id"/720.mp4,stream=audio,output=dest/"$id"/720_audio.mp4 \
  input=src/"$id"/720.mp4,stream=video,output=dest/"$id"/720_video.mp4 \
  input=src/"$id"/540.mp4,stream=audio,output=dest/"$id"/540_audio.mp4 \
  input=src/"$id"/540.mp4,stream=video,output=dest/"$id"/540_video.mp4 \
  input=src/"$id"/360.mp4,stream=audio,output=dest/"$id"/360_audio.mp4 \
  input=src/"$id"/360.mp4,stream=video,output=dest/"$id"/360_video.mp4 \
--mpd_output dest/"$id"/manifest-full.mpd \
--min_buffer_time 2 \
--segment_duration 2

packager \
  input=src/"$id"/720.mp4,stream=audio,output=dest/"$id"/720_audio.mp4 \
  input=src/"$id"/720.mp4,stream=video,output=dest/"$id"/720_video.mp4 \
--mpd_output dest/"$id"/manifest-720.mpd \
--min_buffer_time 2 \
--segment_duration 2

packager \
  input=src/"$id"/540.mp4,stream=audio,output=dest/"$id"/540_audio.mp4 \
  input=src/"$id"/540.mp4,stream=video,output=dest/"$id"/540_video.mp4 \
--mpd_output dest/"$id"/manifest-540.mpd \
--min_buffer_time 2 \
--segment_duration 2

packager \
  input=src/"$id"/360.mp4,stream=audio,output=dest/"$id"/360_audio.mp4 \
  input=src/"$id"/360.mp4,stream=video,output=dest/"$id"/360_video.mp4 \
--mpd_output dest/"$id"/manifest-360.mpd \
--min_buffer_time 2 \
--segment_duration 2


mkdir ./dest/"$id"/hls
mkdir ./dest/"$id"/hls/720
mkdir ./dest/"$id"/hls/540
mkdir ./dest/"$id"/hls/360

mediafilesegmenter -I -t 2 ./src/"$id"/720.mp4 -f ./dest/"$id"/hls/720
mediafilesegmenter -I -t 2 ./src/"$id"/540.mp4 -f ./dest/"$id"/hls/540
mediafilesegmenter -I -t 2 ./src/"$id"/360.mp4 -f ./dest/"$id"/hls/360

mv ./dest/"$id"/hls/720/prog_index.m3u8 ./dest/"$id"/hls/720/manifest-720.m3u8
mv ./dest/"$id"/hls/540/prog_index.m3u8 ./dest/"$id"/hls/540/manifest-540.m3u8
mv ./dest/"$id"/hls/360/prog_index.m3u8 ./dest/"$id"/hls/360/manifest-360.m3u8

cd ./dest/"$id"

variantplaylistcreator -o ./manifest-full.m3u8 \
  ./hls/720/manifest-720.m3u8 ../../src/"$id"/720.plist \
  ./hls/540/manifest-540.m3u8 ../../src/"$id"/540.plist \
  ./hls/360/manifest-360.m3u8 ../../src/"$id"/360.plist

cd ../..