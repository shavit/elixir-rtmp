use Mix.Config

config :video_chat,
  port: case System.get_env("PORT") do nil -> 3000; port -> String.to_integer(port); end
  incoming_port: case System.get_env("INCOMING_PORT") do nil -> 3001; port -> String.to_integer(port); end
  media_directory: case System.get_env("MEDIA_DIRECTORY") do nil -> ""; dir -> dir; end
