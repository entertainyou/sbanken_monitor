defmodule SbankenMonitor.HealthChecks do
  @moduledoc false
  alias Timex.Duration
  @interval 1 |> Duration.from_minutes() |> Duration.to_milliseconds(truncate: true)
  @heartbeat_url Application.get_env(:sbanken_monitor, :heartbeat_url)

  defmodule State do
    @moduledoc false
    defstruct foo: nil
  end

  use SbankenMonitor.Agent, interval: @interval, immediate: true

  def do_work(state) do
    Tesla.get(@heartbeat_url)
    state
  end
end
