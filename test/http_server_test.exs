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
    max_concurrent_requests = 5

    tasks =
      for _ <- 1..max_concurrent_requests do
        Task.async(fn ->
          HTTPoison.get("#{@url}/wildthings")
        end)
      end

    for task <- tasks do
      {:ok, %HTTPoison.Response{status_code: status, body: body}} = Task.await(task)
      assert status == 200
      assert body == "Bears, Lions, Tigers"
    end
  end

  test "accepts a request from multiple urls on a socket and sends back a response" do
    urls = [
      "http://localhost:4000/wildthings",
      "http://localhost:4000/bears",
      "http://localhost:4000/bears/1",
      "http://localhost:4000/wildlife",
      "http://localhost:4000/api/bears"
    ]

    tasks =
      for url <- urls do
        Task.async(fn ->
          HTTPoison.get(url)
        end)
      end

    for task <- tasks do
      {:ok, %HTTPoison.Response{status_code: status, body: body}} = Task.await(task)
      assert status == 200
    end
  end
end
