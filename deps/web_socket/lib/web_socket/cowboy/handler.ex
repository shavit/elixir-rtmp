defmodule WebSocket.Cowboy.Handler do
  @moduledoc """
  """

  @behaviour :cowboy_websocket_handler
  @connection Plug.Adapters.Cowboy.Conn
  alias WebSocket.Events
  alias WebSocket.Message

  @type reply :: tuple

  defmodule State do
    @moduledoc """
    """
    defstruct conn: nil,
              plug: nil,
              action: nil,
              use_topics: true

    @type t :: %__MODULE__{
                 conn: Plug.Conn.t,
                 plug: atom,
                 action: atom,
                 use_topics: boolean
               }
  end

  ## Init

  @doc """
  """
  @spec init(atom, :cowboy_req.req, {atom, atom}) :: {:upgrade, :protocol, :cowboy_websocket}
  def init(_transport, _req, {_plug, action}) do
    {:ok, _pid} = Events.start_link(action)
    {:upgrade, :protocol, :cowboy_websocket}
  end

  @doc """
  """
  @spec websocket_init(atom, :cowboy_req.req, {atom, atom}) :: reply
  def websocket_init(transport, req, opts) do
    state = @connection.conn(req, transport)
      |> build_state(opts)
    Events.subscribe(state.action, self)
    args = get_args(:init, state)
    handle_reply req, args, state
  end

  ## Handle

  @doc """
  """
  @spec websocket_handle(tuple, :cowboy_req.req, State.t) :: reply
  def websocket_handle({:text, msg} = event, req, state) do
    Events.broadcast(state.action, event, self)
    args = get_args(msg, state)
    handle_reply req, args, state
  end

  def websocket_handle(_other, req, state) do
    {:ok, req, state}
  end

  ## Info

  @doc """
  """
  @spec websocket_info(tuple, :cowboy_req.req, State.t) :: reply
  def websocket_info({:timeout, _ref, msg} = event, req, state) do
    Events.broadcast(state.action, event, self)
    args = get_args(msg, state)
    handle_reply req, args, state
  end

  def websocket_info({:text, msg}, req, state) do
    args = get_args(msg, state)
    handle_reply req, args, state
  end

  def websocket_info(_info, req, state) do
    {:ok, req, state, :hibernate}
  end

  ## Terminate

  @doc """
  """
  @spec websocket_terminate(atom | tuple, :cowboy_req.req, State.t) :: :ok
  def websocket_terminate(_reason, _req, state) do
    Events.unsubscribe(state.action, self)
    apply(state.plug, state.action, [:terminate, state])
  end

  @doc """
  """
  @spec terminate(atom | tuple, :cowboy_req.req, State.t) :: :ok
  def terminate(_reason, _req, state) do
    Events.stop(state.action)
    :ok
  end

  ## Helpers

  defp build_state(conn, {plug, action}) do
    conn = update_scheme(conn)
    %State{conn: conn,
           plug: plug,
           action: action}
  end

  defp get_args(:init, state),      do: [:init, state]
  defp get_args(:terminate, state), do: [:terminate, state]
  defp get_args(message, %State{use_topics: false} = state) do
    [message, state]
  end
  defp get_args(message, %State{use_topics: true} = state) do
    case Poison.decode(message, as: Message) do
      {:ok, mes} -> [mes.event, state, mes.data]
      _          -> [message, state]
    end
  end

  defp get_payload([event, _, _], payload) do
    payload = Message.build(event, payload)
    case Poison.encode(payload) do
      {:ok, result} -> result
      _             -> payload
    end
  end

  defp handle_reply(req, args, state) do
    do_handle_reply req, args, apply(state.plug, state.action, args)
  end

  defp do_handle_reply(req, _args, {:ok, state}) do
    {:ok, req, state}
  end
  defp do_handle_reply(req, _args, {:reply, {opcode, payload}, state}) when payload |> is_binary do
    {:reply, {opcode, payload}, req, state, :hibernate}
  end
  defp do_handle_reply(req, args, {:reply, {opcode, payload}, state}) do
    payload = get_payload(args, payload)
    {:reply, {opcode, payload}, req, state, :hibernate}
  end
  defp do_handle_reply(req, _args, {:shutdown}) do
    {:shutdown, req}
  end

  defp update_scheme(%Plug.Conn{scheme: :http} = conn) do
    %{conn | scheme: :ws}
  end
  defp update_scheme(%Plug.Conn{scheme: :https} = conn) do
    %{conn | scheme: :wss}
  end
end
