defmodule EncodingSupervisorTest do
  use ExUnit.Case
  doctest VideoChat

  test "should start a worker" do
    pid = Process.whereis(:stream_encoding_supervisor)
    assert pid != nil
    %{active: active,
      specs: _specs,
      supervisors: _supervisors,
      workers: _workers} = Supervisor.count_children(pid)

    assert active == 1
  end

end
