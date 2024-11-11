defmodule Servy.PledgeController do
  import Servy.PledgeServer, only: [create_pledge: 2, recent_pledges: 0]
  alias Servy.BearView

  def new(conv) do
    BearView.render(conv, BearView.new_pledge())
  end

  def create(conv, %{"name" => name, "amount" => amount}) do
    # Sends the pledge to the external service and caches it
    create_pledge(name, String.to_integer(amount))

    %{conv | status: 201, resp_body: "#{name} pledged #{amount}!"}
  end

  def index(conv) do
    # Gets the recent pledges from the cache
    pledges = recent_pledges()
    content = BearView.recent_pledges(pledges)

    BearView.render(conv, content)
  end
end
