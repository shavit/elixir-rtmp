defmodule ExRTMP.EncoderTest do
  use ExUnit.Case
  alias ExRTMP.Encoder
  import ExRTMP.Support.Fixtures

  describe "encoder" do
    test "detect_file/1 detects mp4" do
      data = fixture_file("part_mp4")
      assert %{type: :quicktime} = Encoder.detect_file(data)
    end
  end
end
