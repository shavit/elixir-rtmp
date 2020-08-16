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
      # IO.inspect Chunk.decode @valid_chunk

      %{
        command: "createStream",
        length: 25,
        stream_id: 0,
        timestamp: 2920,
        type: :command,
        value: 2.0
      } = Chunk.decode(@valid_chunk)
    end
  end
end
