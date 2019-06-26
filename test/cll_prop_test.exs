defmodule CLL.PropTest do
  use ExUnit.Case
  use PropCheck
  import CLL

  property "walking forward then backward by the same amount ends up at the same element" do
    forall [list, travel, start] <- [list(integer()), integer(), integer()] do
      a = init(list) |> next(start) |> value()
      a == init(list) |> next(start + travel) |> prev(travel) |> value()
    end
  end

  property "walking backward then forward by the same amount ends up at the same element" do
    forall [list, travel, start] <- [list(integer()), integer(), integer()] do
      a = init(list) |> prev(start) |> value()
      a == init(list) |> prev(start + travel) |> next(travel) |> value()
    end
  end

  property "inserting N items should increase the length tof the CLL by N" do
    forall [list, moves, start] <- [list(integer()), list(integer()), integer()] do
      cll = list |> init() |> next(start)

      result = Enum.reduce(moves, cll, fn move, acc -> acc |> next(move) |> insert(move) end)

      max(length(list) + length(moves), 0) == len(result)
    end
  end

  property "removing N items should decrease the length of the CLL by N" do
    forall [list, moves, start] <- [list(integer()), list(integer()), integer()] do
      cll = list |> init() |> next(start)

      result = Enum.reduce(moves, cll, fn move, acc -> acc |> next(move) |> remove() end)

      max(length(list) - length(moves), 0) == len(result)
    end
  end

  property "value/2 gets the value N steps away" do
    forall [list, travel, start] <- [list(integer()), integer(), integer()] do
      cll = list |> init() |> next(start)

      value(cll, travel) == value(next(cll, travel))
    end
  end
end
