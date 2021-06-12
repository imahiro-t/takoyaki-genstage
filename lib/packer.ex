defmodule Packer do
  use GenStage

  defmodule State do
    defstruct order: nil,
              packs: [],
              producers: %{Cashier => nil, PostCook => nil}
  end

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:consumer, %State{}, subscribe_to: [Cashier, PostCook]}
  end

  def handle_subscribe(
        :producer,
        _opts,
        {pid, _reference} = from,
        %State{producers: producers} = state
      ) do
    producers =
      if pid == Process.whereis(Cashier) do
        GenStage.ask(from, 1)
        %{producers | Cashier => from}
      else
        %{producers | PostCook => from}
      end

    {:manual, %State{state | producers: producers}}
  end

  def handle_events(
        [%Order{} = order],
        {pid, _reference} = _from,
        %State{order: nil, packs: [], producers: %{PostCook => post_cook}} = state
      ) do
    state =
      if pid == Process.whereis(Cashier) do
        GenStage.ask(post_cook, 1)
        %State{state | order: order}
      else
        state
      end

    {:noreply, [], state}
  end

  def handle_events(
        [%Pack{} = pack],
        {pid, _reference} = from,
        %State{
          order: %Order{
            order_number: order_number,
            order_count: order_count
          },
          packs: packs,
          producers: %{Cashier => cashier}
        } = state
      ) do
    state =
      if pid == Process.whereis(PostCook) do
        packs = [pack | packs]
        1..length(packs) |> Enum.map(fn _ -> "." end) |> Enum.join() |> IO.puts()

        if order_count == packs |> length() do
          serve(order_number, packs)
          GenStage.ask(cashier, 1)
          %State{state | packs: [], order: nil}
        else
          GenStage.ask(from, 1)
          %State{state | packs: packs}
        end
      else
        state
      end

    {:noreply, [], state}
  end

  defp serve(order_number, packs) do
    IO.puts(
      "[#{order_number |> to_string |> String.pad_leading(10, "0")}]" <>
        (packs |> Enum.map(&(&1 |> to_string)) |> Enum.join())
    )
  end
end
