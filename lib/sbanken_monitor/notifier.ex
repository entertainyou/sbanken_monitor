defmodule SbankenMonitor.Notifier do
  @moduledoc false

  use GenServer
  alias Timex.Duration

  @notify_threshold 1 |> Duration.from_days() |> Duration.to_seconds(truncate: true)

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:ok, {[]}}
  end

  def notify({account, transaction}) do
    GenServer.cast(__MODULE__, {:notify, {account, transaction}})
  end

  def handle_cast({:notify, {account, transaction} = record}, {records}) do
    %{"amount" => amount, "text" => text, "accountingDate" => accounting_date} = transaction

    now = DateTime.utc_now()
    {:ok, accounting, _offset} = DateTime.from_iso8601(accounting_date)

    if DateTime.diff(now, accounting) < @notify_threshold do
      IO.puts("#{inspect({account, transaction})}")
      text = "New transaction #{text} #{amount} @ #{accounting_date}"

      SbankenMonitor.Slack.send_message(%{
        text: text
      })

      {:noreply, {records}}
    else
      IO.puts("Found old record #{text} #{amount} @ #{accounting_date}")
      {:noreply, {[record | records]}}
    end
  end
end
