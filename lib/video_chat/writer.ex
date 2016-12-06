#
# Testing module
#
defmodule VideoChat.Writer do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    {{_year,_month,_day},{h,m,s}} = :calendar.local_time
    System.cmd("sh", ["bin/read_string", "[#{h}:#{m}:#{s}] Started from Eixir"])

    {:ok, System.get_pid}
  end
end
