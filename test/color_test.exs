defmodule ColorTest do
  use ExUnit.Case
  doctest Color

  test "gets mixed with other colors when used as a trait" do
    red = %Color{r: 200, g: 0, b: 0}
    gray = %Color{r: 200, g: 200, b: 200}

    crossed = Trait.cross(red, MapSet.new([gray]))

    assert %Color{r: 200, g: 100, b: 100} = crossed
  end
end
