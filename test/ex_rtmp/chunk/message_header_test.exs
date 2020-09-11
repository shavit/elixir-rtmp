defmodule ExRTMP.Chunk.MessageHeaderTest do
  use ExUnit.Case
  alias ExRTMP.Chunk.MessageHeader

  describe "message header" do
    test "new/1 creates a new message header" do
      tests =
        [
          {[message_length: 0, message_type_id: 1, message_stream_id: 2],
           %{message_length: nil, message_stream_id: nil, message_type_id: nil, timestamp: nil}}
        ]
        |> Enum.each(fn {t, x} ->
          assert %MessageHeader{} = msg = MessageHeader.new(t)
          assert x.message_length == msg.message_length
          assert x.message_stream_id == msg.message_stream_id
          assert x.message_type_id == msg.message_type_id
          assert x.timestamp == msg.timestamp
        end)
    end

    test "decode/1 decodes message header" do
      tests =
        [
          {<<2, 0, 0, 0, 0, 0, 6, 4, 0, 0, 0, 0, 0, 6, 17, 249, 187, 163>>,
           %{
             body: <<0, 0, 6, 17, 249, 187, 163>>,
             length: 0,
             message_stream_id: 67_108_864,
             message_type_id: :client_pinged,
             timestamp: 0
           }}
        ]
        |> Enum.each(fn {t, x} ->
          assert x == MessageHeader.decode(t)
        end)
    end
  end
end
