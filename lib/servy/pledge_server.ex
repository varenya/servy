defmodule Servy.PledgeServer do
  use GenServer
  @name :pledge_server

  def start(initial_state \\ []) do
    IO.puts("Starting the pledge server......")
    GenServer.start(__MODULE__, initial_state, name: @name)
  end

  def create_pledge(name, value) do
    GenServer.call(@name, {:create_pledge, name, value})
  end

  def recent_pledges do
    GenServer.call(@name, :recent_pledge)
  end

  def total_pledge() do
    GenServer.call(@name, :total_pledge)
  end

  def clear_pledges do
    GenServer.cast(@name, :clear_pledges)
  end

  # Server

  def init(_state) do
    initial_state = fetch_recent_pledges_from_service()
    {:ok, initial_state}
  end

  def handle_cast(:clear_pledges, _state) do
    {:noreply, []}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, pledge_id} = send_create_pledge(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [{name, amount} | most_recent_pledges]
    {:reply, pledge_id, new_state}
  end

  def handle_call(:total_pledge, _from, state) do
    total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
    {:reply, total, state}
  end

  def handle_call(:recent_pledge, _from, state) do
    {:reply, state, state}
  end

  defp fetch_recent_pledges_from_service do
    # CODE GOES HERE TO FETCH RECENT PLEDGES FROM EXTERNAL SERVICE

    # Example return value:
    [{"wilma", 15}, {"fred", 25}]
  end

  defp send_create_pledge(_name, _value) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

alias Servy.PledgeServer

{:ok, pid} = PledgeServer.start()

IO.inspect(PledgeServer.create_pledge("larry", 10))
IO.inspect(PledgeServer.create_pledge("moe", 20))
IO.inspect(PledgeServer.create_pledge("curly", 30))
IO.inspect(PledgeServer.create_pledge("daisy", 40))
IO.inspect(PledgeServer.create_pledge("grace", 50))

IO.inspect(PledgeServer.recent_pledges())

IO.inspect(PledgeServer.total_pledge())

PledgeServer.clear_pledges()
IO.inspect(PledgeServer.total_pledge())
