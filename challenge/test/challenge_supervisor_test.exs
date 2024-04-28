defmodule ChallengeSupervisorTest do
  use ExUnit.Case
  use GenServer
  doctest Challenge.Supervisor

  describe "start_link/1" do
    test "starts the supervisor" do
      {:ok, pid} = Challenge.Supervisor.start_link([])

      assert {:ok, _} = {:ok, pid}

      assert Process.alive?(pid)
    end
  end

  describe "start_link/2" do
    test "starts the supervisor and initializes child process" do
      {:ok, supervisor_pid} = Supervisor.start_link(Challenge.Supervisor, :ok)

      assert supervisor_pid != nil
      assert is_pid(supervisor_pid)
      assert Process.alive?(supervisor_pid)

      children = Supervisor.which_children(supervisor_pid)
      assert length(children) == 1
    end
  end

  describe "init/1" do
    test "initializes the supervisor with one_for_one strategy and the server child" do
      pid = Challenge.start()
      children_spec = Supervisor.which_children(pid)

      assert length(children_spec) == 1
    end
  end
end
