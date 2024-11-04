defmodule Servy.BearController do
  alias Servy.Conv
  alias Servy.Wildthings
  alias Servy.Bear
  alias Servy.BearView

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_by_asc_name/2)

    content = BearView.index(bears)
    BearView.render(conv, content)
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    BearView.render(conv, BearView.show(bear))
  end

  def create(conv, %{"type" => type, "name" => name}) do
    %Conv{
      conv
      | resp_body: "Created a #{type} bear named #{name}!",
        status: 201
    }
  end
end
