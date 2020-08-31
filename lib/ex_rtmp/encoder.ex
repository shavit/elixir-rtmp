defmodule ExRTMP.Encoder do
  @moduledoc """
  Documentation for `ExRTMP.Encoder`
  """
  use GenServer
  require Logger

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def init(opts) do
    state = %{
      server: Keyword.get(opts, :server)
    }

    {:ok, state}
  end

  def handle_call({:encode, msg}, _ref, state) do
    Logger.info("[Encoder] encoder message: #{inspect(msg)}")

    {:reply, state, state}
  end
end
