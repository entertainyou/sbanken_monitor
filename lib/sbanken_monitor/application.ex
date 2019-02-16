defmodule SbankenMonitor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: SbankenMonitor.Worker.start_link(arg)
      {SbankenMonitor.TokenedClient, []},
      {SbankenMonitor.Notifier, []},
      {SbankenMonitor.Monitor, []},
      {SbankenMonitor.Balance, []},
      {SbankenMonitor.HealthChecks, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SbankenMonitor.Supervisor]
    {:ok, _} = Logger.add_backend(Sentry.LoggerBackend)
    Supervisor.start_link(children, opts)
  end
end
