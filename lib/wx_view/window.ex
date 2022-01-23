defmodule Window do
  @moduledoc "Window powered by wxWidgets onto which a game of life grid is rendered."

  @behaviour :wx_object

  @title "Elixir of Life"
  @size {600, 600}

  # TODO Can we get named constants for key codes from wxWidgets?
  @key_space 32
  @key_q 81

  @spec start_link :: any
  def start_link() do
    :wx_object.start_link(__MODULE__, [], [])
  end

  @spec init(list | nil) :: {any, map}
  def init(_args \\ []) do
    wx = :wx.new()
    frame = :wxFrame.new(wx, -1, @title, size: @size)
    :wxFrame.connect(frame, :size)
    :wxFrame.connect(frame, :close_window)

    panel = :wxPanel.new(frame, [])
    :wxPanel.connect(panel, :paint, [:callback])
    :wxPanel.connect(panel, :key_down)
    :wxFrame.show(frame)

    state = %{panel: panel, grid: %Grid{}}
    {frame, state}
  end

  @spec handle_event({:wx, any, any, any, tuple}, map) :: tuple
  def handle_event(event, state)

  def handle_event({:wx, _, _, _, {:wxSize, :size, size, _}}, state = %{panel: panel}) do
    :wxPanel.setSize(panel, size)
    {:noreply, state}
  end

  def handle_event({:wx, _, _, _, {:wxClose, :close_window}}, state), do: {:stop, :normal, state}

  def handle_event(
        {:wx, _, _, _, {:wxKey, :key_down, _, _, key_code, _, _, _, _, _, _, _}},
        state
      ),
      do: handle_key_down(key_code, state)

  @spec handle_key_down(integer, map) :: tuple
  defp handle_key_down(key_code, state)

  defp handle_key_down(@key_space, state = %{listener_pid: listener_pid}),
    do: send(listener_pid, :toggle_pause) && {:noreply, state}

  defp handle_key_down(@key_q, state),
    do: {:stop, :normal, state}

  defp handle_key_down(_key_code, state), do: {:noreply, state}

  @spec handle_sync_event({:wx, any, any, any, tuple}, any, map) :: :ok
  def handle_sync_event({:wx, _, _, _, {:wxPaint, :paint}}, _, %{panel: panel, grid: grid}) do
    dc = :wxPaintDC.new(panel)
    Renderer.render(grid, dc)
    :wxPaintDC.destroy(dc)
    :ok
  end

  @spec handle_call(tuple, pid, map) :: tuple
  def handle_call(request, from, state)

  def handle_call({:render, grid}, _from, state = %{panel: panel}) do
    new_state = %{state | grid: grid}
    :wxPanel.refresh(panel)
    {:reply, :ok, new_state}
  end

  def handle_call({:add_listener, listener_pid}, _from, state) do
    new_state = Map.put(state, :listener_pid, listener_pid)
    {:reply, :ok, new_state}
  end
end
