defmodule Servy.PledgeServer do
  use GenServer
  @name :pledge_server

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  def start_link(_arg) do
    IO.puts("Starting the pledge server......")
    GenServer.start_link(__MODULE__, %State{}, name: @name)
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

  def set_cache_size(size) do
    GenServer.cast(@name, {:set_cache_size, size})
  end

  # Server

  def init(state) do
    initial_pleges = fetch_recent_pledges_from_service()
    new_state = %{state | pledges: initial_pleges}
    {:ok, new_state}
  end

  def handle_cast(:clear_pledges, state) do
    new_state = %{state | pledges: []}
    {:noreply, new_state}
  end

  def handle_cast({:set_cache_size, size}, %State{pledges: pledges} = state) do
    updated_pledges = Enum.take(pledges, size)
    new_state = %{state | cache_size: size, pledges: updated_pledges}
    {:noreply, new_state}
  end

  def handle_call(
        {:create_pledge, name, amount},
        _from,
        %State{cache_size: cache, pledges: pledges} = state
      ) do
    {:ok, pledge_id} = send_create_pledge(name, amount)
    most_recent_pledges = Enum.take(pledges, cache - 1)
    updated_pledges = [{name, amount} | most_recent_pledges]
    new_state = %{state | pledges: updated_pledges}
    {:reply, pledge_id, new_state}
  end

  def handle_call(:total_pledge, _from, %State{pledges: pledges} = state) do
    total = Enum.map(pledges, &elem(&1, 1)) |> Enum.sum()
    {:reply, total, state}
  end

  def handle_call(:recent_pledge, _from, state) do
    {:reply, state.pledges, state}
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
