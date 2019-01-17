defmodule VideoChat.RTMP.AMFTest do
  use ExUnit.Case

  describe "amf" do

    alias VideoChat.RTMP.AMF

    test "parse/1 parses a message" do
      assert %AMF{} = amf = AMF.parse <<0x02, 0x00, 0x0c, 115, 111, 109, 101, 32, 109, 101, 115, 115, 97, 103, 101>>
      assert "some message" == amf.body
      assert 12 == amf.length
      assert :string_marker == amf.marker

      assert %AMF{} = amf = AMF.parse  <<0x02, 0x00, 0x07, 0x5f, 0x72, 0x65, 0x73, 0x75, 0x6c, 0x74, 0x00, 0x3f, 0xf0, 0x00, 0x00, 0x00>>
      assert "_result" == amf.body
      assert 7 == amf.length
      assert :string_marker == amf.marker
    end
  end
end
