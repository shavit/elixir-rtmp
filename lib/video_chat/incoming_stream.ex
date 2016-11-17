defmodule VideoChat.IncomingStream do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    IO.puts "---> Listening on port #{3001} for incoming stream"
    create_fifo

    {:ok, _socket} = :gen_udp.open(3001, [:binary, {:active, true}])
  end

  # Handle data
  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    # message = packet(data)
    # IO.inspect message

    # video_fifo = System.cwd <> "/tmp/video.pipe"
    video_fifo = System.cwd <> "/tmp/video-1.tmp"

    # Create new if not exists
    # cmd = "mkfifo #{fifo_path}"
    # port = Port.open({:spawn, cmd}, [:eof])

    # receive do
    #   {^port, {:data, res}} ->
    # end

    # cmd = "echo -n -e #{data} > #{video_fifo}"
    # Port.open({:spawn, cmd}, [:eof])

    :ok = File.write(video_fifo, data)
    IO.puts "---> Writing data"

    IO.inspect data

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
  defp create_fifo do
    video_fifo = System.cwd <> "/tmp/video-1.tmp"

    if !File.exists? video_fifo do
      port = Port.open({:spawn, "mkfifo #{video_fifo}"}, [:eof])
      {:ok, port}
    else
      {:ok}
    end
  end

end
