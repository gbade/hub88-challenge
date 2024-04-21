defmodule ChallengeTest do
  use ExUnit.Case
  doctest Challenge

  alias Challenge.{Server, Supervisor}

  setup do
    {:ok, pid} = Supervisor.start_link([])
    {:ok, pid: pid}
  end

  describe "start/0" do
    test "returns pid on success" do
      result = Challenge.start()
      assert is_pid(result)
    end
  end

  test "creating users" do
    server_pid = Supervisor.which_children(@pid)
    # Creating users with empty strings should be ignored
    assert Server.create_users(server_pid, ["user1", "user2", ""]) == :ok
    # Creating duplicate users should be ignored
    assert Server.create_users(server_pid, ["user1", "user2", "user1"]) == :ok
    # Creating users with non-empty strings
    assert Server.create_users(server_pid, ["user3", "user4"]) == :ok
  end
end
