defmodule Servy.FourOhFourCounter do
  use GenServer
  @name :four_oh_four
  # Client
  def start_link(_arg) do
    IO.puts("Starting 404 server..")
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  def reset_count() do
    GenServer.cast(@name, :reset_count)
  end

  def bump_count(url_path) do
    GenServer.call(@name, {:bump_count, url_path})
  end

  def get_count(url_path) do
    GenServer.call(@name, {:get_count, url_path})
  end

  def get_counts() do
    GenServer.call(@name, :get_counts)
  end

  def handle_cast(:reset_count, _state) do
    {:noreply, %{}}
  end

  def handle_call({:bump_count, url}, _from, state) do
    current_count = Map.get(state, url, 0)
    new_state = state |> Map.put(url, current_count + 1)
    {:reply, :ok, new_state}
  end

  def handle_call(:get_counts, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get_count, url_path}, _from, state) do
    response = Map.get(state, url_path, 0)
    {:reply, response, state}
  end
end
