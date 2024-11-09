defmodule HttpServerTest do
  use ExUnit.Case
  alias Servy.Bear

  @url "http://localhost:4000"

  setup_all do
    pid = spawn(Servy.HttpServer, :start, [4000])
    on_exit(fn -> Process.exit(pid, :normal) end)
    :ok
  end

  test "http server request for /api/bears" do
    {:ok, %HTTPoison.Response{status_code: status, body: body}} =
      HTTPoison.get("#{@url}/api/bears")

    bears = Poison.decode!(body, as: [%Bear{}])

    assert status == 200
    assert length(bears) == 10
  end

  test "accepts a request on a socket and sends back a response" do
    parent = self()
    max_concurrent_requests = 5

    for _ <- 1..max_concurrent_requests do
      spawn(fn ->
        {:ok, response} = HTTPoison.get("#{@url}/wildthings")
        send(parent, {:ok, response})
      end)
    end

    for _ <- 1..max_concurrent_requests do
      receive do
        {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
          assert status == 200
          assert body == "Bears, Lions, Tigers"
      end
    end
  end
end
