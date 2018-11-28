defmodule SbankenMonitor.Balance do
  @moduledoc false
  alias Timex.Duration
  alias SbankenMonitor.TokenedClient
  alias SbankenMonitor.Slack

  @interval 1 |> Duration.from_days() |> Duration.to_milliseconds(truncate: true)

  defmodule State do
    @moduledoc false
    defstruct foo: nil
  end

  use SbankenMonitor.Agent, interval: @interval, immediate: true

  def do_work(state) do
    {:ok, results} = TokenedClient.get_accounts()

    results.body
    |> Map.fetch!("items")
    |> Enum.each(fn %{"name" => name, "available" => available, "balance" => balance} ->
      msg = "#{name} available: #{available} balance: #{balance}"

      Slack.send_message(%{
        text: msg
      })
    end)

    state
  end
end
