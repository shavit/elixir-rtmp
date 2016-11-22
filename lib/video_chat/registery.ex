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

end
