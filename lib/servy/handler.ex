defmodule Servy.Handler do
  import Servy.Plugins, only: [rewrite_path: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [get_page: 1, handle_file: 2]

  @status_message_map %{
    200 => "OK",
    201 => "Created",
    401 => "Unauthorized",
    403 => "Forbidden",
    404 => "Not Found",
    500 => "Internal Server Error"
  }

  def handle(request) do
    request |> parse() |> rewrite_path() |> route() |> track() |> format_response()
  end

  def route(%{method: "GET", path: "/wildlife"} = conv) do
    %{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(%{method: "GET", path: "/bears"} = conv) do
    %{conv | resp_body: "Teddy, Smokey, Paddington", status: 400}
  end

  def route(%{method: "GET", path: "/bears/new"} = conv) do
    get_page("form.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%{method: "GET", path: "/bears/" <> id} = conv) do
    %{conv | resp_body: "Bear #{id}", status: 400}
  end

  def route(%{method: "DELETE", path: "/bears/" <> id} = conv) do
    %{conv | resp_body: "Deleting a bear #{id} is forbidden", status: 403}
  end

  def route(%{method: "GET", path: "/pages/" <> filename} = conv) do
    get_page(filename <> ".html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%{method: "GET", path: "/about"} = conv) do
    get_page("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%{path: path} = conv) do
    %{conv | resp_body: "No #{path} here!", status: 404}
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    @status_message_map[code]
  end
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /pages/contact HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /pages/faq HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))
