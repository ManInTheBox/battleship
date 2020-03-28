defmodule Battleship.FieldTest do
  use ExUnit.Case, async: true

  test "creates a new field" do
    assert {1, 5} == Battleship.Field.new({1, 5})
  end
end
