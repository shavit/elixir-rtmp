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
  def handle_cast({:push_message, data}, messages) do
    new_message = data
      |> parse_message

    :ok = new_message
      |> write_data

    IO.inspect "---> New message"
    IO.inspect new_message.channel
    IO.inspect <<new_message.resolution>>

    # File.write("tmp/webcam_ts/#{length(messages)}.mp4", messages)
    {:noreply, [new_message | messages]}
  end

  # Synchronous
  def handle_call({:push_message, data}, _from, messages) do

    new_message = data
      |> parse_message

    :ok = new_message
      |> write_data

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

  defp write_data(message) do
    # File.write("tmp/picture-#{message.channel}.jpg", message.data)
    # File.write("tmp/picture-#{message.channel}.jpg", message.data, [:append])
    File.write("tmp/video-#{message.channel}.mp4", message.data, [:append])
  end

  # Messages should not exceed 4000 bytes
  defp parse_message(message) do
    # channel: 001
    # resolution: 1 | 2 | 3 | 4
    # data: binary
    <<
      channel :: little-unsigned-integer-size(32),
      resolution :: little-unsigned-integer-size(8),
      data :: binary
    >> = message

    IO.inspect "C:#{channel} | R:#{resolution}"

    %{
      channel: channel,
      resolution: resolution,
      data: data
    }
  end
end
