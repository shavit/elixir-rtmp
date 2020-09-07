defmodule ExRTMP.Chunk.MessageHeader do
  @moduledoc """
  `ExRTMP.Chunk.MessageHeader` encodes the message header
  """

  @doc """
  decode/1 decodes message header
  """

  def decode(<<_fmt::2, 1::6, _csid::16, msg::binary>>) do
    decode_message_header(msg)
  end

  def decode(<<_fmt::2, 0::6, _csid::8, msg::binary>>) do
    decode_message_header(msg)
  end

  def decode(<<0::2, _csid::6, msg::binary>>) do
    decode_message_header(msg)
  end

  defp decode_message_header(<<tm::24, l::16, mt::8, msid::32, b::binary>>) do
    %{
      timestamp: tm,
      length: l,
      message_type_id: mt,
      message_stream_id: msid,
      body: b
    }
  end

  defp decode_message_header(_msg), do: {:error, "could not decode message header"}
end
