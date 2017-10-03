defmodule VideoChat.Router do
  use Plug.Router
  import VideoChat.Template
  alias VideoChat.Encoding.FileSupervisor, as: FileSupervisor

plug Plug.Static,
  at: "/public",
  from: :video_chat
plug :match
plug :dispatch

  def init(options) do
    options
  end

  def start_link(_type, _args) do
    {:ok, _} = Plug.Adapters.Cowboy.http VideoChat.Router, []
  end

  get "/" do
    # {:ok, _pid1} = FileSupervisor.start_link(name: :file_encoding_supervisor_1, workers: 3, path: "tmp/video.mp4")

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, render("live"))
  end

  # Should pick a public channel to broadcast HLS from file, not from memory.
  # Get live stream from the bucket
  # get "/live.mp4" do
  #   video_raw = VideoChat.Encoding.Encoder.get_one(nil, 0) |> Enum.reverse |> Enum.join
  #
  #   IO.puts "---> Live mp4 video from the bucket #{byte_size(video_raw)}"
  #
  #   conn
  #   |> put_resp_content_type("video/mp4")
  #   |> put_resp_header("Accept-Ranges", "bytes")
  #   |> send_resp(206, video_raw)
  # end

  post "/upload" do
    case read_body(conn) do
      {:ok, _file_data, _} ->

        # TODO: Extract each file data and write to the uploads folder,
        #   then send the location or binary to the encoder.
        # File.write("tmp/uploaded-video.mp4", file_data, [:binary])


        FileSupervisor.start_link(name: :file_encoding_supervisor_1,
          workers: 1)

        conn
        |> put_resp_header("Location", "/")
        |> send_resp(301, "")

      {:error, _term} ->
        conn
        |> send_resp(500, "Error uploading the file")

      _ ->
        conn
        |> send_resp(500, "Unknown error")
    end
  end

  # Encode video on demand.
  # Should not start another task if the file is encoded
  get "/playlists" do
    # Start encoding the video
    # cmd = "bin/create_sequence tmp/The.Wolf.of.Wall.Street.2013.BluRay.mp4"
    cmd = "bin/create_sequence tmp/video.mp4"
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
  get "/playlists/:slug" do
    # Check the file extension
    ext = slug
      |> String.split(".")
    |> List.last

    video_file = case ext do
      "m3u8" -> "/ts/#{streaming_resolution(conn)}.m3u8"
      "ts" -> "/ts/#{slug}"
      _ -> "/ts/#{streaming_resolution(conn)}.m3u8"
    end

    # file_path = Path.join(System.cwd, video_file)
    file_path = System.cwd
      |> Path.join(Application.get_env(:video_chat, :media_directory))
      |> Path.join(video_file)
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
  get "/media/:file_name" do
    matched = ~r(^[a-zA-Z0-9]+[\\.][a-zA-Z0-9]{2,4}$)
      |> Regex.match?(file_name)
    ext = (file_name
      |> String.split("."))
        |> List.last

    case matched && ext do
      "mp4" -> stream_video_file(conn, file_name)
      "jpg" -> serve_image(conn, file_name)
      "png" -> serve_image(conn, file_name)
      _ -> send_resp(404)
    end
  end

  # Live stream from the webcam or UDP connection/client.
  get "/videos/live/playlist" do
    # TODO: Parse the packets.
    IO.inspect "---> Getting live video stream"

    # video = VideoChat.Encoding.Encoder.get_one |> List.last
    file_path = Path.join(System.cwd, "tmp/webcam/live.m3u8")
    offset = get_offset(conn.req_headers)
    size = get_file_size(file_path)

    conn
    |> put_resp_content_type("application/vnd.apple.mpegurl")
    |> put_resp_header("Accept-Ranges", "bytes")
    |> put_resp_header("Content-Length", "#{size}")
    |> put_resp_header("Content-Range", "bytes #{offset}-#{size-1}/#{size}")
    # |> send_resp(206, playlist_file)
    |> send_file(206, file_path, offset, size-offset)
  end

  # Stream each segment in a sequence.
  # Get called from the video player
  get "/videos/live/:ts" do
    file_path = Path.join(System.cwd, "tmp/webcam/#{ts}")
    IO.inspect file_path

    conn
    |> put_resp_content_type("application/vnd.apple.mpegurl")
    |> put_resp_header("Accept-Ranges", "bytes")
    |> send_file(206, file_path)
  end

  match _ do
    conn
    |> send_resp(404, "Page not found")
  end

  # Stream a video file on demand
  defp stream_video_file(conn, file_name) do
    file_path = System.cwd
      |> Path.join(Application.get_env(:video_chat, :media_directory))
      |> Path.join(file_name)
    offset = get_offset(conn.req_headers)
    size = get_file_size(file_path)

    conn
    |> put_resp_content_type("application/vnd.apple.mpegurl")
    |> put_resp_header("Accept-Ranges", "bytes")
    |> put_resp_header("Content-Length", "#{size}")
    |> put_resp_header("Content-Range", "bytes #{offset}-#{size-1}/#{size}")
    |> send_file(206, file_path, offset, size-offset)
  end

  # Stream an image, totally pointless
  defp serve_image(conn, file_name) do
    file_path = System.cwd
      |> Path.join(Application.get_env(:video_chat, :media_directory))
      |> Path.join(file_name)
    size = get_file_size(file_path)

    conn
    |> put_resp_content_type("application/jpg")
    |> put_resp_header("Accept-Ranges", "bytes")
    |> put_resp_header("Content-Length", "#{size}")
    |> send_file(206, file_path)
  end

  # Get the file size from a path
  defp get_file_size(path) do
    {:ok, %{size: size}} = File.stat path
    size
  end

  # Extract the playback offset from the request headers
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

  defp streaming_resolution(conn) do
    case fetch_query_params(conn).params["vq"] do
      "l" -> "320x180"
      "s" -> "480x270"
      "m" -> "640x360"
      "h" -> "1280x720"
      _ -> "480x270"
    end
  end

  # No skipping
  # defp playlist_file do
  #   '
  #     #EXTM3U
  #     #EXT-X-TARGETDURATION:10
  #     #EXT-X-VERSION:3
  #     #EXT-X-MEDIA-SEQUENCE:0
  #     #EXTINF:11.323222,
  #     /videos/live/320x1800.ts
  #     #EXTINF:9.000000,
  #     /videos/live/320x1801.ts
  #     #EXTINF:7.300000,
  #     /videos/live/320x1802.ts
  #     #EXTINF:8.800000,
  #     /videos/live/320x1803.ts
  #   '
  # end

end
