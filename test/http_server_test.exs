defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpClient

  setup_all do
    pid = spawn(Servy.HttpServer, :start, [4000])
    on_exit(fn -> Process.exit(pid, :normal) end)
    :ok
  end

  test "http server request for /api/bears" do
    request = """
    GET /api/bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = HttpClient.send_request(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Type: application/json\r
    Content-Length: 605\r
    \r
    [{"hibernating":true,"type":"Brown","name":"Teddy","id":1},
     {"hibernating":false,"type":"Black","name":"Smokey","id":2},
     {"hibernating":false,"type":"Brown","name":"Paddington","id":3},
     {"hibernating":true,"type":"Grizzly","name":"Scarface","id":4},
     {"hibernating":false,"type":"Polar","name":"Snow","id":5},
     {"hibernating":false,"type":"Grizzly","name":"Brutus","id":6},
     {"hibernating":true,"type":"Black","name":"Rosie","id":7},
     {"hibernating":false,"type":"Panda","name":"Roscoe","id":8},
     {"hibernating":true,"type":"Polar","name":"Iceman","id":9},
     {"hibernating":false,"type":"Grizzly","name":"Kenai","id":10}]
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  defp remove_whitespace(text) do
    String.replace(text, ~r{\s}, "")
  end
end
