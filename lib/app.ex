defmodule ElixirOfLifeApp do
  use Application

  def start(_type, _args) do
    "Started app #{inspect self()}" |> IO.puts()

    # Start model, view and controller
    grid = Grid.random_init(-20, -20, 20, 20)
    wx_view = WxView.create()
    {:ok, pid} = Controller.start_link(grid, wx_view)

    # Run until controller process terminates
    ref = Process.monitor(pid)

    receive do
      {:DOWN, ^ref, _, _, _} ->
        :ok
    end

    {:ok, pid}
  end
end
