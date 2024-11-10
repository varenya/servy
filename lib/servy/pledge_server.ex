defmodule Servy.PledgeServer do
  @name :pledge_server

  # Client Side
  def start do
    pid = spawn(__MODULE__, :listen_loop, [[]])
    Process.register(pid, @name)
    pid
  end

  def create_pledge(name, value) do
    send(@name, {self(), :create_pledge, name, value})

    receive do
      {:response, pledge_id} -> pledge_id
    end
  end

  def recent_pledges do
    send(@name, {self(), :recent_pledge})

    receive do
      {:response, value} -> value
    end
  end

  def total_pledge() do
    send(@name, {self(), :total_pledge})

    receive do
      {:response, total} -> total
    end
  end

  # Server
  def listen_loop(state) do
    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, pledge_id} = send_create_pledge(name, amount)
        most_recent_pledges = Enum.take(state, 2)
        new_state = [{name, amount} | most_recent_pledges]
        send(sender, {:response, pledge_id})
        listen_loop(new_state)

      {sender, :recent_pledge} ->
        send(sender, {:response, state})
        listen_loop(state)

      {sender, :total_pledge} ->
        total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
        send(sender, {:response, total})
        listen_loop(state)

      unexpected_message ->
        IO.puts("Unexpected message : #{inspect(unexpected_message)}")
        listen_loop(state)
    end
  end

  defp send_create_pledge(_name, _value) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end
