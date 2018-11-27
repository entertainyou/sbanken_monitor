defmodule SbankenMonitor.Worker do
  use GenServer

  require Logger

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def init(arg) do
    Logger.info("Worker inited, arg: #{inspect arg}")
    {:ok, %{}}
  end
end