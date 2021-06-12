defmodule Order do
  defstruct order_number: 1, order_count: 0
end

defmodule Takoball do
  defstruct value: "●"
end

defmodule Pack do
  defstruct takoballs: []
end

defimpl String.Chars, for: Pack do
  def to_string(pack) do
    "[#{pack.takoballs |> Enum.map(& &1.value) |> Enum.join(",")}]"
  end
end
