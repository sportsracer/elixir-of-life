defmodule WxView do
  @moduledoc "Visualize a game of life grid in a window powered by wxWidgets."

  @type t :: %__MODULE__{
          window_pid: pid
        }
  defstruct [:window_pid]

  @spec create :: t
  def create() do
    {:wx_ref, _, _, pid} = Window.start_link()
    "Started view #{inspect(pid)}" |> IO.puts()
    %WxView{window_pid: pid}
  end
end

defimpl View, for: WxView do
  @spec render(WxView.t(), Grid.t()) :: atom
  def render(wx_view, grid) do
    pid = wx_view.window_pid
    Process.alive?(pid) && :wx_object.call(pid, {:render, grid})
  end

  @spec add_listener(WxView.t(), pid) :: atom
  def add_listener(wx_view, listener_pid) do
    pid = wx_view.window_pid
    Process.alive?(pid) && :wx_object.call(pid, {:add_listener, listener_pid})
  end
end
