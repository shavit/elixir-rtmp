defmodule VideoChat.Writer do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    IO.inspect "---> Init writer"
    System.cmd("sh", ["bin/read_string"])
    IO.puts :stdio, "Starting Elixir app"
    {:ok}
  end
end
