defmodule Servy do
  use Application

  def start(_type, _args) do
    IO.puts("starting servy application..")
    Servy.Supervisor.start_link()
  end
end
