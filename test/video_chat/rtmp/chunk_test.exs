defmodule VideoChat.RTMP.ChunkTest do
  use ExUnit.Case
  alias VideoChat.RTMP.Chunk
  alias VideoChat.RTMP.Chunk.Message

  describe "chunk" do

    test "parse/1 creates a command message" do
      # https://en.wikipedia.org/wiki/Real-Time_Messaging_Protocol#Connect
      msg = <<0x03, #fmt
        0x0, 0x0b, 0x6b, # timestamp
        0x0, 0x0, 0x19, # length
        0x14, # message type id, AMF0 encoded command mesage
        0x0, 0x0, 0x0, 0x0, # message stream id
      >>
      assert {:message, message, _reply} = Chunk.parse msg
      assert %Message{} = message
      assert 0x0 == message.chunk_type
      assert 0x3 == message.chunk_stream_id
      assert <<0x0, 0x0b, 0x6b>> == <<message.time::size(24)>>
      assert 0x14 == message.message_type_id
    end
  end
end
