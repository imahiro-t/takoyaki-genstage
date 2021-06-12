defmodule Cook do
  use GenStage

  @takoball_count 8

  def start_link(name) do
    GenStage.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    {:producer_consumer, :non_use, subscribe_to: [{PreCook, max_demand: 1, min_demand: 0}]}
  end

  def handle_events([%Pack{} = empty_pack], _from, state) do
    pack = empty_pack |> cook()
    {:noreply, [pack], state}
  end

  defp cook(%Pack{} = empty_pack) do
    Process.sleep(3000)

    try do
      takoballs =
        1..@takoball_count
        |> Enum.map(fn _ -> cook_takoball() end)

      %Pack{empty_pack | takoballs: takoballs}
    rescue
      _ ->
        IO.puts("sorry... bug inside... retrying to cook...")
        empty_pack |> cook()
    end
  end

  defp cook_takoball() do
    if 1..100 |> Enum.random() == 1 do
      raise "bug"
    else
      %Takoball{}
    end
  end
end
