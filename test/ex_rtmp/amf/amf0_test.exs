defmodule ExRTMP.AMF.AMF0Test do
  use ExUnit.Case
  alias ExRTMP.AMF.AMF0

  describe "amf0 encode" do
    test "encode/1 null message" do
      assert AMF0.encode(nil) == <<0x5>>
    end

    test "encode/1 boolean message" do
      assert AMF0.encode(true) == <<0x1, 0x1>>
      assert AMF0.encode(false) == <<0x1, 0x0>>
    end

    test "encode/1 number message" do
      assert AMF0.encode(11) == <<0, 64, 38, 0, 0, 0, 0, 0, 0>>
      assert AMF0.encode(17) == <<0, 64, 49, 0, 0, 0, 0, 0, 0>>
    end

    test "encode/1 string message" do
      assert <<2, 0, 12, 115, 111, 109, 101, 32, 109, 101, 115, 115, 97, 103, 101>> =
               AMF0.encode("some message")
    end

    test "encode/1 object message" do
      # 0, 0, 9
      msg = %{}
      assert AMF0.encode(msg) == <<3, 0, 0, 9>>
      msg = %{"a" => "b"}
      assert AMF0.encode(msg) == <<3, 0, 1, 97, 2, 0, 1, 98, 0, 0, 9>>
      msg = %{"Name" => "some name", "City" => "some city"}

      assert AMF0.encode(msg) ==
               <<3, 0, 4, 67, 105, 116, 121, 2, 0, 9, 115, 111, 109, 101, 32, 99, 105, 116, 121,
                 0, 4, 78, 97, 109, 101, 2, 0, 9, 115, 111, 109, 101, 32, 110, 97, 109, 101, 0, 0,
                 9>>
    end

    test "encode/1 strict array message" do
      msg = [1, 2, 3]

      assert AMF0.encode(msg) ==
               <<10, 0, 0, 0, 3, 0, 63, 240, 0, 0, 0, 0, 0, 0, 0, 64, 0, 0, 0, 0, 0, 0, 0, 0, 64,
                 8, 0, 0, 0, 0, 0, 0>>

      msg = [21]
      assert AMF0.encode(msg) == <<0xA, 0, 0, 0, 1, 0, 64, 53, 0, 0, 0, 0, 0, 0>>
    end

    test "encode/1 mixed array message" do
      msg = ["f", 6]
      assert AMF0.encode(msg) == <<8, 0, 0, 0, 2, 2, 0, 1, 102, 0, 64, 24, 0, 0, 0, 0, 0, 0>>
    end
  end

  describe "amf0 decode" do
    test "decode/1 null" do
      assert [nil] == AMF0.decode(<<0x5>>)
    end

    test "decode/1 boolean" do
      assert [true] == AMF0.decode(<<0x1, 0x1>>)
      assert [false] == AMF0.decode(<<0x1, 0x0>>)
    end

    test "decode/1 number" do
      msg = <<0, 63, 240, 0, 0, 0, 0, 0, 0>>
      assert [1.0] = AMF0.decode(msg)
    end

    test "decode/1 string" do
      msg = <<2, 0, 12, 115, 111, 109, 101, 32, 109, 101, 115, 115, 97, 103, 101>>
      assert ["some message"] == AMF0.decode(msg)
    end

    test "decode/1 object" do
      msg =
        <<0x03, 0x00, 0x04, 0x6E, 0x61, 0x6D, 0x65, 0x02, 0x00, 0x04, 0x4D, 0x69, 0x6B, 0x65,
          0x00, 0x03, 0x61, 0x67, 0x65, 0x00, 0x40, 0x3E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x05, 0x61, 0x6C, 0x69, 0x61, 0x73, 0x02, 0x00, 0x04, 0x4D, 0x69, 0x6B, 0x65,
          0x00, 0x00, 0x09>>

      assert %{"age" => 30.0, "alias" => "Mike", "name" => "Mike"} == AMF0.decode(msg)
    end

    test "decode/1 strict array" do
      msg = <<0xA, 0x0, 0x0, 0x0, 0x1, 0x0, 0x40, 0x26, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0>>
      assert [11.0] == AMF0.decode(msg)

      msg =
        <<10, 0, 0, 0, 3, 0, 64, 8, 0, 0, 0, 0, 0, 0, 0, 64, 16, 0, 0, 0, 0, 0, 0, 0, 64, 20, 0,
          0, 0, 0, 0, 0>>

      assert [3.0, 4.0, 5.0] == AMF0.decode(msg)
    end
  end

  describe "amf0 encode decode native types" do
    test "encode decode use atoms" do
      m = %{a: "b", c: "d", e: 5}
      b = AMF0.encode(m)
      assert AMF0.decode(b) == %{"a" => "b", "c" => "d", "e" => 5.0}
    end

    test "encode decode nested objects" do
      m = %{"a" => %{}}
      b = AMF0.encode(m)
      assert AMF0.decode(b) == %{"a" => %{}}

      m = %{a: %{b: %{}, c: 3}}
      b = AMF0.encode(m)
      assert AMF0.decode(b) == %{"a" => %{"b" => %{}, "c" => 3.0}}
    end
  end
end
