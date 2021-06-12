defmodule OrderTaker do
  use GenStage

  def start_link(initial_order_number) do
    GenStage.start_link(__MODULE__, initial_order_number, name: __MODULE__)
  end

  def init(initial_order_number) do
    {:producer, initial_order_number, dispatcher: GenStage.BroadcastDispatcher}
  end

  def order(order_count) do
    GenStage.call(__MODULE__, {:order, order_count}, 5000)
  end

  def handle_call({:order, order_count}, _from, order_number) do
    IO.puts(
      "#{order_count} pack(s) ordered [#{order_number |> to_string |> String.pad_leading(10, "0")}]"
    )

    {:reply, :ok, [%Order{order_number: order_number, order_count: order_count}],
     order_number + 1}
  end

  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end
end
