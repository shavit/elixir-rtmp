defmodule VideoChat.RTMP.AMF0Test do
  use ExUnit.Case
  alias VideoChat.RTMP.AMF0

  describe "amf0" do
    test "new/1 creates string message" do
      assert <<2, 0, 12, 115, 111, 109, 101, 32, 109, 101, 115, 115, 97, 103, 101>> =
               AMF0.new("some message")
    end

    test "deserialize/1 creates a struct from amf message" do
      raw_message =
        <<0x03, 0x00, 0x04, 0x6E, 0x61, 0x6D, 0x65, 0x02, 0x00, 0x04, 0x4D, 0x69, 0x6B, 0x65,
          0x00, 0x03, 0x61, 0x67, 0x65, 0x00, 0x40, 0x3E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x05, 0x61, 0x6C, 0x69, 0x61, 0x73, 0x02, 0x00, 0x04, 0x4D, 0x69, 0x6B, 0x65,
          0x00, 0x00, 0x09>>

      assert {:ok, %AMF0{} = amf} = AMF0.deserialize(raw_message)
      assert 30.0 == Map.get(amf.body, "age")
      assert "Mike" == Map.get(amf.body, "alias")
      assert "Mike" == Map.get(amf.body, "name")
    end
  end
end
