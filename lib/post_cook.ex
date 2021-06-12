defmodule PostCook do
  use GenStage

  def start_link(lane_names) do
    GenStage.start_link(__MODULE__, lane_names, name: __MODULE__)
  end

  def init(lane_names) do
    {:producer_consumer, :non_use, subscribe_to: lane_names}
  end

  def handle_events([%Pack{} = pack], _from, state) do
    {:noreply, [pack], state}
  end
end
