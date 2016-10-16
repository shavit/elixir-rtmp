defmodule VideoChat.Server do
  def init(opts) do
    {:ok,
      Plug.Adapters.Cowboy.child_spec(:http,
        VideoChat.Router,
        opts,
        [port: 4001])}
  end

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, VideoChat.Router, [], [port: 4001]),
    ]

    opts = [strategy: :one_for_one, name: VideoChat.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
