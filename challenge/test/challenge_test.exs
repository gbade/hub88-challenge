defmodule ChallengeTest do
  use ExUnit.Case
  doctest Challenge

  alias Challenge.{Server, Supervisor}

  describe "start/0" do
    test "starts the supervisor" do
      {:ok, pid} = Challenge.start()

      assert pid != nil
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
end
