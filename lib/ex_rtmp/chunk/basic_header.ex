defmodule ExRTMP.Chunk.BasicHeader do
  @moduledoc """
  `ExRTMP.Chunk.BasicHeader` encodes the chunk stream ID and type
  """

  defstruct [:stream_id, :type]


  def new(csid, :one) when csid > 2 and csid <= 65_599 do
    <<0::2, csid::6>>
  end
  def new(_csid, :one), do: {:error, "id out of range"}
end
