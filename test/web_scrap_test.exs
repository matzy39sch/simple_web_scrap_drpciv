defmodule WebScrapTest do
  use ExUnit.Case
  doctest WebScrap

  test "greets the world" do
    assert WebScrap.hello() == :world
  end
end
