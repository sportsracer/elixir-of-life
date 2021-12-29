defmodule GameAgent do
  @moduledoc "Agent for holding game state."

  use Agent

  def start_link(grid) do
    {:ok, pid} = Agent.start_link(fn -> grid end, name: __MODULE__)
    "Started game agent #{inspect pid}" |> IO.puts
  end

  def grid(), do: Agent.get(__MODULE__, & &1)

  def tick(), do: Agent.update(__MODULE__, &Grid.tick(&1))
end

defprotocol View do
  @moduledoc "View interface."

  @spec render(t, Grid.t()) :: atom()
  def render(view, grid)
end

defmodule Controller do
  defstruct [:view]

  @tick_duration 100

  defp start_game_loop(controller) do
    :timer.sleep(@tick_duration)
    GameAgent.tick()
    View.render(controller.view, GameAgent.grid())
    start_game_loop(controller)
  end

  def start_link(grid, view) do
    GameAgent.start_link(grid)
    controller = %Controller{view: view}
    Task.start(fn -> start_game_loop(controller) end)
  end
end
