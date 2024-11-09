defmodule Servy.UserApi do
  def get_user(id) when is_integer(id) do
    url = "https://jsonplaceholder.typicode.com/users/#{Integer.to_string(id)}"
    response = HTTPoison.get(url)
    handle_response(response)
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    city = body |> Poison.Parser.parse!(%{}) |> get_in(["address", "city"])
    {:ok, city}
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: status, body: _body}}) do
    {:error, "Unknown error #{status}"}
  end

  defp handle_response(%HTTPoison.Error{id: nil, reason: reason}), do: {:error, reason}
end
