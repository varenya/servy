defmodule Servy.Conv do
  defstruct method: "",
            path: "",
            resp_body: "",
            status: nil,
            params: %{},
            headers: %{},
            resp_headers: %{"Content-Type" => "text/html"}

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

  def set_content_type(conv, content_type) do
    resp_headers = conv.resp_headers |> Map.put("Content-Type", content_type)
    %{conv | resp_headers: resp_headers}
  end

  def content_type(conv) do
    conv.resp_headers["Content-Type"]
  end

  defp status_reason(code) do
    @status_message_map[code]
  end
end
