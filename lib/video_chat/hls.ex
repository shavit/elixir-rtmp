defmodule VideoChat.HLS do
  @moduledoc """
  `VideoChat.HLS` on-demand and live playlists
  """

  # TODO: Add tags
  # TODO: Add versions

  defmodule Segment do
    @moduledoc """
    `VideoChat.HLS.Segment`
    """

    defstruct [
      :duration,
      :src
    ]

    @doc """
    new/2 creates a new segment

    iex> new(https://example.com/vod/1.ts, 11.0)
    %Segment{src: "https://example.com/vod/1.ts", duration: 11.0}
    """
    def new(src, duration) do
      %__MODULE__{src: src, duration: duration}
    end

    @doc """
    to_string/1 creates segment tags for the playlist

    iex> segment = %Segment{
    src: "https://example.com/vod/1.ts", 
    duration: 11.0
    }
    iex> to_string(segment)
    #EXTINF:11.0
    https://example.com/vod/1.ts
    """
    def to_string(%__MODULE__{} = struct) do
      "#EXTINF:#{struct.duration}\n#{struct.src}\n"
    end
  end

  defstruct [
    :version,
    :cache,
    :segments
  ]

  @tag "#EXTM3U"

  @doc """
  new/1 creates a playlist
  """
  def new(_opts) do
    %__MODULE__{
      cache: false,
      segments: [],
      version: 4
    }
  end

  @doc """
  vod/1 creates on-demand playlist
  """
  def vod(_struct) do
    throw("Not implemented")
  end

  @doc """
  live/1 creates a live playlist
  """
  def live(_struct) do
    throw("Not implemented")
  end

  @doc """
  add_segment/2 appends a segment to the end of the segment list

  It will not check for duplications
  """
  def add_segment(%__MODULE__{segments: segments} = struct, %Segment{} = segment) do
    %{
      struct
      | segments: List.insert_at(segments, -1, segment)
    }
  end

  @doc """
  to_string/1 returns the playlist
  """
  def to_string(_struct) do
    """
    #EXT-X-VERSION:4
    #EXT-X-ALLOW-CACHE:NO
    """

    throw("Not implemented")
  end
end
