defmodule Servy.FourOhFourCounter do
  # Client
  def start(initial \\ %{}) do
    Agent.start(fn -> initial end, name: __MODULE__)
  end

  defp update_url_count(url_map, url) do
    current_count = Map.get(url_map, url, 0)
    url_map |> Map.put(url, current_count + 1)
  end

  def bump_count(url_path) do
    Agent.update(__MODULE__, &update_url_count(&1, url_path))
  end

  def get_count(url_path) do
    Agent.get(__MODULE__, fn state -> Map.get(state, url_path, 0) end)
  end

  def get_counts() do
    Agent.get(__MODULE__, fn state -> state end)
  end
end
