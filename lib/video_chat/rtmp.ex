defmodule VideoChat.RTMP do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  # TODO: Implement in TCP
  def init(:ok) do
    rtmp_port = Application.get_env(:video_chat, :rtmp_port)
    {:ok, _socket} = :gen_udp.open(rtmp_port, [:binary,
      {:active, true}, {:buffer, 524288}
      ])
  end

  # TODO: Implement in TCP
  # TODO: Handle multiple clients
  def handle_info({:udp, socket, _ip, _port, data}, state) do
    IO.inspect "[RTMP] #{socket} | Received #{byte_size(data)} bytes"

    {:noreply, state}
  end

  def handle_info({_, _socket}, state) do
    {:noreply, state}
  end

end
