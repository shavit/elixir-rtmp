defmodule VideoChat.Encoding.Encoder do
  use GenServer
  # use Supervisor

  #
  # Create data structure to store messages from different channels
  #   with differnet identifiers and timestamps
  #

  def start_link(opts \\ {:id, :default}) do
    {:id, id} = opts
    IO.inspect "---> Starting encoding bucket: #{id}"
    {:ok, _pid} = GenServer.start_link(__MODULE__, %{id: id}, [])
  end

  def encode(data) do
    GenServer.cast(:encoder, {:encode, data})
  end

  def push(pid, message) do
    GenServer.cast(pid, {:push_message, message})
  end

  def get_one(pid, key) do
    GenServer.call(pid, {:get_messages, key})
  end

  def pop(pid, key) do
    GenServer.call(pid, {:pop_message, key})
  end

  def call_action(pid, action_handler, args \\ nil) do
    GenServer.call(pid, {:call_action, action_handler, args})
  end

  def handle_call({:call_action, action_handler, args}, _from, actions) do
    # Process.send_after(self(), :try_running, 0)
    {:reply, action_handler.(args), actions}
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
      |> Map.get(new_message.channel <> new_message.resolution <> new_message.id, []))
      |> List.insert_at(-1, new_message.data)

    {:noreply,
      Map.put(messages,
        new_message.channel <> new_message.resolution <> new_message.id,
        key_list)}
  end

  # Synchronous
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
