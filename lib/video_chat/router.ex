defmodule VideoChat.Router do
  use Plug.Router
  import VideoChat.Template

  plug :match
  plug :dispatch

  def init(options) do
    options
  end

  def start_link(_type, _args) do
    {:ok, _} = Plug.Adapters.Cowboy.http VideoChat.Router, []
  end

  # Render a page with a player
  get "/" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, render("live"))
  end

  # Encode video on demand.
  # Should not start another task if the file is encoded
  get "/playlists" do
    # Start encoding the video
    cmd = "bin/create_sequence tmp/The.Wolf.of.Wall.Street.2013.BluRay.mp4"
    port = Port.open({:spawn, cmd}, [:eof])

    receive do
      {^port, {:data, res}} ->
        IO.puts "Reading data #{IO.inspect res}"

        # Rediredct to the video
        conn
        |> put_resp_header("Location", "/playlists/1")
        |> send_resp(301, "")
    end

  end

  # Returns a playlist file (m3u8), then redirect to the ts file
  # /playlists/playlist-file-name.m3u8
  #
  # GET /playlists/:slug
  get "/playlists/:slug" do
    # Check the file extension
    ext = slug
      |> String.split(".")
    |> List.last

    video_file = cond do
      ext == "m3u8" -> "tmp/ts/320x180.m3u8"
      ext == "ts" -> "tmp/ts/#{slug}"
      true -> "tmp/ts/320x180.m3u8"
    end

    file_path = Path.join(System.cwd, video_file)
    offset = get_offset(conn.req_headers)
    size = get_file_size(file_path)

    conn
    |> put_resp_content_type("application/vnd.apple.mpegurl")
    |> put_resp_header("Accept-Ranges", "bytes")
    |> put_resp_header("Content-Length", "#{size}")
    |> put_resp_header("Content-Range", "bytes #{offset}-#{size-1}/#{size}")
    |> send_file(206, file_path, offset, size-offset)
  end

  # Stream the video, enable seek and skip bytes.
  get "/videos/stream" do
    # video_file = "videos/2.m4v"
    video_file = "/tmp/video.mp4"
    file_path = Path.join(System.cwd, video_file)
    offset = get_offset(conn.req_headers)
    size = get_file_size(file_path)


    conn
    # |> put_resp_content_type("video/mp4")
    |> put_resp_content_type("application/vnd.apple.mpegurl")
    |> put_resp_header("Accept-Ranges", "bytes")
    |> put_resp_header("Content-Length", "#{size}")
    |> put_resp_header("Content-Range", "bytes #{offset}-#{size-1}/#{size}")
    |> send_file(206, file_path, offset, size-offset)
  end

  # Live stream from the webcam or UDP connection.
  get "/videos/live" do
    IO.inspect "---> Getting live video stream"

    # IO.inspect VideoChat.EncodingBucket.get
    video = hd(VideoChat.EncodingBucket.get)
    # video = Enum.map_join(
    #   VideoChat.EncodingBucket.get,
    #   fn b ->
    #     b
    #   end
    # )
    # This will remove the data from all of the consumer, resulting in
    #   unstable stream.
    # video = VideoChat.EncodingBucket.pop
    IO.inspect byte_size(video)
    IO.inspect video

    conn
    # |> put_resp_content_type("video/mp4")
    |> put_resp_content_type("application/vnd.apple.mpegurl")
    |> put_resp_header("Accept-Ranges", "bytes")
    |> send_resp(200, video)
  end

  # Create a playlist for the live stream
  get "/videos/live/playlist" do
    IO.inspect "---> Getting live playlist file"

    video_file = Path.join(System.cwd, "tmp/webcam/live.m3u8")

    conn
    |> put_resp_content_type("application/vnd.apple.mpegurl")
    |> put_resp_header("Accept-Ranges", "bytes")
    # |> send_resp(206, playlist_file)
    |> send_file(200, video_file)
  end

  # Test the bucket
  get "/bucket" do
    IO.inspect "---> Get /bucket"
    IO.inspect VideoChat.EncodingBucket.get

    conn
    |> send_resp(200, "Yes")
  end

  match _ do
    conn
    |> send_resp(404, "Not found")
  end

  #
  # Helpers
  #

  defp get_file_size(path) do
    {:ok, %{size: size}} = File.stat path

    size
  end

  defp get_offset(headers) do
    case List.keyfind(headers, "range", 0) do
    {"range", "bytes=" <> start_pos} ->
      String.split(start_pos, "-")
        |> hd
        |> String.to_integer
    nil ->
      0
    end
  end

  # No skipping
  defp playlist_file(name \\ :default) do
    f = "
      #EXTM3U
      #EXT-X-TARGETDURATION:10
      #EXT-X-VERSION:3
      #EXT-X-MEDIA-SEQUENCE:0
      /videos/live
    "
    video = hd(VideoChat.EncodingBucket.get)
  end

end
