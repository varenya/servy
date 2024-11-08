defmodule Servy.HttpClient do
  def send_request(request) do
    # to make it runnable on one machine
    some_host_in_net = ~c"localhost"

    {:ok, socket} =
      :gen_tcp.connect(some_host_in_net, 4000, [:binary, packet: :raw, active: false])

    :ok = :gen_tcp.send(socket, request)

    response =
      case :gen_tcp.recv(socket, 0) do
        {:ok, response} -> response
        {:error, reason} -> IO.inspect(reason)
      end

    :ok = :gen_tcp.close(socket)
    response
  end
end
