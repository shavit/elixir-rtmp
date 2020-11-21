defmodule ExRTMP.AMF.AMF3Test do
  use ExUnit.Case
  alias ExRTMP.AMF.AMF3

  describe "amf3" do
    test "new/2 creates string message" do
      assert <<6, 25, 115, 111, 109, 101, 32, 109, 101, 115, 115, 97, 103, 101>> =
               AMF3.new("some message", :string)
    end
  end
 
 describe "amf3 encode" do
    test "encode/1 integer" do
      assert <<4, 0, 0, 0, 0>> = AMF3.encode(0)
      assert <<4, 0, 0, 3, 232>> = AMF3.encode(1_000)
    end
    test "encode/1 nil" do
      assert <<1>> = AMF3.encode(nil)
    end
    test "encode/1 bool" do
      assert <<2>> = AMF3.encode(false)
      assert <<3>> = AMF3.encode(true)
    end
  end
end
