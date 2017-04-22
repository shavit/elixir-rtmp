defmodule VideoChat do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, VideoChat.Router, [], [port: Application.get_env(:video_chat, :port)]),
      # Starts a worker by calling: VideoChat.Worker.start_link(arg1, arg2, arg3)
      # worker(VideoChat.Worker, [arg1, arg2, arg3]),
      worker(VideoChat.IncomingStream, []),
      # worker(VideoChat.Encoding.Encoder, [])
      worker(VideoChat.Encoding.Supervisor, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VideoChat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
