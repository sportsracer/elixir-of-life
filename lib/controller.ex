defmodule GameAgent do
  @moduledoc "Agent for holding game state."

  use Agent

  def start_link(grid) do
    {:ok, pid} = Agent.start_link(fn -> grid end, name: __MODULE__)
    "Started game agent #{inspect(pid)}" |> IO.puts()
  end

  def grid(), do: Agent.get(__MODULE__, & &1)

  def tick(), do: Agent.update(__MODULE__, &Conway.tick(&1))
end

defprotocol View do
  @moduledoc "View interface."

  @spec render(t, Grid.t()) :: atom
  def render(view, grid)

  @spec add_listener(t, pid) :: atom
  def add_listener(view, listener_pid)
end

defmodule Controller do
  defstruct [:view]

  @tick_duration 50

  defp start_game_loop(controller, iteration \\ 0) do
    View.render(controller.view, GameAgent.grid())

    time = :timer.tc(GameAgent, :tick, []) |> elem(0) |> div(1_000)

    "Iteration #{iteration}\t#{map_size(GameAgent.grid().cells)} cells\t#{time} ms"
    |> IO.puts()

    sleep_time = (@tick_duration - time) |> max(0)
    :timer.sleep(sleep_time)

    receive do
      :toggle_pause ->
        receive do
          # Wait for another toggle pause event before resuming
          :toggle_pause -> :ok
        end
    after
      0 -> nil
    end

    start_game_loop(controller, iteration + 1)
  end

  def start_link(grid, view) do
    GameAgent.start_link(grid)
    controller = %Controller{view: view}
    {:ok, pid} = Task.start(fn -> start_game_loop(controller) end)
    View.add_listener(view, pid)
    {:ok, pid}
  end
end
