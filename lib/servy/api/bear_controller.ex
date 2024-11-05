defmodule Servy.Api.BearController do
  alias Servy.Wildthings

  def index(conv) do
    json = Wildthings.list_bears() |> Poison.encode!()
    %{conv | resp_body: json, resp_content_type: "application/json", status: 200}
  end
end
