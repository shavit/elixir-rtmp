defmodule ExRTMP.ChunkTest do
  use ExUnit.Case
  alias ExRTMP.Chunk
  alias ExRTMP.Chunk.Message

  # https://en.wikipedia.org/wiki/Real-Time_Messaging_Protocol#Connect
  @valid_chunk <<
    # fmt
    0x03,
    # timestamp
    0x0,
    0x0B,
    0x68,
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

  describe "chunk" do
    test "decode/1 decodes a valid chunk" do
      %{
	basic_header: <<3>>,
	chunk_header: <<0, 11, 104, 0, 0, 25, 20, 0, 0, 0, 0>>,
	length: 25,
	message_stream_id: 0,
	size: 25,
	timestamp: 2920,
	type: :command
      } = Chunk.decode(@valid_chunk)
    end

    test "decode/1 creates stream" do
      msg = <<2, 0, 0, 0, 0, 0, 6, 4, 0, 0, 0, 0, 0, 6, 17, 249, 187, 163>>
      res = Chunk.decode(msg)
      assert res.body == <<0, 6, 17, 249, 187, 163>>
    end
  end
end
