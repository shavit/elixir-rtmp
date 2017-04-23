defmodule VideoChat.IncomingStream do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    incoming_port = Application.get_env(:video_chat, :incoming_port)
    # IO.puts "---> Listening on port #{incoming_port} for incoming stream"

    {:ok, _socket} = :gen_udp.open(incoming_port, [:binary,
      {:active, true}, {:buffer, 524288}
      ])
  end

  # Incoming streaming data from the webcam.
  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    IO.inspect "---> Received #{byte_size(data)} bytes from #{_port}"
    VideoChat.Encoding.Encoder.push data
    {:noreply, state}
  end

  def handle_info({_, _socket}, state) do
    {:noreply, state}
  end

end
