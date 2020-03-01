defmodule VideoChat.HLSTest do
  use ExUnit.Case
  alias VideoChat.HLS.Segment

  @valid_attrs %{
    duration: 9.0,
    src: "https://example.com/vod/2.ts"
  }

  describe "segment" do
    test "new/2 creates HLS segment struct" do
      assert %Segment{} = segment = Segment.new(@valid_attrs.src, @valid_attrs.duration)
      assert segment.duration == @valid_attrs.duration
      assert segment.src == @valid_attrs.src
    end

    test "to_string/1 returns segment tags" do
      segment = Segment.new(@valid_attrs.src, @valid_attrs.duration)

      expected = """
      #EXTINF:9.0
      https://example.com/vod/2.ts
      """

      assert Segment.to_string(segment) =~ expected
    end
  end
end
