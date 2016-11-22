defmodule VideoChat.Registry do
  use GenServer

  @doc """
  Start the registery
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, [name: name])
  end

  @doc """
  Lookup the bucket pid for name stored in server
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a bucket assosiated to the given name in server
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  #
  #   Server callbacks
  #
  def init(:ok) do
    IO.puts "---> Starting registry"
    {:ok, %{}}
  end

  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.fetch(names, name), names}
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
