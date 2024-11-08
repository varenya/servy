defmodule Servy.Handler do
  import Servy.Plugins, only: [rewrite_path: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [get_page: 1, handle_file: 2]

  alias Servy.BearController
  alias Servy.Conv
  alias Servy.VideoCam

  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    |> route()
    |> track()
    |> put_content_length()
    |> format_response()
  end

  def put_content_length(conv) do
    resp_headers = Map.put(conv.resp_headers, "Content-Length", String.length(conv.resp_body))
    %{conv | resp_headers: resp_headers}
  end

  def route(%Conv{method: "GET", path: "/kaboom"}) do
    raise "Kaboom!"
  end

  def route(%Conv{method: "GET", path: "/snapshots"} = conv) do
    parent = self()
    spawn(fn -> send(parent, {:result, VideoCam.get_snapshot("cam-1")}) end)
    spawn(fn -> send(parent, {:result, VideoCam.get_snapshot("cam-2")}) end)
    spawn(fn -> send(parent, {:result, VideoCam.get_snapshot("cam-3")}) end)

    snapshot1 =
      receive do
        {:result, filename} -> filename
      end

    snapshot2 =
      receive do
        {:result, filename} -> filename
      end

    snapshot3 =
      receive do
        {:result, filename} -> filename
      end

    snapshots = [snapshot1, snapshot2, snapshot3]

    %{conv | status: 200, resp_body: inspect(snapshots)}
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time |> String.to_integer() |> :timer.sleep()
    %Conv{conv | resp_body: "Awake!", status: 200}
  end

  def route(%Conv{method: "GET", path: "/wildlife"} = conv) do
    %Conv{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/api/bears", params: params} = conv) do
    Servy.Api.BearController.create(conv, params)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    get_page("form.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    %Conv{conv | resp_body: "Deleting a bear #{id} is forbidden", status: 403}
  end

  def route(%Conv{method: "POST", path: "/bears", params: params, headers: _headers} = conv) do
    BearController.create(conv, params)
  end

  def route(%Conv{method: "GET", path: "/pages/faq"} = conv) do
    get_page("faq.md")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> filename} = conv) do
    get_page(filename <> ".html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    get_page("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{path: path} = conv) do
    %Conv{conv | resp_body: "No #{path} here!", status: 404}
  end

  def format_response_headers(%Conv{resp_headers: resp_headers}) do
    resp_headers
    |> Enum.map(fn {k, v} -> "#{k}: #{v}\r" end)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end
end

request = """
GET /pages/faq HTTP/1.1\r
Host: example.com\r
User-Agent: ExampleBrowser/1.0\r
Accept: */*\r
\r
"""

resp = Servy.Handler.handle(request)

IO.inspect(resp)

request = """
GET /pages/about HTTP/1.1\r
Host: example.com\r
User-Agent: ExampleBrowser/1.0\r
Accept: */*\r
\r
"""

resp = Servy.Handler.handle(request)

IO.inspect(resp)
