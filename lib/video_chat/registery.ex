defmodule VideoChat.Registery do
  use GenServer

  @doc """
  Start the registery
  """
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, [])
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
end
