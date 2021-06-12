defmodule Cashier do
  use GenStage

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:producer_consumer, :non_use, subscribe_to: [{OrderTaker, max_demand: 1, min_demand: 0}]}
  end

  def handle_events([%Order{} = order], _from, state) do
    {:noreply, [order], state}
  end
end
