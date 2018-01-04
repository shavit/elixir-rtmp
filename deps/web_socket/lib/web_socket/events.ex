defmodule WebSocket.Events do
  @moduledoc """
  """

  use GenEvent

  @type event :: {:add_client | :remove_client, pid}
               | {:send, tuple, pid}
  @type state :: [pid]

  ## Public API

  @doc """
  """
  @spec start_link(atom) :: {:ok, pid}
  def start_link(ref) do
    case GenEvent.start_link(name: ref) do
      {:ok, pid} ->
        GenEvent.add_handler(ref, __MODULE__, [])
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        {:ok, pid}
    end
  end

  @doc """
  """
  @spec subscribe(atom, pid) :: :ok
  def subscribe(ref, pid) do
    GenEvent.notify(ref, {:add_client, pid})
  end

  @doc """
  """
  @spec unsubscribe(atom, pid) :: :ok
  def unsubscribe(ref, pid) do
    GenEvent.notify(ref, {:remove_client, pid})
  end

  @doc """
  """
  @spec broadcast(atom, tuple, pid | nil) :: :ok
  def broadcast(ref, event, originator) do
    GenEvent.notify(ref, {:send, event, originator})
  end

  @doc """
  """
  @spec broadcast!(atom, tuple) :: :ok
  def broadcast!(ref, event) do
    broadcast(ref, event, nil)
  end

  @doc """
  """
  @spec stop(atom) :: :ok
  def stop(ref) do
    GenEvent.stop(ref)
  end

  ## Callbacks

  @doc """
  """
  @spec handle_event(event, state) :: {:ok, state}
  def handle_event({:add_client, pid}, clients) do
    {:ok, [pid|clients]}
  end

  def handle_event({:remove_client, pid}, clients) do
    {:ok, clients |> Enum.filter(&(&1 != pid))}
  end

  def handle_event({:send, event, originator}, clients) do
    spawn fn ->
      clients |> Enum.map(&(maybe_send(&1, originator, event)))
    end
    {:ok, clients}
  end

  defp maybe_send(client, originator, event) do
    unless client == originator do
      send client, event
    end
  end
end
