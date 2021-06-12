defmodule PreCook do
  use GenStage

  def start_link(initial_cook_count) do
    GenStage.start_link(__MODULE__, initial_cook_count, name: __MODULE__)
  end

  def init(initial_cook_count) do
    {:producer_consumer, initial_cook_count,
     subscribe_to: [EmptyPackPreparation, InitEmptyPackPreparation]}
  end

  def handle_subscribe(:producer, _opts, {pid, _reference} = from, initial_cook_count = state) do
    if pid == Process.whereis(InitEmptyPackPreparation) do
      GenStage.ask(from, initial_cook_count)
      {:manual, state}
    else
      {:automatic, state}
    end
  end

  def handle_subscribe(:consumer, _opts, _from, state) do
    {:automatic, state}
  end

  def handle_events(empty_packs, _from, state) do
    {:noreply, empty_packs, state}
  end
end
