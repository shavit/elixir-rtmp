defmodule FileEncoderTest do
  use ExUnit.Case
  import VideoChat.Encoding.FileSupervisor, only: :functions
  doctest VideoChat

  setup %{} do
    {:ok, pid} = start_link(name: :file_encoding_supervisor, workers: 3, path: :random_video)

    %{pid: pid}
  end

  test "should start n supervisor workers", %{pid: pid} do
    %{active: _active,
      specs: _specs,
      supervisors: _supervisors,
      workers: workers} = Supervisor.count_children(pid)

    assert workers == 3
  end

  test "should start multiple different supervisors" do
    assert {:ok, pid1} = start_link(name: :file_encoding_supervisor_1, workers: 3, path: :random_video)
    assert {:ok, pid2} = start_link(name: :file_encoding_supervisor_2, workers: 2, path: :random_video)
    assert {:ok, pid3} = start_link(name: :file_encoding_supervisor_3, workers: 1, path: :random_video)
    assert pid1 != pid2 != pid3
  end

  test "supervisor should start multiple encoding tasks", %{pid: pid} do
    assert {:ok, _pid} = start_child(pid, [id: :one, name: :file_encoding_supervisor_1, path: :random_video, res: :mp4_320])
    assert {:ok, _pid} = start_child(pid, [id: :two, name: :file_encoding_supervisor_1, path: :random_video, res: :mp4_320])
    assert {:ok, _pid} = start_child(pid, [id: :three, name: :file_encoding_supervisor_2, path: :random_video, res: :mp4_320])
    assert {:ok, _pid} = start_child(pid, [id: :four, name: :file_encoding_supervisor_2, path: :random_video, res: :mp4_320])
  end

  test "encode", %{pid: pid} do
    assert {:ok, _pid} = start_child(pid, [id: :encode_one, name: :file_encoding_supervisor_1, path: :random_video, res: :mp4_320])
  end
end
