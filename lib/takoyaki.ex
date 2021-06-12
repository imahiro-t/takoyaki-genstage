defmodule Takoyaki do
  use GenServer

  @max_order_count 6

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    send_next_order()
    {:ok, :non_use}
  end

  def handle_info(:order, state) do
    order()
    send_next_order()
    {:noreply, state}
  end

  defp send_next_order() do
    Process.send_after(self(), :order, (10..50 |> Enum.random()) * 100)
  end

  defp order() do
    OrderTaker.order(1..@max_order_count |> Enum.random())
  end
end
