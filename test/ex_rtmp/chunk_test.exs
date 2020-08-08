defmodule ExRTMP.ChunkTest do
  use ExUnit.Case
  alias ExRTMP.Chunk
  alias ExRTMP.Chunk.Message

  describe "chunk" do
    test "parse/1 parse amf string message" do
      # https://en.wikipedia.org/wiki/Real-Time_Messaging_Protocol#Connect
      # fmt
      msg = <<
        0x03,
        # timestamp
        0x0,
        0x0B,
        0x6B,
        # length
        0x0,
        0x0,
        0x19,
        # message type id, AMF0 encoded command mesage
        0x14,
        # message stream id
        0x0,
        0x0,
        0x0,
        0x0,
        # amf string marker
        0x02,
        # string message size
        0x0,
        0x0C,
        # createStream
        0x63,
        0x72,
        0x65,
        0x61,
        0x74,
        0x65,
        0x53,
        0x74,
        0x72,
        0x65,
        0x61,
        0x6D,
        # transaction id
        0x0,
        0x40,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        # null; no more arguments
        0x5
      >>

      # TODO: Implement
      # assert {:message, message, _reply} = Chunk.parse(msg)
      # assert %Message{} = message
      # assert 0x0 == message.chunk_type
      # assert 0x3 == message.chunk_stream_id
      # assert <<0x0, 0x0B, 0x6B>> == <<message.time::size(24)>>
      # 0x14 == message.message_type_id
    end
  end
end
