defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\r\n\r\n", parts: 2)

    [request_line | header_lines] = String.split(top, "\r\n")

    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines)
    params = parse_params(headers["Content-Type"], params_string)

    %Conv{method: method, path: path, params: params, headers: headers}
  end

  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim() |> URI.decode_query()
  end

  def parse_params(_, _), do: %{}

  def parse_headers(header_lines, res \\ %{})

  def parse_headers([head | tail], res) do
    [header_key, header_value] = String.split(head, ": ") |> Enum.map(&String.trim/1)
    parse_headers(tail, Map.put_new(res, header_key, header_value))
  end

  def parse_headers([], res), do: res
end
