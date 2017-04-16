defmodule VideoChat.EncodingBucket do
  use GenServer
  # use Supervisor

  #
  # Create data structure to store messages from different channels
  #   with differnet identifiers and timestamps
  #

  def start_link do
    GenServer.start_link(__MODULE__, [], [name: :encoding_bucket])
    # Supervisor.start_link(__MODULE__, :ok)
  end

  # def init(:ok) do
  #   children = [
  #     worker(VideoChat.Encoder, [])
  #   ]
  #
  #   # {:ok, messages}
  #   supervise(children, strategy: :one_for_one)
  # end

  def add(message) do
    # Write to file
    File.write("tmp/video2.raw", message, [:append])
    File.write("tmp/video2.mp4", message, [:append])
    File.write("tmp/video3.mp4", message)
    # Send messages to the encoder
    VideoChat.Encoder.encode(message)

    GenServer.cast(:encoding_bucket, {:add_message, message})
  end

  def push(message) do
    # GenServer.call(:encoding_bucket, {:push_message, message})
    GenServer.cast(:encoding_bucket, {:push_message, message})
  end

  def get do
    GenServer.call(:encoding_bucket, :get_messages)
  end

  def pop do
    GenServer.call(:encoding_bucket, :pop_message)
  end

  #
  # Server callbacks
  #

  # Asynchronous
  def handle_cast({:add_message, new_message}, messages) do
    {:noreply, [new_message | messages]}
  end

  # In order for this to work, each packet should have a header
  #   with the information about the size, resolution and channel.
  # Then this server will close each file and write to disk.
  # After each write, the playlist file should be updated.
  def handle_cast({:push_message, new_message}, messages) do
    File.write("tmp/webcam_ts/#{length(messages)}.mp4", messages)
    {:noreply, [new_message | messages]}
  end

  # Synchronous
  def handle_call({:push_message, new_message}, _from, messages) do
    {:noreply, [new_message | messages]}
  end

  def handle_call(:get_messages, _from, messages) do
    {:reply, messages, messages}
  end

  def handle_call(:pop_message, _from, [message | messages]) do
    {:reply, message, messages}
  end

  def handle_call(:pop_message, _from, []) do
    {:reply, nil, []}
  end

end
