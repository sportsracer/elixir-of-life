defmodule WxView do
  @moduledoc "Visualize a game of life grid in a window powered by wxWidgets."

  defstruct [:window_pid]

  def create() do
    {:wx_ref, _, _, pid} = Window.start_link()
    "Started view #{inspect pid}" |> IO.puts()
    # TODO: Why does linking the view process not take down the controller on exit?
    # Process.link(pid)
    %WxView{window_pid: pid}
  end
end

defimpl View, for: WxView do
  def render(wx_view, grid) do
    if Process.alive?(wx_view.window_pid) do
      :wx_object.call(wx_view.window_pid, {:render, grid})
    else
      Process.exit(self(), :ok)
    end
  end
end
