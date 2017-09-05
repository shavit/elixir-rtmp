# Diana

[![Build Status](https://travis-ci.org/shavit/Diana.svg?branch=master)](https://travis-ci.org/shavit/Diana)
[![Code Climate](https://codeclimate.com/github/shavit/Diana/badges/gpa.svg)](https://codeclimate.com/github/shavit/Diana)

Elixir Video Chat Streaming Server

![Preview](https://github.com/shavit/Diana/blob/master/doc/meme.gif?raw=true)

This is not production ready yet, although part of this server is already in use to serve videos on demand.

This is what it is able to do now:

* Play videos on demand in HLS format.
* Seek in the videos.
* Accept streams from a webcam.
* Encode multiple videos in multiple resolutions using tasks.
* <s>Stream live video to the server from webcam or encoders.</s>
* <s>Play live video from camera or live source.</s>
* <s>Encode live videos from a stream.</s> (however it is possible using ffmpeg directly)


![Preview](https://github.com/shavit/Diana/blob/master/doc/page-1.png?raw=true)


## Quick start

1. Configure environment variables, or edit `.profile.example.`
2. Make *tmp* directory with a video file named *video.mp4*
3. Start the server using `docker-compose up`, or `bin/start`
4. Visit http://localhost:3000 to watch a demo.
5. Replace the video under `./tmp/video.mp4`

### Streaming to the server
Stream to udp://localhost:3001, or run `bin/udp`.

### Streaming HLS using FFMPEG

Listen, encode and write to file:
````
bin/read_hls
````

Stream the video from the `tmp` directory:
````
bin/stream_hls
````

### MacOS webcam client and video player

You can use [this webcam client](https://github.com/shavit/Monique)
