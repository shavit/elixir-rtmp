defmodule VideoChat.FLVTest do
  use ExUnit.Case

  describe "flv" do
    alias VideoChat.FLV

    test "type/1 detects video audio or both" do
      assert :video ==
               FLV.type(
                 <<70, 76, 86, 1, 1, 0, 0, 0, 9, 0, 0, 0, 0, 18, 0, 1, 116, 0, 0, 0, 0, 0, 0, 0,
                   2, 0, 10, 111, 110, 77, 101, 116, 97, 68, 97, 116, 97>>
               )

      assert :audio ==
               FLV.type(
                 <<70, 76, 86, 1, 4, 0, 0, 0, 9, 0, 0, 0, 0, 18, 0, 1, 116, 0, 0, 0, 0, 0, 0, 0,
                   2, 0, 10, 111, 110, 77, 101, 116, 97, 68, 97, 116, 97>>
               )

      assert :audio_video ==
               FLV.type(
                 <<70, 76, 86, 1, 5, 0, 0, 0, 9, 0, 0, 0, 0, 18, 0, 1, 116, 0, 0, 0, 0, 0, 0, 0,
                   2, 0, 10, 111, 110, 77, 101, 116, 97, 68, 97, 116, 97>>
               )
    end

    test "parse/1 parses data" do
      type = 0x12
      # 1001
      pckt_size = <<49, 48, 48, 49>>
      # <<48, 49, 48, 48>>
      prv_size = 808_529_968
      pckt_type = 0x12
      p_type = 0x12
      # "123"
      p_size = <<49, 50, 51>>
      # "234"
      tstamp_l = <<50, 51, 52>>
      tstamp_u = 0x9
      # "523"
      stream_id = <<53, 50, 51>>
      # <<115, 111, 109, 101, 32, 116, 101, 115, 116, 32, 100, 97, 116, 97>>
      p_data = "some test data"

      msg =
        <<0x46, 0x4C, 0x56, 0x1, pckt_type, 49, 48, 48, 49, 48, 49, 48, 48, 0x12, 49, 50, 51, 50,
          51, 52, 0x9, 53, 50, 51>> <> p_data

      assert p_data == FLV.parse(msg)
    end
  end
end
