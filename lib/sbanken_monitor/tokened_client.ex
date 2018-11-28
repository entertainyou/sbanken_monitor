defmodule SbankenMonitor.TokenedClient do
  @moduledoc false
  alias Timex.Duration
  alias SbankenMonitor.Client

  @interval 50 |> Duration.from_minutes() |> Duration.to_milliseconds(truncate: true)

  defmodule State do
    @moduledoc false
    defstruct client: nil, customer_id: Application.get_env(:sbanken_monitor, :customer_id)
  end

  use SbankenMonitor.Agent, interval: @interval, immediate: true

  defp do_work(%State{customer_id: customer_id} = state) do
    client = Client.new(customer_id)
    %State{state | client: client}
  end

  def get_accounts() do
    GenServer.call(__MODULE__, :get_accounts)
  end

  def get_account(account_id) do
    GenServer.call(__MODULE__, {:get_account, account_id})
  end

  def get_transactions(account_id) do
    GenServer.call(__MODULE__, {:get_transaction, account_id})
  end

  def handle_call(:get_accounts, _from, %State{client: client} = state) do
    {:reply, Client.get_accounts(client), state}
  end

  def handle_call({:get_account, account_id}, _from, %State{client: client} = state) do
    {:reply, Client.get_account(client, account_id), state}
  end

  def handle_call({:get_transaction, account_id}, _from, %State{client: client} = state) do
    {:reply, Client.get_transactions(client, account_id), state}
  end
end
