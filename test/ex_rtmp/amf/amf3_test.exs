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
    
    test "encode/1 string" do
      assert <<6, 9, 109, 105, 107, 101>> == AMF3.encode("mike")
    end

    test "encode/1 array" do
      assert <<0x9, 0, 0, 0, 1, 6, 3, 97>> == AMF3.encode(["a"])
      assert <<9, 0, 0, 0, 3, 6, 3, 97, 6, 3, 98, 6, 3, 99>> == AMF3.encode(["a", "b", "c"])
    end

    test "encode/1 vector integer" do
      assert <<13, 3, 0, 255, 255, 255, 255>> == AMF3.encode([-1])
      assert <<13, 3, 0, 255, 255, 255, 245>> == AMF3.encode([-11])
      assert <<0xd, 7, 0, 0, 0, 0, 1, 0, 0, 0, 0, 255, 255, 255, 255>> == AMF3.encode([1, 0, -1])
    end

    test "encode/1 vector unsigned integer" do
      assert <<0xe, 3, 0, 0, 0, 0, 0>> == AMF3.encode([-0])
      assert<<0xe, 5, 0, 0, 0, 0, 0, 0, 0, 0, 1>> == AMF3.encode([0, 1])
      assert <<0xe, 7, 0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 3>> == AMF3.encode([1, 2, 3])
      assert <<0xe, 9, 0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 0>> == AMF3.encode([1, 2, 3, -0])
    end
    
    test "encode/1 vector double" do
      assert <<0xf, 0, 0, 0, 1, 191, 240, 0, 0, 0, 0, 0, 0>> == AMF3.encode([-1.0])
      assert <<0xf, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 63, 240, 0, 0, 0, 0, 0, 0, 191, 240, 0, 0, 0, 0, 0, 0>> == AMF3.encode([0, 1, -1.0])
      assert <<15, 0, 0, 0, 3, 63, 240, 0, 0, 0, 0, 0, 0, 64, 0, 0, 0, 0, 0, 0, 0, 64, 8, 0, 0, 0, 0, 0, 0>> = AMF3.encode([1, 2, 3.0])
      assert <<15, 0, 0, 0, 1, 63, 239, 174, 20, 122, 225, 71, 174>> == AMF3.encode([0.99])
    end

    test "encode/1 object" do
      assert <<0xa, 0>> == AMF3.encode(%{})
      assert <<0xa, 1, 3, 97, 10, 0>> == AMF3.encode(%{a: %{}})
      assert <<0xa, 1, 3, 97, 10, 0>> == AMF3.encode(%{"a" => %{}})
      assert <<0xa, 1, 3, 98, 10, 1, 7, 102, 111, 111, 6, 7, 98, 97, 114>> == AMF3.encode(%{"b" => %{"foo" => "bar"}})
      assert <<0xa, 1, 3, 98, 10, 1, 7, 102, 111, 111, 6, 7, 98, 97, 114>> == AMF3.encode(%{b: %{foo: "bar"}})
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
