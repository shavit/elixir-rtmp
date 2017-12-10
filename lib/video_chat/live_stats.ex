defmodule VideoChat.LiveStats do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{channels: []}, name: elem(opts, 1))
  end

  def init(state), do: {:ok, state}

  def handle_call({:get_channels}, _from, state) do
    {:reply, state.channels, state}
  end

  def handle_call({:publish_start, _app, name}, _from, state) do
    {:reply,
      state,
      Map.put(state, :channels, [name | state.channels])}
  end

  def handle_call({:publish_end, _app, name}, _from, state) do
    channels = Enum.filter(state.channels, fn(x) -> x != name end)
    {:reply, state, Map.put(state, :channels, channels)}
  end

end
