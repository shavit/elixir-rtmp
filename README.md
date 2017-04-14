# Diana Elixir Video Chat Streaming Server

![Video Chat](https://github.com/shavit/verbose-parakeet/raw/master/doc/meme.gif?raw=true)

* Play videos on demand.
* Seek in the videos.
* <s>Stream live video to the server from webcam or encoders.</s>
* <s>Play live video from camera or live source.</s>
* <s>Encode videos on the fly.<s>

## Quick start

1. Configure environment variables, or edit `.profile.example.`
2. Make *tmp* directory with a video file named *video.mp4*
3. Start the server using `bin/start`

Visit http://localhost:3000.

There are 3 players on the page:
  1. Playing streamed video.
  2. Playing HLS.
  3. <s>Playing live stream from a webcam.</s>

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

### MacOS webcam client

You can use [this webcam client](https://github.com/shavit/Monique)
