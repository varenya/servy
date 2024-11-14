defmodule FourOhFourCounterTest do
  use ExUnit.Case

  alias Servy.FourOhFourCounter, as: Counter

  setup do
    {:ok, pid} = Counter.start_link([])
    on_exit(fn -> Process.exit(pid, :normal) end)
    :ok
  end

  test "reports counts of missing path requests" do
    Counter.bump_count("/bigfoot")
    Counter.bump_count("/nessie")
    Counter.bump_count("/nessie")
    Counter.bump_count("/bigfoot")
    Counter.bump_count("/nessie")

    assert Counter.get_count("/nessie") == 3
    assert Counter.get_count("/bigfoot") == 2

    assert Counter.get_counts() == %{"/bigfoot" => 2, "/nessie" => 3}
    Counter.reset_count()
    assert Counter.get_counts() == %{}
  end
end
