defmodule VideoChat.Stack do
  use GenServer

  def start_link(state, opts \\ []) do
    IO.puts "Starting stack"
    GenServer.start_link(__MODULE__, state, opts)
  end

  def handle_call(:pop, _from, [h|t]) do
    {:reply, h, t}
  end

  def handle_cast({:push, h}, t) do
    {:noreply, [h|t]}
  end
end
