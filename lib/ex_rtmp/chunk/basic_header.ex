defmodule ExRTMP.Chunk.BasicHeader do
  @moduledoc """
  `ExRTMP.Chunk.BasicHeader` encodes the chunk stream ID and type
  """

  defstruct [:stream_id, :type]

  @doc """
  new/2 creates a basic header

    * Type 0 - 1 byte
    * Type 1 - 2 bytes
    * Type 2 - 3 bytes

  ## Params
    * fmt - The chunk type, that will determine the message header
    * csid - The size will determine basic header format
  """
  def new(csid, :one) when csid > 2 and csid <= 63 do
    <<0::2, csid::6>>
  end

  def new(csid, :two) when csid >= 64 and csid <= 319 do
    <<1::2, 0::6, csid - 64::8>>
  end

  def new(csid, :three) when csid >= 64 and csid <= 65_599 do
    <<1::2, 1::6, csid - 64::16-little>>
  end

  def new(_csid, :one), do: {:error, "id out of range"}
  def new(_csid, :two), do: {:error, "id out of range"}
  def new(_csid, :three), do: {:error, "id out of range"}

  def decode(<<0::2, csid::6, rest::binary>>), do: new(csid, :one)
  def decode(_msg), do: nil
end
