defmodule Takoyaki.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @initial_order_number 1
  @initial_cook_count 4

  @impl true
  def start(_type, _args) do
    children = [
      {OrderTaker, @initial_order_number},
      {Cashier, []},
      {InitEmptyPackPreparation, @initial_cook_count},
      {EmptyPackPreparation, []},
      {PreCook, @initial_cook_count},
      Supervisor.child_spec({Cook, :lane1}, id: :lane1),
      Supervisor.child_spec({Cook, :lane2}, id: :lane2),
      Supervisor.child_spec({Cook, :lane3}, id: :lane3),
      Supervisor.child_spec({Cook, :lane4}, id: :lane4),
      {PostCook, [:lane1, :lane2, :lane3, :lane4]},
      {Packer, []},
      {Takoyaki, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :rest_for_one, name: Takoyaki.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
