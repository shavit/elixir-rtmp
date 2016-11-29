defmodule VideoChat.Registry do
  use GenServer

  @doc """
  Start the registery
  """
  def start_link do
    # Start with the name :bucket_registry for reference
    GenServer.start_link(__MODULE__, [], [name: :bucket_registry])
  end

  @doc """
  Lookup the bucket pid for name stored in server
  """
  def lookup(server) do
    GenServer.call(server, {:lookup, :bucket_registry})
  end

  @doc """
  Ensures there is a bucket assosiated to the given name in server
  """
  def create(server) do
    GenServer.cast(server, {:create, :bucket_registry})
  end

  @doc """
  Add a message
  """
  def add(message) do
    GenServer.cast(:bucket_registry, {:add_message, message})
  end

  @doc """
  Get messages
  """
  def get do
    GenServer.call(:bucket_registry, :get_messages)
  end

  #
  #   Server callbacks
  #
  def init(messages) do
    {:ok, messages}
  end

  def handle_call(:get_messages, _from, messages) do
    {:reply, messages, messages}
  end

  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.fetch(names, name), names}
  end

  def handle_cast({:add_message, new_message}, messages) do
    {:noreply, [new_message | messages]}
  end

  def handle_cast({:create, name}, names) do
    if Map.has_key?(names, name) do
      {:noreply, names}
    else
      {:ok, bucket} = VideoChat.Bucket.start_link
      {:noreply, Map.put(names, name, bucket)}
    end
  end
end
