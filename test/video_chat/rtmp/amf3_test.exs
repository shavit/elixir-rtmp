defmodule VideoChat.RTMP.AMF3Test do
  use ExUnit.Case
  alias VideoChat.RTMP.AMF3

  describe "amf3" do
    test "new/2 creates string message" do
      assert <<6, 25, 115, 111, 109, 101, 32, 109, 101, 115, 115, 97, 103, 101>> =
               AMF3.new("some message", :string)
    end
  end
end
