defmodule Servy.Conv do
  defstruct method: "", path: "", resp_body: "", status: nil, params: %{}, headers: %{}

  @status_message_map %{
    200 => "OK",
    201 => "Created",
    401 => "Unauthorized",
    403 => "Forbidden",
    404 => "Not Found",
    500 => "Internal Server Error"
  }

  def full_status(conv) do
    "#{conv.status} #{status_reason(conv.status)}"
  end

  defp status_reason(code) do
    @status_message_map[code]
  end
end
