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

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
