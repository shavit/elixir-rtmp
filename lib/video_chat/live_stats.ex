defmodule VideoChat.LiveStats do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{channels: []}, name: elem(opts, 1))
  end

  def init(state) do
    Logger.info "New channel"
    IO.inspect state

    {:ok, state}
  end

  def handle_call({:get_channels}, _from, state) do
    {:reply, state.channels, state}
  end

  def handle_call({:publish_start, _app, name}, _from, state) do
    Logger.info "Handle publish start"
    IO.inspect state

    {:reply,
      state,
      Map.put(state, :channels, [name | state.channels])}
  end

  def handle_call({:publish_end, _app, name}, _from, state) do
    Logger.info "Handle publish end"
    IO.inspect state

    channels = Enum.filter(state.channels, fn(x) -> x != name end)
    {:reply, state, Map.put(state, :channels, channels)}
  end

  def handle_call(action, from, state) do
    Logger.info "Handle call"
    IO.inspect action
    IO.inspect from
    IO.inspect state

    {:reply, state, state}
  end
end
