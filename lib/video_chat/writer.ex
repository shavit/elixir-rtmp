defmodule VideoChat.Writer do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    # For debugging
    # Log using a different process
    {{_year,_month,_day},{h,m,s}} = :calendar.local_time
    System.cmd("sh", ["bin/read_string", "[#{h}:#{m}:#{s}] Started from Eixir"])

    # Listen to incoming streams on 3002
    System.cmd(Path.join([System.cwd, "bin", "read_hls"]), ["-v"])

    {:ok, System.get_pid}
  end
end
