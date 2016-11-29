defmodule VideoChat.IncomingStream do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    IO.puts "---> Listening on port #{3001} for incoming stream"
    System.cwd <> "/tmp/video-2.tmp" |> create_fifo

    {:ok, _socket} = :gen_udp.open(3001, [:binary, {:active, true}])
  end

  # Incoming streaming data from the webcam.
  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    IO.inspect "---> Received #{byte_size(data)} bytes"
    # message = packet(data)

    # Write to the bucket
    VideoChat.EncodingBucket.add data

    {:noreply, state}
  end

  # Handle data
  def handle_info({_, _socket}, state) do
    {:noreply, state}
  end

  # Parse packet
  def packet(data) do
    IO.puts "---> Parsing data"
    IO.inspect data

    # 30 bytes * 8 = 240 bits
    <<
      _header :: size(240),
      priority_code :: bitstring-size(8),
      agent_number :: little-unsigned-integer-size(32),
      message :: bitstring-size(320)
    >> = data

    # The message
    %{
      priority_code: priority_code,
      agent_number: agent_number,
      message: String.rstrip(message),
    }
  end

  # Create new named pipe if not exists
  defp create_fifo(video_fifo) do
    # video_fifo = System.cwd <> "/tmp/video-1.tmp"

    if !File.exists? video_fifo do
      port = Port.open({:spawn, "mkfifo -m+w #{video_fifo}"}, [:eof])
      {:ok, port}
    else
      {:ok}
    end
  end

end
