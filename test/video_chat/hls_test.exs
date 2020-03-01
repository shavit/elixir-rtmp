defmodule VideoChat.HLSTest do
  use ExUnit.Case
  alias VideoChat.HLS
  alias VideoChat.HLS.Segment

  @valid_segment %{
    duration: 9.0,
    src: "https://example.com/vod/2.ts"
  }

  describe "hls" do
    test "add_segment/2 appends a segment" do
      opts = %{cache: true}
      hls = HLS.new(opts)
      segment = %Segment{}

      assert %HLS{segments: segments} = segement = HLS.add_segment(hls, segment)
      assert [segment] == segments

      assert %HLS{segments: segments} = HLS.add_segment(hls, segment)
      assert [segment] == List.last(segments)
      assert [segment] == List.first(segments)
    end
  end

  describe "segment" do
    test "new/2 creates HLS segment struct" do
      assert %Segment{} = segment = Segment.new(@valid_segment.src, @valid_segment.duration)
      assert segment.duration == @valid_segment.duration
      assert segment.src == @valid_segment.src
    end

    test "to_string/1 returns segment tags" do
      segment = Segment.new(@valid_segment.src, @valid_segment.duration)

      expected = """
      #EXTINF:9.0
      https://example.com/vod/2.ts
      """

      assert Segment.to_string(segment) =~ expected
    end
  end
end
