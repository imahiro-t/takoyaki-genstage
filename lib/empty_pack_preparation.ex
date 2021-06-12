defmodule EmptyPackPreparation do
  use GenStage

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:producer_consumer, :non_use, subscribe_to: [{OrderTaker, max_demand: 1, min_demand: 0}]}
  end

  def handle_events([%Order{order_count: order_count}], _from, state) do
    empty_packs = order_count |> prepare_empty_packs()
    {:noreply, empty_packs, state}
  end

  defp prepare_empty_packs(pack_count) do
    1..pack_count |> Enum.map(fn _ -> %Pack{} end)
  end
end
