# RTMP

[![Build Status](https://travis-ci.org/shavit/elixir-rtmp.svg?branch=master)](https://travis-ci.org/shavit/elixir-rtmp)

> Streaming server

At the moment there are no build-in media encoders, so you will need to
  implement your own.

### Configurations

  * `rtmp_port` - Environment variable `RTMP_PORT`, default to 1935.

## Development

Debug the server with `rtmpdump`

## Test

```
mix test
```

## Client

Create a message

```
$ AMF0.new "some message"
<<2, 0, 12, 115, 111, 109, 101, 32, 109, 101, 115, 115, 97, 103, 101>>
```

```
$ AMF0.new "some message"
<<6, 25, 115, 111, 109, 101, 32, 109, 101, 115, 115, 97, 103, 101>>
```