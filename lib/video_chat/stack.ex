defmodule VideoChat.Stack do
  use GenServer

  def start_link(state, opts \\ []) do
    IO.puts "Starting stack"
    # GenServer.start_link(__MODULE__, state, opts)
    GenServer.start_link(VideoChat.Server, state, opts)
    # Plug.Adapters.Cowboy.child_spec(:http, VideoChat.Router, [], [port: 4001])
  end

  def handle_call(:pop, _from, [h|t]) do
    {:reply, h, t}
  end

  def handle_cast({:push, h}, t) do
    {:noreply, [h|t]}
  end
end
