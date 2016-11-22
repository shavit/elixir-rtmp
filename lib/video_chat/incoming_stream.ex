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

  # Handle data
  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    # message = packet(data)
    # IO.inspect message
    IO.inspect data

    # video_fifo = System.cwd <> "/tmp/video.pipe"
    video_fifo = System.cwd <> "/tmp/video-2.tmp"

    # cmd = "bin/get_format #{video_fifo}"
    # port = Port.open({:spawn, cmd}, [:eof])
    # receive do
    #   {^port, {:data, res}} ->
    #     IO.inspect "---> The format is"
    #     IO.inspect res
    # end

    # Create new if not exists
    # cmd = "mkfifo #{fifo_path}"
    # port = Port.open({:spawn, cmd}, [:eof])

    # receive do
    #   {^port, {:data, res}} ->
    # end

    # cmd = "echo -n -e #{data} > #{video_fifo}"
    # Port.open({:spawn, cmd}, [:eof])

    # This is not writing the file correctly
    IO.inspect "---> Writing to #{video_fifo}"
    # Write to the bucket
    res = File.write(video_fifo, data, [:append])
    IO.inspect res
    # IO.puts "---> Writing data"

    {:ok, bucket} = VideoChat.Bucket.start_link
    VideoChat.Bucket.add(bucket, :live_video, data)
    res = File.write(System.cwd <> "/tmp/video-4.tmp", data, [:append])
    IO.inspect res

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
