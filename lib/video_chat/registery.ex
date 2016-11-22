defmodule VideoChat.Registery do

  @doc """
  Start the registery
  """
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, [])
  end
end
