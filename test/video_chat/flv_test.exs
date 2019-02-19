defmodule VideoChat.FLVTest do
  use ExUnit.Case

  describe "flv" do

    alias VideoChat.FLV

    test "type/1 detects video audio or both" do
      assert :video == FLV.type <<70, 76, 86, 1, 1,
        0, 0, 0, 9, 0, 0, 0, 0, 18, 0, 1, 116, 0, 0, 0, 0, 0, 0, 0, 2, 0,
        10, 111, 110, 77, 101, 116, 97, 68, 97, 116, 97>>
      assert :audio == FLV.type <<70, 76, 86, 1, 4,
        0, 0, 0, 9, 0, 0, 0, 0, 18, 0, 1, 116, 0, 0, 0, 0, 0, 0, 0, 2, 0,
        10, 111, 110, 77, 101, 116, 97, 68, 97, 116, 97>>
      assert :audio_video == FLV.type <<70, 76, 86, 1, 5,
        0, 0, 0, 9, 0, 0, 0, 0, 18, 0, 1, 116, 0, 0, 0, 0, 0, 0, 0, 2, 0,
        10, 111, 110, 77, 101, 116, 97, 68, 97, 116, 97>>
    end
  end
end
