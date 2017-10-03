defmodule VideoChat.IncomingStream do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    incoming_port = Application.get_env(:video_chat, :incoming_port)
    {:ok, _socket} = :gen_udp.open(incoming_port, [:binary,
      {:active, true}, {:buffer, 524288}
      ])
  end

  # Incoming streaming data from the webcam.
  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    # IO.inspect "---> Received #{byte_size(data)} bytes from #{_port}"
    # File.write("tmp/video-complete-file.mp4", data, [:append, :binary])
    VideoChat.Encoding.StreamEncoder.push data

    {:noreply, state}
  end

  def handle_info({_, _socket}, state) do
    {:noreply, state}
  end

end
