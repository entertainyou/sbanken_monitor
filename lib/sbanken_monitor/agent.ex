defmodule SbankenMonitor.Agent do
  @moduledoc false
  defmacro __using__(opts) do
    interval = Keyword.get(opts, :interval)
    immediate = Keyword.get(opts, :immediate, false)

    quote do
      use GenServer
      require Logger

      def start_link(args) do
        Logger.debug("#{__MODULE__} start_link args: #{inspect(args)}")
        GenServer.start_link(__MODULE__, args, name: __MODULE__)
      end

      def init(_args) do
        Logger.debug("#{__MODULE__} init")
        state = %__MODULE__.State{}
        schedule()

        if unquote(immediate) do
          {:ok, do_work(state)}
        else
          {:ok, state}
        end
      end

      defp schedule() do
        Process.send_after(self(), :work, unquote(interval))
      end

      def handle_info(:work, state) do
        schedule()
        new_state = do_work(state)
        Logger.debug("#{__MODULE__} handle_info")
        {:noreply, new_state}
      end
    end
  end
end
