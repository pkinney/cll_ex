defmodule CLLTest do
  use ExUnit.Case
  import CLL
  doctest CLL

  @empty init([])
  @zip 1..7 |> Enum.to_list() |> init()

  describe "CLL.at/2" do
    test "on an empty list" do
      assert value(@empty, 0) == nil
      assert value(@empty, -1) == nil
      assert value(@empty, 3) == nil
    end

    test "when at the start" do
      assert value(@zip, 0) == 1
      assert value(@zip, 1) == 2
      assert value(@zip, -2) == 6
      assert value(@zip, 7) == 1
      assert value(@zip, -7) == 1
      assert value(@zip, 10) == 4
      assert value(@zip, -10) == 5
    end

    test "when in the middle" do
      z = @zip |> next(3)

      assert value(z, 0) == 4
      assert value(z, 1) == 5
      assert value(z, -2) == 2
      assert value(z, len(z)) == value(z)
      assert value(z, -len(z)) == value(z)
      assert value(z, len(z) + 3) == value(z, 3)
      assert value(z, -(len(z) + 3)) == value(z, -3)
    end

    test "when near the end" do
      z = @zip |> next(len(@zip) - 1)

      assert value(z, 0) == 7
      assert value(z, 1) == 1
      assert value(z, -2) == 5
      assert value(z, len(z)) == value(z)
      assert value(z, -len(z)) == value(z)
      assert value(z, len(z) + 3) == value(z, 3)
      assert value(z, -(len(z) + 3)) == value(z, -3)
    end

    test "when at the end" do
      z = @zip |> next(len(@zip))

      assert value(z, 0) == 1
      assert value(z, 1) == 2
      assert value(z, -2) == 6
      assert value(z, len(z)) == value(z)
      assert value(z, -len(z)) == value(z)
      assert value(z, len(z) + 3) == value(z, 3)
      assert value(z, -(len(z) + 3)) == value(z, -3)
    end
  end

  describe "CLL.next/2 and CLL.prev/2" do
    test "when at the start" do
      z = @zip

      assert z |> next() |> value() == 2
      assert z |> next(3) |> value() == 4
      assert z |> next() |> next(2) |> value() == 4
      assert z |> next(len(z)) |> value() == 1
      assert z |> next(len(z)) |> next(-1) |> value() == 7
      assert z |> next(len(z) + 3) |> value() == 4
    end
  end

  describe "CLL.remove/1" do
    test "remove the first element" do
      assert @zip |> remove() |> to_list() == Enum.to_list(2..7)
      assert @zip |> remove() |> remove() |> remove() |> to_list() == Enum.to_list(4..7)
    end

    test "remove a middle element" do
      assert @zip |> next(3) |> remove() |> to_list() == [1, 2, 3, 5, 6, 7]
      assert @zip |> next(3) |> remove() |> remove() |> remove() |> to_list() == [1, 2, 3, 7]
      assert @zip |> next(5) |> remove() |> remove() |> remove() |> to_list() == [2, 3, 4, 5]

      assert @zip
             |> next(5)
             |> remove()
             |> remove()
             |> remove()
             |> remove()
             |> remove()
             |> remove()
             |> remove()
             |> to_list() == []

      assert @zip
             |> next(5)
             |> remove()
             |> remove()
             |> remove()
             |> remove()
             |> remove()
             |> remove()
             |> remove()
             |> remove()
             |> remove()
             |> remove()
             |> to_list() == []
    end
  end

  describe "CLL.insert/2" do
    test "should insert into an empty list" do
      assert @empty |> insert(:foo) |> to_list() == [:foo]
      assert @empty |> insert(:foo) |> value() == :foo
      assert @empty |> insert(:foo) |> insert(:bar) |> to_list() == [:foo, :bar]
    end

    test "should insert at the beginning" do
      assert @zip |> insert(:foo) |> to_list() == [:foo, 1, 2, 3, 4, 5, 6, 7]
    end

    test "should insert at the end after reaching the end" do
      assert @zip |> next(7) |> insert(:foo) |> to_list() == [1, 2, 3, 4, 5, 6, 7, :foo]
      assert @zip |> next(7) |> insert(:foo) |> value() == 1
    end

    test "should still point to the same value after inserting before the value" do
      assert @zip |> insert(:foo) |> offset() == 1
      assert @zip |> next(2) |> insert(:foo) |> value() == 3
      assert @zip |> next(7) |> insert(:foo) |> value() == 1
      assert @zip |> next(7) |> insert(:foo) |> next() |> value() == 2
    end

    test "should insert at the end" do
      assert @zip |> next(7) |> insert(:foo) |> to_list() == [1, 2, 3, 4, 5, 6, 7, :foo]
    end
  end

  describe "CLL.replace/2" do
    test "replace the first element" do
      assert @zip |> replace(:foo) |> to_list() == [:foo, 2, 3, 4, 5, 6, 7]
      assert @zip |> replace(:foo) |> value() == :foo
    end

    test "replace the first element after reaching the end" do
      assert @zip |> next(7) |> value() == 1
      assert @zip |> next(7) |> replace(:foo) |> to_list() == [:foo, 2, 3, 4, 5, 6, 7]
      assert @zip |> next(7) |> replace(:foo) |> value() == :foo
    end

    test "replace the last element" do
      assert @zip |> next(6) |> value() == 7
      assert @zip |> next(6) |> replace(:foo) |> to_list() == [1, 2, 3, 4, 5, 6, :foo]
      assert @zip |> next(6) |> replace(:foo) |> value() == :foo
    end

    test "replace an element in the middle" do
      assert @zip |> next(3) |> replace(:foo) |> to_list() == [1, 2, 3, :foo, 5, 6, 7]
      assert @zip |> next(3) |> replace(:foo) |> value() == :foo
    end

    test "is idempotent" do
      assert @zip
             |> next(3)
             |> replace(:foo)
             |> replace(:bar)
             |> replace(:bar)
             |> to_list == [1, 2, 3, :bar, 5, 6, 7]
    end
  end

  describe "CLL.to_list/1" do
    test "should always be the same no matter where the cursor is" do
      assert @zip |> to_list == Enum.to_list(1..7)

      assert @zip |> next(2) |> to_list == Enum.to_list(1..7)
      assert @zip |> next(7) |> to_list == Enum.to_list(1..7)
      assert @zip |> next(12) |> to_list == Enum.to_list(1..7)

      assert @zip |> prev(2) |> to_list == Enum.to_list(1..7)
      assert @zip |> prev(7) |> to_list == Enum.to_list(1..7)
      assert @zip |> prev(12) |> to_list == Enum.to_list(1..7)
    end
  end

  describe "CLL.empty?/1" do
    test "should return true for an empty list" do
      assert empty?(@empty)
    end

    test "should return false for a non-empty list" do
      refute empty?(@zip)
      refute @zip |> prev() |> empty?()
    end

    test "should return true after a list is emptied" do
      assert @zip
             |> remove()
             |> remove()
             |> remove()
             |> remove()
             |> remove()
             |> remove()
             |> remove()
             |> empty?()
    end
  end
end
