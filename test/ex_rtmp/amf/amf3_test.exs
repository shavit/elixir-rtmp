defmodule ExRTMP.AMF.AMF3Test do
  use ExUnit.Case
  alias ExRTMP.AMF.AMF3

  describe "amf3 encoder" do
    test "encode/1 nil" do
      assert <<1>> == AMF3.encode(nil)
    end

    test "encode/1 bool" do
      assert <<2>> == AMF3.encode(false)
      assert <<3>> == AMF3.encode(true)
    end

    test "encode/1 float" do
      assert <<0x5, 63, 241, 153, 153, 153, 153, 153, 154>> == AMF3.encode(1.1)
      assert <<0x5, 128, 0, 0, 0, 0, 0, 0, 0>> == AMF3.encode(-0.0)
      assert <<0x5, 191, 241, 153, 153, 153, 153, 153, 154>> == AMF3.encode(-1.1)
    end

    test "encode/1 unsigned integer" do
      assert <<0x4, 0>> == AMF3.encode(0)
      assert <<0x4, 11>> == AMF3.encode(11)
      assert <<0x4, 130, 8>> == AMF3.encode(264)
    end

    test "encode/1 integer" do
      assert <<0x4, 255, 255, 255, 255>> == AMF3.encode(-1)
      assert <<0x4, 255, 255, 255, 155>> == AMF3.encode(-101)
    end

    test "encode/1 vector unsigned integer" do
      assert <<0xE, 7, 0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 3>> == AMF3.encode([1, 2, 3])
    end
    test "encode/1 string" do
      assert <<6, 9, 109, 105, 107, 101>> == AMF3.encode("mike")
    end
  end

  describe "amf3 decode" do
    test "decode/1 nil" do
      assert {:ok, nil} == AMF3.decode(<<1>>)
    end

    test "decode/1 bool" do
      assert {:ok, false} == AMF3.decode(<<2>>)
      assert {:ok, true} == AMF3.decode(<<3>>)
    end

    test "decode/1 float" do
      assert {:ok, 1.1} == AMF3.decode(<<0x5, 63, 241, 153, 153, 153, 153, 153, 154>>)
    end
  end
end
