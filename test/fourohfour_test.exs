defmodule FourOhFourCounterTest do
  use ExUnit.Case

  alias Servy.FourOhFourCounter, as: Counter

  setup_all do
    Counter.start()
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
  end

  test "reset count should make the state empty map" do
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
