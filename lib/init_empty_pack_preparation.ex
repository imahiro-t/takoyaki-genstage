defmodule InitEmptyPackPreparation do
  use GenStage

  def start_link(initial_cook_count) do
    GenStage.start_link(__MODULE__, initial_cook_count, name: __MODULE__)
  end

  def init(initial_cook_count) do
    {:producer, initial_cook_count}
  end

  def handle_demand(demand, rest_pack_count) when demand > 0 and rest_pack_count > 0 do
    pack_count = if rest_pack_count > demand, do: demand, else: rest_pack_count
    empty_packs = pack_count |> prepare_empty_packs()
    {:noreply, empty_packs, rest_pack_count - pack_count}
  end

  def handle_demand(_demand, rest_pack_count) do
    {:noreply, [], rest_pack_count}
  end

  defp prepare_empty_packs(pack_count) do
    1..pack_count |> Enum.map(fn _ -> %Pack{} end)
  end
end
