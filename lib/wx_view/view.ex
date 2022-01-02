defmodule WxView do
  @moduledoc "Visualize a game of life grid in a window powered by wxWidgets."

  defstruct [:window_pid]

  def create() do
    {:wx_ref, _, _, pid} = Window.start_link()
    "Started view #{inspect(pid)}" |> IO.puts()
    %WxView{window_pid: pid}
  end
end

defimpl View, for: WxView do
  def render(wx_view, grid) do
    pid = wx_view.window_pid
    Process.alive?(pid) && :wx_object.call(pid, {:render, grid})
  end
end
