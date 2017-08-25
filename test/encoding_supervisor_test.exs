defmodule EncodingSupervisorTest do
  use ExUnit.Case
  doctest VideoChat

  test "should start a worker" do
    pid = Process.whereis(:encoding_supervisor)
    assert pid != nil
    %{active: active,
      specs: _specs,
      supervisors: _supervisors,
      workers: _workers} = Supervisor.count_children(pid)

    assert active > 0
    IO.puts "---> Active children: #{active}"
  end

end
