defmodule Servy.GenericServer do
  def start(module_name, initial_state, name) do
    pid = spawn(__MODULE__, :listen_loop, [initial_state, module_name])
    Process.register(pid, name)
    pid
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, response} ->
        response
    end
  end

  def listen_loop(state, module_name) do
    receive do
      {:call, sender, message} ->
        {response, new_state} = module_name.handle_call(message, state)
        send(sender, {:response, response})
        listen_loop(new_state, module_name)

      {:cast, message} ->
        new_state = module_name.handle_cast(message, state)
        listen_loop(new_state, module_name)

      other ->
        new_state = module_name.handle_info(other, state)
        listen_loop(new_state, module_name)
    end
  end
end

defmodule Servy.PledgeServer do
  alias Servy.GenericServer

  @name :pledge_server

  def start(initial_state \\ []) do
    IO.puts("Starting the pledge server......")
    GenericServer.start(__MODULE__, initial_state, @name)
  end

  def create_pledge(name, value) do
    GenericServer.call(@name, {:create_pledge, name, value})
  end

  def recent_pledges do
    GenericServer.call(@name, :recent_pledge)
  end

  def total_pledge() do
    GenericServer.call(@name, :total_pledge)
  end

  def clear_pledges do
    GenericServer.cast(@name, :clear_pledges)
  end

  # Server

  def handle_cast(:clear_pledges, _state) do
    []
  end

  def handle_info(unexpected_message, state) do
    IO.puts("Unexpected message : #{inspect(unexpected_message)}")
    state
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, pledge_id} = send_create_pledge(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [{name, amount} | most_recent_pledges]
    {pledge_id, new_state}
  end

  def handle_call(:total_pledge, state) do
    total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
    {total, state}
  end

  def handle_call(:recent_pledge, state) do
    {state, state}
  end

  defp send_create_pledge(_name, _value) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

alias Servy.PledgeServer

pid = PledgeServer.start()

send(pid, {:stop, "hammertime"})

IO.inspect(PledgeServer.create_pledge("larry", 10))
IO.inspect(PledgeServer.create_pledge("moe", 20))
IO.inspect(PledgeServer.create_pledge("curly", 30))
IO.inspect(PledgeServer.create_pledge("daisy", 40))
IO.inspect(PledgeServer.create_pledge("grace", 50))

IO.inspect(PledgeServer.recent_pledges())

IO.inspect(PledgeServer.total_pledge())

PledgeServer.clear_pledges()
IO.inspect(PledgeServer.total_pledge())
