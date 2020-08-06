defmodule ExRTMP.Client do
    @moduledoc """
    `VideoChat.RTMP.Client`
    """

    # TODO: Register and supervise

    # TODO: Discover encoder/decoder from the parent

    @doc """
    new/1 establish a connection to a remote server
    """
    def new(_opts) do
      ip = '127.0.0.1' # TODO: Change this
      port = 1939 # TODO: Change this
      opts = [:binary, {:active, false}, {:buffer, 1800}]
      {:ok, sock} = :gen_tcp.connect(ip, port, opts)
      sock
    end

    
end
