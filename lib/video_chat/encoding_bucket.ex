defmodule VideoChat.EncodingBucket do
  use GenServer
  # use Supervisor

  #
  # Create data structure to store messages from different channels
  #   with differnet identifiers and timestamps
  #

  def start_link do
    GenServer.start_link(__MODULE__, %{}, [name: :encoding_bucket])
    # Supervisor.start_link(__MODULE__, :ok)
  end

  def push(message) do
    GenServer.cast(:encoding_bucket, {:push_message, message})
  end

  def get(key) do
    GenServer.call(:encoding_bucket, {:get_messages, key})
  end

  def pop(key) do
    GenServer.call(:encoding_bucket, {:pop_message, key})
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

    key_list = (messages
      |> Map.get(new_message.channel <> new_message.resolution, []))
      |> List.insert_at(-1, new_message.data)

    {:noreply,
      Map.put(messages,
        new_message.channel <> new_message.resolution,
        key_list)}
  end

  # Synchronous
  def handle_call({:push_message, data}, _from, messages) do

    new_message = data
      |> parse_message

    :ok = new_message
      |> write_data

    key_list = (messages
      |> Map.get(new_message.channel <> new_message.resolution, []))
      |> List.insert_at(-1, new_message.data)

    {:noreply,
      Map.put(messages,
        new_message.channel <> new_message.resolution,
        key_list)}
  end

  def handle_call({:get_messages, key}, _from, messages) do
    {:reply,
      Map.get(messages, key),
      messages}
  end

  def handle_call({:pop_message, key}, _from, messages) do
    {message, key_list} = messages
      |> Map.get(key)
      |> List.pop_at(0)

    {:reply,
      message,
      Map.put(messages,
        key,
        key_list)}
  end

  def handle_call(:pop_message, _from, []) do
    {:reply, nil, %{}}
  end

  defp write_data(message) do
    # File.write("tmp/picture-#{message.channel}.jpg", message.data)
    # File.write("tmp/picture-#{message.channel}-#{message.resolution}.jpg",
    #   message.data,
    #   [:append, :binary])
    File.write("tmp/video-#{message.channel}-#{message.resolution}.mp4",
      message.data,
      [:append, :binary])
  end

  # Messages should not exceed 4000 bytes
  defp parse_message(message) do
    # channel: 001
    # resolution: 1 | 2 | 3 | 4
    # data: binary
    <<
      channel :: bitstring-size(32),
      resolution :: bitstring-size(8),
      data :: binary
    >> = message

    # IO.inspect "C:#{channel} | R:#{resolution}"

    %{
      channel: channel,
      resolution: resolution,
      data: data
    }
  end
end
