defmodule SbankenMonitor.Slack do
  @moduledoc false
  use Tesla
  @slack_url Application.get_env(:sbanken_monitor, :slack_url)

  plug(Tesla.Middleware.JSON)

  def send_message(msg) do
    post(@slack_url, msg)
  end
end
