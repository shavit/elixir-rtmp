defmodule ExRTMP.Chunk.MessageHeader do
  @moduledoc """
  `ExRTMP.Chunk.MessageHeader` encodes the message header

  Type 0 - 11 bytes
  Type 1 - 7 bytes
  Type 2 - 3 bytes
  Type 3 - No message header
  """
  alias ExRTMP.ControlMessage
  defstruct [:timestamp, :message_length, :message_type_id, :message_stream_id]

  @doc"""
  new/1 creates a new message header
  """
  def new(opts) do
    %__MODULE__{}
  end

  @doc """
  decode/1 decodes message header
  """

  def decode(<<_fmt::2, 1::6, _csid::16, msg::binary>>) do
    msg
  end

  def decode(<<_fmt::2, 0::6, _csid::8, msg::binary>>) do
    msg
  end

  def decode(<<0::2, _csid::6, msg::binary>>) do
    case msg do
      <<tm::24, l::16, mt::8, msid::32, b::binary>> ->
        %{
          timestamp: tm,
          length: l,
          message_type_id: ControlMessage.get_type(mt),
          message_stream_id: msid,
          body: b
        }

      _ ->
        {:error, "could not decode message header"}
    end
  end
end
