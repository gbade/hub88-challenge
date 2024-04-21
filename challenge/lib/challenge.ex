defmodule Challenge do
  use GenServer

  @doc """
    Start a linked and isolated supervision tree and return the root server that
    will handle the requests.
  """
  @spec start :: GenServer.server()
  def start do
    {:ok, supervisor_pid} = Challenge.Supervisor.start_link([])
    supervisor_pid
  end

  @doc """
    Create non existing users with currency as "USD" and amount as 100,000
    It must ignore empty binary `""` or if the user already exists.
  """
  @spec create_users(server :: GenServer.server(), users :: [String.t()]) :: :ok
  def create_users(server, users) do
   GenServer.cast(server,{:create_users, users})
   :ok
  end

  @doc """
    The same behavior is from `POST /transaction/bet` docs.

    The `body` parameter is the "body" from the docs as a map with keys as atoms.
    The result is the "response" from the docs as a map with keys as atoms.
  """
  @spec bet(server :: GenServer.server(), body :: map) :: map
  def bet(server, body) do
    GenServer.cast(server, {:bet, body})
  end

  @doc """
    The same behavior is from `POST /transaction/win` docs.

    The `body` parameter is the "body" from the docs as a map with keys as atoms.
    The result is the "response" from the docs as a map with keys as atoms.
  """
  @spec win(server :: GenServer.server(), body :: map) :: map
  def win(server, body) do
    GenServer.cast(server, {:win, body})
  end
end
