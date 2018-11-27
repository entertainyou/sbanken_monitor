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
    %{"amount" => amount, "text" => text, "accountingDate" => accountingDate} = transaction

    now = DateTime.utc_now()
    {:ok, accounting, _offset} = DateTime.from_iso8601(accountingDate)

    if DateTime.diff(now, accounting) < @notify_threshold do
      IO.inspect({account, transaction})
      text = "New transaction #{text} #{amount} @ #{accountingDate}"

      SbankenMonitor.Slack.send_message(%{
        text: text
      })

      {:noreply, {records}}
    else
      IO.puts("Found old record #{text} #{amount} @ #{accountingDate}")
      {:noreply, {[record | records]}}
    end
  end
end
