defmodule Servy.Api.BearController do
  alias Servy.Wildthings
  alias Servy.Conv

  def index(conv) do
    json = Wildthings.list_bears() |> Poison.encode!()
    %{conv | resp_body: json, status: 200} |> Conv.set_content_type("application/json")
  end

  def create(conv, bear_params) do
    %{
      conv
      | resp_body: "Created a #{bear_params["type"]} bear named #{bear_params["name"]}!",
        status: 201
    }
  end
end
