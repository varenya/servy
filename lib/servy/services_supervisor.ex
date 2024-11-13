defmodule Servy.ServicesSupervisor do
  use Supervisor

  def start_link do
    IO.puts("Starting the services supervisor")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_arg) do
    children = [Servy.PledgeServer, Servy.SensorServer]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
