defmodule ChallengeTest do
  use ExUnit.Case
  use GenServer
  doctest Challenge

  # alias Challenge.{Server, Supervisor}

  describe "start/1" do
    test "starts the supervisor" do
      pid = Challenge.start()

      assert pid != nil
      assert is_pid(pid)
      assert Process.alive?(pid)
    end
  end

  describe "start_link/1" do
    test "starts the supervisor" do
      {:ok, pid} = Challenge.Supervisor.start_link([])

      assert {:ok, _} = {:ok, pid}

      assert Process.alive?(pid)
    end
  end

  describe "handle_call/3 for bes placed" do
    test "places a bet successfully" do
      state = %{"user1" => %{amount: 200_000}}
      amount = 50_000

      {:reply, %{status: :ok, message: "Bet placed", new_balance: new_balance}, new_state} =
        Challenge.Server.handle_call({:bet, %{user: "user1", amount: amount}}, nil, state)

      assert new_balance == 150_000
      assert new_state == %{"user1" => %{amount: 150_000}}
    end

    test "handles insufficient funds" do
      state = %{"user1" => %{amount: 20_000}}
      amount = 50_000

      {:reply, %{status: :error, message: "Insufficient funds"}, new_state} =
        Challenge.Server.handle_call({:bet, %{user: "user1", amount: amount}}, nil, state)

      assert new_state == state
    end

    test "handles user not found" do
      state = %{}
      amount = 50_000

      {:reply, %{status: :error, message: "User not found"}, new_state} =
        Challenge.Server.handle_call({:bet, %{user: "user1", amount: amount}}, nil, state)

      assert new_state == state
    end
  end

  describe "handle_call/3 for win transactions" do
    test "records a win successfully" do
      state = %{"user1" => %{amount: 100_000}}
      amount = 50_000

      {:reply, %{status: :ok, message: "Win recorded", new_balance: new_balance}, new_state} =
        Challenge.Server.handle_call({:win, %{user: "user1", amount: amount}}, nil, state)

      assert new_balance == 150_000
      assert new_state == %{"user1" => %{amount: 150_000}}
    end

    test "handles user not found for win transaction" do
      state = %{}
      amount = 50_000

      {:reply, %{status: :error, message: "User not found"}, new_state} =
        Challenge.Server.handle_call({:win, %{user: "user1", amount: amount}}, nil, state)

      assert new_state == state
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

  describe "create_users/2" do
    test "creates non-existing users with currency as USD and amount as 100,000" do
      server = start_server()

      Challenge.create_users(server, ["user1", "user2", "user3", "user1", ""])

      :timer.sleep(500)

      assert user_exists?(server, "user1")
      assert user_exists?(server, "user2")
      assert user_exists?(server, "user3")
      refute user_exists?(server, "")
    end
  end

  describe "bet/2" do
    test "sends a bet transaction to the server" do
      server = start_server()

      response = Challenge.bet(server, %{user: "user1", amount: 100})

      # Simulate some delay to allow the cast message to be processed
      :timer.sleep(500)

      assert response == %{}
    end
  end

  # Helper function to start the GenServer
  defp start_server do
    pid = Challenge.start()
    pid
  end

  # Helper function to check if a user exists in the server state
  defp user_exists?(server, user) do
    GenServer.call(server, {:user_exists?, user})
  end
end
