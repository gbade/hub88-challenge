defmodule Challenge.User do
  use GenServer

  # Define the structure for user data
  defstruct currency: "USD", amount: 100_000

  # Start the GenServer
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # Initialize the GenServer with an empty state
  def init(initial_state) do
    {:ok, initial_state}
  end

  # Handle calls to create users
  def handle_cast({:create_users, users}, _from, state) do
    new_state = Enum.reduce(users, state, fn user, acc ->
      if user != "" and not Map.has_key?(acc, user) do
        Map.put(acc, user, %Challenge.User{currency: "USD", amount: 100_000})
      else
        Map.put(acc, user, %{"currency" => "USD", "amount" => 100_000})
      end
    end)

    {:reply,  new_state}
  end

  # Handle the bet transaction
  def handle_call({:bet, %{user: user, amount: amount}}, _from, state) do
    case state |> Map.fetch(user) do
      {:ok, %{amount: user_amount} = user_data} when user_amount >= amount ->
        # Update user balance
        new_user_data = %{user_data | amount: user_amount - amount}
        new_state = Map.put(state, user, new_user_data)
        {:reply, %{status: :ok, message: "Bet placed", new_balance: new_user_data.amount}, new_state}

      {:ok, _} ->
        {:reply, %{status: :error, message: "Insufficient funds"}, state}

      :error ->
        {:reply, %{status: :error, message: "User not found"}, state}
    end
  end

  # Handle the win transaction
  def handle_call({:win, %{user: user, amount: amount}}, _from, state) do
    case state |> Map.fetch(user) do
      {:ok, %{amount: user_amount} = user_data} ->
        # Update user balance
        new_user_data = %{user_data | amount: user_amount + amount}
        new_state = Map.put(state, user, new_user_data)
        {:reply, %{status: :ok, message: "Win recorded", new_balance: new_user_data.amount}, new_state}

      :error ->
        {:reply, %{status: :error, message: "User not found"}, state}
    end
  end
end
