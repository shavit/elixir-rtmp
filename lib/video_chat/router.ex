defmodule VideoChat.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    conn
    |> send_resp(200, "Hello")
  end

  # Accept video stream
  post "/videos/stream" do
    # stream to the clients
    conn
    |> send_repo(200, "Wait")
  end

  # Stream video
  get "/videos/live" do
    conn
    |> put_resp_content_type("application/octet-stream")
    |> send_resp(200, "ok")
  end

  match _ do
    conn
    |> send_resp(404, "Not found")
  end
end
