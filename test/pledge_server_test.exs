defmodule PledgeServerTest do
  use ExUnit.Case
  alias Servy.PledgeServer

  setup_all %{} do
    {:ok, pid} = PledgeServer.start_link([])
    on_exit(fn -> Process.exit(pid, :normal) end)
    :ok
  end

  test "pledge server should hold only 3 recent pledges" do
    PledgeServer.create_pledge("larry", 10)
    PledgeServer.create_pledge("moe", 20)
    PledgeServer.create_pledge("jack", 30)
    PledgeServer.create_pledge("jim", 30)

    assert length(PledgeServer.recent_pledges()) == 3
  end

  test "total pledge should be sum of recent pledges" do
    PledgeServer.create_pledge("moe", 20)
    PledgeServer.create_pledge("jack", 30)
    PledgeServer.create_pledge("jim", 30)
    assert PledgeServer.total_pledge() == 80
  end
end
