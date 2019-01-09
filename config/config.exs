use Mix.Config

config :video_chat,
  rtmp_port: System.get_env("RTMP_PORT") || 1935
