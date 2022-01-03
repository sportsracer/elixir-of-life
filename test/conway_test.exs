defmodule ConwayTest do
  use ExUnit.Case
  doctest Conway

  test "spawns cells on empty positions with three neighbours" do
    assert is_nil(Conway.transition(nil, %{live: 1}))
    assert is_nil(Conway.transition(nil, %{live: 2}))
    assert Conway.transition(nil, %{live: 3}) == :live
    Enum.each(4..9, fn i -> assert is_nil(Conway.transition(nil, %{live: i})) end)
  end

  test "kills cells unless they have two or three neighbours" do
    assert is_nil(Conway.transition(:live, %{live: 1}))
    assert Conway.transition(:live, %{live: 2}) == :live
    assert Conway.transition(:live, %{live: 3}) == :live
    Enum.each(4..9, fn i -> assert is_nil(Conway.transition(:live, %{live: i})) end)
  end
end
