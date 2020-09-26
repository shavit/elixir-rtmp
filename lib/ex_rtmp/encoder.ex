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

  @doc """
  detect_file/1 get the file signature for the decoder
  """
  def detect_file(<<sz::32, t0::binary-size(4), t1::binary-size(4), _rest::binary>>) do
    %{
      size: sz,
      type: get_type(t0),
      stype: t1
    }
  end

  def detect_file(_data), do: {:error, "unknown file format"}

  defp get_type(code) do
    case code do
      "ftyp" -> :quicktime
      _ -> :unknown
    end
  end
end
