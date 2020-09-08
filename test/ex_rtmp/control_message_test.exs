defmodule ExRTMP.ControlMessageTest do
  use ExUnit.Case
  alias ExRTMP.ControlMessage

  describe "control message" do
    test "new/1 creates a new control message" do
      msg = ControlMessage.new([])
      assert is_binary(msg)
    end

    test "client_pinged/2 creates a ping control message" do
      # <<0, 1, 0, 0, 6, 63>>
      csid = 10
      stream_id = 11
      assert <<csid::16, timestamp::8*4>> = ControlMessage.client_pinged(csid, stream_id)
    end

    test "decode/1 decodes a message ping client" do
      msg = <<0, 6, 17, 249, 187, 163>>
      assert %{timestamp: _timestamp, type: :client_pinged} = ControlMessage.decode(msg)
    end

    test "get_type/1 returns control message type" do
      tests = %{
        0x0 => :clear_stream,
        0x01 => :clear_buffer,
        0x02 => :stream_dry,
        0x03 => :client_buffer_time,
        0x04 => :reset_stream,
        0x06 => :client_pinged,
        0x07 => :client_ponged,
        0x08 => :udp_request,
        0x09 => :udp_response,
        0x0A => :bandwidth_limit,
        0x0B => :bandwidth,
        0x0C => :throttle_bandwidth,
        0x0D => :stream_created,
        0x0E => :stream_deleted,
        0x0F => :set_read_access,
        0x10 => :set_write_access,
        0x11 => :stream_meta_request,
        0x12 => :stream_meta_response,
        0x13 => :get_segment_boundary,
        0x14 => :set_segment_boundary,
        0x15 => :on_disconnect,
        0x16 => :set_critical_link,
        0x17 => :disconnect,
        0x18 => :hash_update,
        0x19 => :hash_timeout,
        0x1A => :hash_request,
        0x1B => :hash_response,
        0x1C => :check_bandwidth,
        0x1D => :set_audio_sample_acceses,
        0x1E => :set_video_sample_acceses,
        0x1F => :throttle_begin,
        0x20 => :throttle_end,
        0x21 => :drm_notify,
        0x22 => :rtmfp_sync,
        0x23 => :query_ihello,
        0x24 => :forward_ihello,
        0x25 => :redirect_ihello,
        0x26 => :notify_eof,
        0x27 => :proxy_continue,
        0x28 => :proxy_remove_upstream,
        0x29 => :rtmfp_set_keepalive,
        0x2E => :segment_not_found
      }

      Enum.each(tests, fn {a, b} ->
        assert b == ControlMessage.get_type(a)
      end)
    end
  end
end
