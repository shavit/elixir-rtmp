defmodule ExRTMP.AMFTest do
  use ExUnit.Case
  alias ExRTMP.AMF

  defp assert_test_case({input, expect}) do
    assert AMF.encode_key(input) == expect
  end

  describe "amf" do

    test "encode_key/1 encodes object key" do
      [
	{"some key", <<0x8, 115, 111, 109, 101, 32, 107, 101, 121>>}
      ] |> Enum.each(&assert_test_case/1)
    end
  end
end
