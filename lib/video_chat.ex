defmodule VideoChat do
  @moduledoc """
  `VideoChat` RTMP server application
  """

  use Application
  alias ExRTMP.Server, as: ExRTMPServer

  def start(_type, _args) do
    children = [
      {ExRTMPServer, [port: "RTMP_PORT" |> System.get_env("1935") |> String.to_integer()]}
    ]

    opts = [
      strategy: :one_for_one,
      name: VideoChat,
      max_restarts: 10,
      max_seconds: 10
    ]

    Supervisor.start_link(children, opts)
  end
end
