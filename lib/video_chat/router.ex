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

  #
  # GET /playlists/:slug
  #
  # Return a playlist file
  #
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

  # Accept video stream
  post "/videos/stream" do


    # stream to the clients
    conn
    |> send_resp(200, "Wait")
  end

  # Stream video
  get "/videos/live" do
    video_file = "videos/2.m4v"
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

  # Live stream of incoming data from webcam
  get "/stream/live" do
    # Create protocol communcation
    # video_fifo = System.cwd <> "/tmp/video.pipe"
    video_fifo = System.cwd <> "/tmp/video-1.tmp"

    # :erlang.open_port(video_fifo, [EOF])
    cmd = "cat #{video_fifo}"
    # port = Port.open({:spawn, cmd}, [:binary])
    # port = Port.open({:spawn, cmd}, [:eof]))

    port = Port.open({:spawn, cmd}, [:eof])

    #
    #   Should create a playlist with time sequence files
    #

    # Respond with data
    receive do
      {^port, {:data, res}} ->
        IO.puts "Reading data #{IO.inspect res}"

        conn
        # |> put_resp_content_type("video/mp4")
        |> put_resp_content_type("application/vnd.apple.mpegurl")
        |> send_file(206, video_fifo)
    end

    # Port.open({:spawn, cmd}, [:eof])
    #   |> wait_for_data

    #
    #   Original video file
    #

    # video_file = "videos/video.mp4"
    # file_path = Path.join(System.cwd, video_file)
    # offset = get_offset(conn.req_headers)
    # size = get_file_size(file_path)


    # conn
    # # |> put_resp_content_type("video/mp4")
    # |> put_resp_content_type("application/vnd.apple.mpegurl")
    # |> send_file(206, file_path, offset, size-offset)
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

  def wait_for_data(port) do
    receive do
      {^port, {:data, res}} ->
        IO.puts "Reading data #{IO.inspect res}"
    end
  end

end
