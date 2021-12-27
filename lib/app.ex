defmodule ElixirOfLifeApp do
  use Application

  defp refresh_every(pid, ms) do
    :timer.sleep(ms)
    :wx_object.call(pid, :refresh)
    refresh_every(pid, ms)
  end

  def start(_type, _args) do
    IO.puts("Starting with PID #{inspect self()})…")

    {:wx_ref, _, _, pid} = Canvas.start_link()

    Task.start(fn -> refresh_every(pid, 1000) end)

    ref = Process.monitor(pid)
    receive do
      {:DOWN, ^ref, _, _, _} ->
        :ok
    end

    {:ok, pid}
  end
end
