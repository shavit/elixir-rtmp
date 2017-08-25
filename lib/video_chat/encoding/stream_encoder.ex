defmodule VideoChat.Encoding.StreamEncoder do
  use GenServer

  #
  # Create data structure to store messages from different channels
  #   with differnet identifiers and timestamps
  #
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: :encoder)
  end

  def encode(data) do
    GenServer.cast(:encoder, {:encode, data})
  end

  def push(message) do
    GenServer.cast(:encoder, {:push_message, message})
  end

  def get_one(key) do
    GenServer.call(:encoder, {:get_channel_message, key})
  end

  def get_all(key) do
    GenServer.call(:encoder, {:get_channel_messages, key})
  end

  def pop(key) do
    GenServer.call(:encoder, {:pop_message, key})
  end

  def call_action(action_handler, args \\ nil) do
    GenServer.call(:encoder, {:call_action, action_handler, args})
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

    case write_data(new_message) do
      :ok ->
        nil
      _ ->
        IO.puts "---> Error writing an ecoded message into file"
    end

    key_list = (messages
      |> Map.get(new_message.channel <> new_message.resolution, []))
      |> List.insert_at(-1, {new_message.id, new_message.data})

    # This should be changed to a linked list.
    # There is a problem with duplicates, altough it shouldn't happen
    #   with UDP messages, since they will not be sent if they dropped.
    {:noreply,
      Map.put(messages,
        new_message.channel <> new_message.resolution,
        key_list)}
  end

  # Synchronous
  def handle_call({:call_action, action_handler, args}, _from, actions) do
    # Process.send_after(self(), :try_running, 0)
    {:reply, action_handler.(args), actions}
  end

  def handle_call({:get_channel_message, key}, _from, messages) do
    <<
    channel :: bitstring-size(32),
    resolution :: bitstring-size(8),
    id :: bitstring-size(32)
    >> = key

    {:reply,
      Map.get(messages, channel<>resolution)
        |> Enum.filter(fn x -> elem(x, 0) == id end)
        |> List.first
        |> elem(1),
      messages}
  end

  def handle_call({:get_channel_messages, key}, _from, messages) do
    {:reply,
      ((Map.get(messages, key) || [])
        |> Enum.sort),
      messages}
  end

  def handle_call({:pop_message, key}, _from, messages) do
    {message, key_list} = (Map.get(messages, key) || [])
      |> List.pop_at(0)

    {:reply,
      elem((message || {nil, nil}), 1),
      Map.put(messages,
        key,
        key_list)}
  end

  def handle_call(:pop_message, _from, []) do
    {:reply, nil, %{}}
  end

  defp write_data(message) do
    # File.write("tmp/picture-#{message.channel}-#{message.resolution}.jpg",
    #   message.data,
    #   [:append, :binary])
    # IO.inspect message.id
    File.write("tmp/video-#{message.channel}-#{message.resolution}-#{message.id}.mp4",
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
      id :: bitstring-size(32),
      data :: binary
    >> = message

    # IO.inspect "C:#{channel} | R:#{resolution} | ID: #{id}"

    %{
      channel: channel,
      resolution: resolution,
      id: id,
      data: data
    }
  end
end
