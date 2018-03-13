defmodule Tai.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Tai.PubSub,
      Tai.Trading.Supervisor,
      Tai.Exchanges.Supervisor,
      Tai.Advisors.Supervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
