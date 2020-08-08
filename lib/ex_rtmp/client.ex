defmodule ExRTMP.Client do
  @moduledoc """
  `ExRTMP.Client` RTMP client
  """
  use GenServer, restart: :transient
  alias ExRTMP.Handshake
  require Logger

  # TODO: Register and supervise

  # TODO: Discover encoder/decoder from the parent

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def init(opts) do
    ip = opts |> Keyword.get(:ip, "127.0.0.1") |> String.to_charlist()
    port = opts |> Keyword.get(:port, "1939") |> String.to_integer()
    opts = [:binary, {:active, false}, {:buffer, 1800}]
    {:ok, sock} = :gen_tcp.connect(ip, port, opts)

    {:ok, %{conn: sock}}
  end

  @doc """
  new/1 establishes a connection to a remote rtmp server
  """
  def new(args \\ []), do: start_link(args)

  def handshake do
    GenServer.call(__MODULE__, {:handshake})
  end

  def handle_call({:handshake}, _ref, state) do
    Handshake.send_c0(state.conn)
    Handshake.send_c1(state.conn)

    {:reply, :ok, state}
  end
end
