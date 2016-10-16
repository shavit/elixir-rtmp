defmodule VideoChat.Server do
  def init(opts) do
    {:ok,
      Plug.Adapters.Cowboy.child_spec(:http,
        VideoChat.Router,
        opts,
        [port: 4001])}
  end

end
