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
      ] |> Enum.each(&assert_test_case/1)
    end

    test "encode_boolean/1 encodes boolean value" do
      [
    	{&AMF.encode_boolean/1, true, <<0x01, 0x01>>},
    	{&AMF.encode_boolean/1, false, <<0x01, 0x00>>},
    	{&AMF.encode_boolean/1, 1, <<0x01, 0x01>>},
    	{&AMF.encode_boolean/1, 0, <<0x01, 0x00>>},
    	{&AMF.encode_boolean/1, "something", {:error, "invalid input"}},
      ] |> Enum.each(&assert_test_case/1)      
    end
  end
end
