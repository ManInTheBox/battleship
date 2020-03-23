defmodule Battleship.FieldTest do
  use ExUnit.Case, async: false

  test "creates a new field" do
    assert {:A, 5} == Battleship.Field.new(:A, 5)
  end
end
