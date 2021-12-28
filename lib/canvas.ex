defmodule Canvas do
  @behaviour :wx_object

  @title "Elixir of Life"
  @size {600, 600}

  def start_link() do
    :wx_object.start_link(__MODULE__, [], [])
  end

  def init(_args \\ []) do
    wx = :wx.new()
    frame = :wxFrame.new(wx, -1, @title, size: @size)
    :wxFrame.connect(frame, :size)
    :wxFrame.connect(frame, :close_window)

    panel = :wxPanel.new(frame, [])
    :wxPanel.connect(panel, :paint, [:callback])
    :wxFrame.show(frame)

    state = %{panel: panel}
    {frame, state}
  end

  def handle_event({:wx, _, _, _, {:wxSize, :size, size, _}}, state = %{panel: panel}) do
    :wxPanel.setSize(panel, size)
    {:noreply, state}
  end

  def handle_event({:wx, _, _, _, {:wxClose, :close_window}}, state) do
    {:stop, :normal, state}
  end

  def handle_sync_event({:wx, _, _, _, {:wxPaint, :paint}}, _, %{panel: panel}) do
    dc = :wxPaintDC.new(panel)
    grid = Grid.random_init(-20, -20, 20, 20)
    View.render(grid, dc)
    :wxPaintDC.destroy(dc)
    :ok
  end

  def handle_call(:refresh, _from, state = %{panel: panel}) do
    :wxPanel.refresh(panel)
    {:reply, :ok, state}
  end
end
