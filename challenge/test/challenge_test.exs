defmodule ChallengeTest do

  use ExUnit.Case
  use GenServer
  doctest Challenge

  # setup_all do
  #   server_pid = Challenge.start()
  #   server_pid
  # end

  describe "start/1" do
    test "starts the supervisor" do
      pid = Challenge.start()

      assert pid != nil
      assert is_pid(pid)
      assert Process.alive?(pid)
    end
  end

  describe "init/1" do
    test "initializes the supervisor with one_for_one strategy and the server child" do
      pid = Challenge.start()
      children_spec = Supervisor.which_children(pid)

      assert length(children_spec) == 1
    end
  end

  describe "create_users/2" do
    test "create_users adds new users with default currency and amount" do
      server_pid = Challenge.start()

      Challenge.create_users(server_pid, ["user1", "user2", "user3"])

      assert Map.keys(GenServer.call(server_pid, {:get_state, self()})) == ["user1", "user2", "user3"]
      assert Map.values(GenServer.call(server_pid, {:get_state, self()})) == [
        %{currency: "USD", amount: 100_000},
        %{currency: "USD", amount: 100_000},
        %{currency: "USD", amount: 100_000}
      ]
    end

    # test "create_users ignores empty string or existing users" do
    #   server = Supervisor.which_children(Challenge.Supervisor)
    #   server_pid = List.first(server)[:pid]

    #   # Add existing user
    #   Server.update_state(server_pid, %{"existing_user" => %{currency: "USD", amount: 50_000}})

    #   # Call create_users with existing and empty users
    #   Challenge.create_users(server_pid, ["existing_user", ""])

    #   assert Map.keys(Server.get_state(server_pid)) == ["existing_user"]
    #   assert Map.values(Server.get_state(server_pid)) == [%{currency: "USD", amount: 50_000}]
    # end
  end
end
