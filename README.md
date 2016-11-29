# Diana Video Chat

![Video Chat](https://github.com/shavit/verbose-parakeet/raw/master/doc/meme.gif?raw=true)

* Play videos on demand.
* Seek in the videos.
* Stream live video to the server from webcam or encoders.
* Play live video from camera or live source.
* Encode videos on the fly.

## Quick start

Start the server `bin/start`, visit http://localhost:3000.

There are 3 players on the page:
  1. Playing streamed video.
  2. Playing HLS.
  3. Playing live stream from a webcam.

### Streaming to the server
Stream to udp://localhost:3001, or run `bin/udp`.
