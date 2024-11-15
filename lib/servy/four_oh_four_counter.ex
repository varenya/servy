defmodule Servy.FourOhFourCounter do
  alias Servy.GenericServer
  @name :four_oh_four
  # Client
  def start(initial \\ %{}) do
    GenericServer.start(__MODULE__, initial, @name)
  end

  def reset_count() do
    GenericServer.cast(@name, :reset_count)
  end

  def bump_count(url_path) do
    GenericServer.call(@name, {:bump_count, url_path})
  end

  def get_count(url_path) do
    GenericServer.call(@name, {:get_count, url_path})
  end

  def get_counts() do
    GenericServer.call(@name, :get_counts)
  end

  def handle_cast(:reset_count, _state) do
    %{}
  end

  def handle_call({:bump_count, url}, state) do
    current_count = Map.get(state, url, 0)
    new_state = state |> Map.put(url, current_count + 1)
    {:ok, new_state}
  end

  def handle_call(:get_counts, state) do
    {state, state}
  end

  def handle_call({:get_count, url_path}, state) do
    response = Map.get(state, url_path, 0)
    {response, state}
  end
end
