defmodule SbankenMonitor.Monitor do
  @moduledoc false
  alias SbankenMonitor.TokenedClient
  alias SbankenMonitor.Notifier
  alias Timex.Duration

  @monitor_interval 1 |> Duration.from_minutes() |> Duration.to_milliseconds(truncate: true)

  defmodule State do
    @moduledoc false
    defstruct transactions: MapSet.new()
  end

  use SbankenMonitor.Agent, interval: @monitor_interval, immediate: true

  def do_work(%State{transactions: transactions} = state) do
    {:ok, result} = TokenedClient.get_accounts()
    account_ids = result.body |> Map.fetch!("items") |> Enum.map(&Map.fetch!(&1, "accountId"))

    new_transactions =
      account_ids
      |> Enum.map(fn account_id ->
        {:ok, result} = TokenedClient.get_transactions(account_id)
        transactions = result.body |> Map.fetch!("items")
        {account_id, transactions}
      end)
      |> Enum.flat_map(fn {account_id, transactions} ->
        Enum.map(transactions, fn transaction -> {account_id, transaction} end)
      end)
      |> Enum.reduce(transactions, fn {account_id, transaction} = record, acc ->
        with_transaction_id = Map.put_new(transaction, "transactionId", "0")

        case MapSet.member?(acc, {account_id, with_transaction_id}) do
          true ->
            acc

          false ->
            Notifier.notify(record)
            MapSet.put(acc, {account_id, with_transaction_id})
        end
      end)

    %State{state | transactions: new_transactions}
  end
end
