defmodule Servy.SensorServer do
  use GenServer
  alias Servy.VideoCam

  @name :sensor_server

  defmodule State do
    defstruct sensor_data: %{}, duration: :timer.seconds(5)
  end

  def start do
    GenServer.start(__MODULE__, %State{}, name: @name)
  end

  def get_snapshots do
    GenServer.call(@name, :get_snapshots)
  end

  def set_refresh_interval(duration) do
    GenServer.cast(@name, {:set_refresh_interval, duration})
  end

  def init(state) do
    new_state = %{state | sensor_data: update_snapshot_cache()}
    refresh_cache(new_state.duration)
    {:ok, new_state}
  end

  def handle_call(:get_snapshots, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:set_refresh_interval, duration}, state) do
    new_state = %{state | duration: duration}
    {:noreply, new_state}
  end

  def handle_info(:refresh, state) do
    new_state = %{state | sensor_data: update_snapshot_cache()}
    refresh_cache(new_state.duration)
    {:noreply, new_state}
  end

  defp refresh_cache(duration) do
    Process.send_after(self(), :refresh, duration)
  end

  def update_snapshot_cache do
    IO.puts("Updating snapshot cache...")
    task = Task.async(Servy.Tracker, :get_location, ["bigfoot"])

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(VideoCam, :get_snapshot, [&1]))
      |> Enum.map(&Task.await/1)

    bigfoot = Task.await(task)
    %{snapshots: snapshots, location: bigfoot}
  end
end
