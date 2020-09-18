defmodule ExRTMP.AMFTest do
  use ExUnit.Case
  alias ExRTMP.AMF

  defp assert_test_case({fun, input, expect}) do
    assert fun.(input) == expect
  end

  describe "amf" do
    test "encode/1 encodes a message" do
      # [
      #   {&AMF.encode/1, %{id: "0", message: "some message"},
      #    <<1, 0, 6, 63, 0, 0, 30, 2, 105, 100, 2, 0, 1, 48, 7, 109, 101, 115, 115, 97, 103, 101,
      #      2, 0, 12, 115, 111, 109, 101, 32, 109, 101, 115, 115, 97, 103, 101>>}
      # ]
      # |> Enum.each(&assert_test_case/1)
    end

    test "encode_key/1 encodes object key" do
      [
        {&AMF.encode_key/1, "some key", <<0x8, 115, 111, 109, 101, 32, 107, 101, 121>>}
      ]
      |> Enum.each(&assert_test_case/1)
    end

    test "encode_number/1 encodes boolean value" do
      [
        {&AMF.encode_number/1, 0, <<0x00, 0x0, 0, 0, 0, 0, 0, 0, 0>>},
        {&AMF.encode_number/1, 12, <<0x00, 64, 40, 0, 0, 0, 0, 0, 0>>},
        {&AMF.encode_number/1, 0.11, <<0x0, 63, 188, 40, 245, 194, 143, 92, 41>>},
        {&AMF.encode_number/1, "something", {:error, "invalid input"}}
      ]
      |> Enum.each(&assert_test_case/1)
    end

    test "encode_boolean/1 encodes boolean value" do
      [
        {&AMF.encode_boolean/1, true, <<0x01, 0x01>>},
        {&AMF.encode_boolean/1, false, <<0x01, 0x00>>},
        {&AMF.encode_boolean/1, 1, <<0x01, 0x01>>},
        {&AMF.encode_boolean/1, 0, <<0x01, 0x00>>},
        {&AMF.encode_boolean/1, "something", {:error, "invalid input"}}
      ]
      |> Enum.each(&assert_test_case/1)
    end

    test "encode_string/1 encodes string value" do
      string_32bit = Enum.join(-10..0x10000)

      [
        {&AMF.encode_string/1, "some value",
         <<0x02, 0, 10, 115, 111, 109, 101, 32, 118, 97, 108, 117, 101>>},
        {&AMF.encode_string/1, "some other value",
         <<0x02, 0, 16, 115, 111, 109, 101, 32, 111, 116, 104, 101, 114, 32, 118, 97, 108, 117,
           101>>},
        {&AMF.encode_string/1, string_32bit, <<0x02, 0, 4, 212, 180>> <> string_32bit}
      ]
      |> Enum.each(&assert_test_case/1)
    end

    test "encode_object/1 encodes object value" do
      [
        {&AMF.encode_object/1, 1234, {:error, "invalid input"}},
        {&AMF.encode_object/1, [1, 2, 3, 4], {:error, "invalid input"}},
        {&AMF.encode_object/1, {1, 2, 3, 4}, {:error, "invalid input"}}
      ]
      |> Enum.each(&assert_test_case/1)
    end

    test "encode_null/1 encodes null value" do
      [
        {&AMF.encode_null/1, nil, <<0x05>>},
        {&AMF.encode_null/1, 1234, {:error, "invalid input"}},
        {&AMF.encode_null/1, "null", {:error, "invalid input"}}
      ]
      |> Enum.each(&assert_test_case/1)
    end

    test "encode_array/1 encodes array value" do
      [
        {&AMF.encode_array/1, ["some value"],
         <<0x08, 0, 0, 0, 1, 0x02, 0, 10, 115, 111, 109, 101, 32, 118, 97, 108, 117, 101>>}
      ]
      |> Enum.each(&assert_test_case/1)
    end

    test "encode_date/1 encodes date" do
      [
        {&AMF.encode_date/1, 12345, <<0x0B, 64, 200, 28, 128, 0, 0, 0, 0>>},
        {&AMF.encode_date/1, 1, <<0x0B, 63, 240, 0, 0, 0, 0, 0, 0>>}
      ]
      |> Enum.each(&assert_test_case/1)
    end
  end
end
