defmodule ElixirOfLifeApp do
  use Application

  defp make_grid() do
    # Set up colored quadrants
    grid =
      Grid.random_init(0, -30, 30, 0, 0.3, :live, Color.make(:green))
      |> Grid.merge(Grid.random_init(-30, 0, 0, 30, 0.3, :live, Color.make(:blue)))
      |> Grid.merge(Grid.random_init(0, 0, 30, 30, 0.3, :live, Color.make(:red)))

    # Attack it with gliders :)
    Enum.reduce(0..99, grid, fn i, acc ->
      row_offset = (rem(i, 4) - 2) * 4
      left = -15 - i * 2 - row_offset
      top = -15 - i * 2 + row_offset

      Grid.merge(
        acc,
        Conway.Patterns.make(:glider, left, top, Color.make(:white))
      )
    end)
  end

  def start(_type, _args) do
    "Started app #{inspect(self())}" |> IO.puts()

    # Start model, view and controller
    grid = make_grid()
    wx_view = WxView.create()
    {:ok, pid} = Controller.start_link(grid, wx_view)

    # Run until controller process terminates
    ctrl_ref = Process.monitor(pid)
    view_ref = Process.monitor(wx_view.window_pid)

    receive do
      {:DOWN, ^view_ref, _, _, _} -> Process.exit(pid, :ok)
      {:DOWN, ^ctrl_ref, _, _, _} -> :ok
    end

    {:ok, pid}
  end
end
