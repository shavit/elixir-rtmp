defmodule ExRTMP.AMFTest do
  use ExUnit.Case
  alias ExRTMP.AMF

  defp assert_test_case({fun, input, expect}) do
    assert fun.(input) == expect
  end

  describe "amf" do
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
      [
        {&AMF.encode_string/1, "some value", <<0x02, 115, 111, 109, 101, 32, 118, 97, 108, 117, 101>>},
        {&AMF.encode_string/1, 1234, {:error, "invalid input"}}
      ]
      |> Enum.each(&assert_test_case/1)
    end

      test "encode_objecet/1 encodes object value" do
      [

        {&AMF.encode_string/1, 1234, {:error, "invalid input"}},
	{&AMF.encode_string/1, [1,2,3,4], {:error, "invalid input"}},
	{&AMF.encode_string/1, {1,2,3,4}, {:error, "invalid input"}},
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
  end
end
