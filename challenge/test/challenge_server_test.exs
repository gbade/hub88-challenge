defmodule ChallengeServerTest do
  use ExUnit.Case
  use GenServer
  doctest Challenge.Server

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
end
