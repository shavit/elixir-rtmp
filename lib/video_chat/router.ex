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
    |> send_resp(200, "<video autoplay controls><source src=\"/videos/live\" type=\"video/mp4\"/> </video>")
  end

  # get "/playlists/.m3u8" do
  get "/playlists/:slug" do
    IO.inspect slug

    video_file = "tmp/video_stream.mp4"
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

  # The stream from another media server
  get "/stream/live" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, render("live"))
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

end
