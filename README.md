# Diana

[![Build Status](https://travis-ci.org/shavit/Diana.svg?branch=master)](https://travis-ci.org/shavit/Diana)
[![Code Climate](https://codeclimate.com/github/shavit/Diana/badges/gpa.svg)](https://codeclimate.com/github/shavit/Diana)

Elixir Video Chat Streaming Server

This is what it is able to do now:

* Play videos on demand in HLS format.
* Seek in the videos.
* Accept streams from a webcam.
* Encode multiple videos in multiple resolutions using tasks.
* Stream live video to the server from webcam or encoders.
* Play live video from camera or live source.


![Preview](https://github.com/shavit/Diana/blob/master/doc/page-1.png?raw=true)


**TODO: Complete the quick start guide**

## Quick start

1. <s>Configure environment variables, or edit `.profile.example.`</s>
2. <s>Make *tmp* directory with a video file named *video.mp4*</s>
3. <s>Start the server using `docker-compose up`, or `bin/start`</s>
4. <s>Visit http://localhost:3000 to watch a demo.</s>
5. <s>Replace the video under `./tmp/video.mp4`</s>

### Streaming to the server
<s>Stream to udp://localhost:3001, or run `bin/udp`.</s>


### MacOS webcam client and video player

You can use [this webcam client](https://github.com/shavit/Monique)
