defmodule CLL do
  @moduledoc """
  This module can be used to represent a data structure with similar behavior
  as circular Doubly-Linked-List.

  "But wait, aren't all Lists in Erlang Linked Lists?"  Well yes, but they
  are immutable, which makes things like removing elements while iterating
  through the list very slow.  Also, getting consistent CLL-like behaviour
  from normal Lists is not easy when dealing with problems such as polygon
  math around the beginning and end of the list.

  Internally, it uses a Zipper data structure
  (https://en.wikipedia.org/wiki/Zipper_(data_structure))
  to keep the items before and
  after the current item in a way that optimizes for moving forward and
  backward in the list.  Because the next and previous item are always the
  first items in the surrounding lists, those operations are substantially
  faster than tracking a cursor in a standar List an fetching its neighbors.

  A list can be created by passing a List to the `init/2` function along with
  an boolean defining if the resulting Doubly-Linked-List is circular or not.
  Once created, you can traverse through the list one or more steps at a time.

  ## Examples
      iex> [1, 2, 3, 4, 5]
      ...> |> CLL.init()
      ...> |> CLL.value()
      1

      iex> [1, 2, 3, 4, 5]
      ...> |> CLL.init()
      ...> |> CLL.next()
      ...> |> CLL.value()
      2

      iex> [1, 2, 3, 4, 5]
      ...> |> CLL.init()
      ...> |> CLL.prev()
      ...> |> CLL.prev(3)
      ...> |> CLL.next(2)
      ...> |> CLL.value()
      4

  You can also modify the list by inserting, replacing, or removing the current
  element.  Finally, if desired, you can convert the CLL back into a List.

  ## Examples
      iex> CLL.init([1, 2, 3, 4, 5])
      ...> |> CLL.next(2)
      ...> |> CLL.remove()
      ...> |> CLL.to_list()
      [1, 2, 4, 5]

      iex> CLL.init([1, 2, 3, 4, 5])
      ...> |> CLL.prev(2)
      ...> |> CLL.replace(:foo)
      ...> |> CLL.to_list()
      [1, 2, 3, :foo, 5]

      iex> CLL.init([1, 2, 3, 4, 5])
      ...> |> CLL.next(3)
      ...> |> CLL.insert(3.5)
      ...> |> CLL.insert(3.75)
      ...> |> CLL.to_list()
      [1, 2, 3, 3.5, 3.75, 4, 5]

  To help with use cases where iterating through the list once is useful, CLL
  keeps track of the "start" of the list so that you can determine when a list
  has been fully traversed.  A list can also be reset to the initial start
  position at any time.

  ## Examples
      iex> CLL.init([1, 2, 3, 4, 5])
      ...> |> CLL.next(3)
      ...> |> CLL.prev(2)
      ...> |> CLL.next()
      ...> |> CLL.offset()
      2

      iex> CLL.init([1, 2, 3, 4, 5])
      ...> |> CLL.next(5)
      ...> |> CLL.done?()
      true

      iex> CLL.init([1, 2, 3, 4, 5])
      ...> |> CLL.next(4)
      ...> |> CLL.reset()
      ...> |> CLL.value()
      1
  """

  @type cll :: {list, list}
  @type value :: any

  @doc """
  Initializes a CLL with the contents of the given list and sets the 
  """
  @spec init(list) :: cll
  def init(list) when is_list(list), do: {[], list}

  @doc """
  Moves the root of the list to the next element in the CLL.
  """
  @spec next(cll) :: cll
  def next({[], []}), do: {[], []}

  def next({visited, []}) do
    [a | remain] = Enum.reverse(visited)
    {[a], remain}
  end

  def next({visited, [a | remain]}), do: {[a] ++ visited, remain}

  @doc """
  Preforms the `next/1` action a `number` of times.
  """
  @spec next(cll, number) :: cll
  def next(state, 0), do: state
  def next(state, 1), do: next(state)
  def next(state, offset) when offset < 0, do: prev(state, -offset)
  def next(state, offset), do: next(next(state), offset - 1)

  @doc """
  Moves the root of the list to the previous element in the CLL.
  """
  @spec prev(cll) :: cll
  def prev({[], []}), do: {[], []}
  def prev({[], remain}), do: {Enum.reverse(remain), []} |> prev()
  def prev({[a | visited], remain}), do: {visited, [a] ++ remain}

  @doc """
  Preforms the `prev/1` action a `number` of times.
  """
  @spec prev(cll, number) :: cll
  def prev(state, 0), do: state
  def prev(state, 1), do: prev(state)
  def prev(state, offset) when offset < 0, do: next(state, -offset)
  def prev(state, offset), do: prev(prev(state), offset - 1)

  @doc """
  Returns the value at the given offset from the root.  If `offset` is not given, the value at root is returned.
  """
  @spec value(cll) :: any
  @spec value(cll, number) :: any
  def value(state, offset \\ 0)

  def value({[], []}, _), do: nil

  def value({_, remain} = state, offset) when offset >= length(remain),
    do: value(state, offset - len(state))

  def value({visited, _} = state, offset) when offset < -length(visited),
    do: value(state, offset + len(state))

  def value({visited, _}, offset) when offset < 0, do: Enum.at(visited, -offset - 1)
  def value({_, remain}, offset), do: Enum.at(remain, offset)

  @doc """
  Returns the number of elements in the CLL.

  ## Examples

      iex> CLL.init([1, 2, 3, 4, 5])
      ...> |> CLL.len()
      5 

  """
  @spec len(cll) :: non_neg_integer
  def len({visited, remain}), do: length(visited) + length(remain)

  @doc """
  Returns `true` if the CLL is empty, `false` otherwise.

  ## Examples

      iex> CLL.init([1, 2, 3, 4, 5])
      ...> |> CLL.empty?()
      false 

      iex> CLL.init([])
      ...> |> CLL.empty?()
      true


  """
  @spec empty?(cll) :: boolean
  def empty?({[], []}), do: true
  def empty?(_), do: false

  @doc """
  Returns the offset of the CLL pointer from the first element of the original list.
  """
  @spec offset(cll) :: non_neg_integer
  def offset({visited, _}), do: length(visited)

  @doc """
  In the case that you are stepping through the list, the function returns true when all of the elements of the list have been visited once and only once.

  ## Examples

      iex> CLL.init([1, 2, 3])
      ...> |> CLL.next()
      ...> |> CLL.next()
      ...> |> CLL.next()
      ...> |> CLL.done?()
      true

      iex> CLL.init([1, 2, 3])
      ...> |> CLL.next()
      ...> |> CLL.next()
      ...> |> CLL.next()
      ...> |> CLL.next()
      ...> |> CLL.done?()
      false
  """
  @spec done?(cll) :: boolean
  def done?({_, []}), do: true
  def done?(_), do: false

  @doc """
  Resets the pointer to point to the first element of the original list.

  ## Examples

      iex> CLL.init([1, 2, 3])
      ...> |> CLL.next(2)
      ...> |> CLL.reset()
      ...> |> CLL.value()
      1
  """
  @spec reset(cll) :: cll
  def reset({_, _} = state) do
    state |> to_list() |> init()
  end

  @doc """
  Removes the element at the pointer from the list.  The pointer will point to the element after the removed one.
  """
  @spec remove(cll) :: cll
  def remove({[], []}), do: {[], []}
  def remove({visited, []}), do: {Enum.drop(visited, -1), []}
  def remove({visited, [_ | remain]}), do: {visited, remain}

  @doc """
  Inserts an element prior to the pointer position such that inserting an element
  does not change the value at the pointer position.

  ## Examples
      iex> CLL.init([1, 2, 3, 4, 5])
      ...> |> CLL.next(2)
      ...> |> CLL.value()
      3

      iex> CLL.init([1, 2, 3, 4, 5])
      ...> |> CLL.next(2)
      ...> |> CLL.insert(9)
      ...> |> CLL.value()
      3
  """
  @spec insert(cll, any) :: cll
  def insert({visited, remain}, value), do: {[value | visited], remain}

  @doc """
  Replaces the element at the pointer positing with the given value.  The pointer remains in the same place.

  ## Examples

      iex> CLL.init([1, 2, 3, 4, 5])
      ...> |> CLL.next(2)
      ...> |> CLL.replace(9)
      ...> |> CLL.value()
      9 

      iex> CLL.init([1, 2, 3, 4, 5])
      ...> |> CLL.next(2)
      ...> |> CLL.insert(9)
      ...> |> CLL.value()
      3
  """
  @spec replace(cll, any) :: cll
  def replace({[], []}, _), do: {[], []}
  def replace({visited, []}, value), do: {Enum.drop(visited, -1) ++ [value], []}
  def replace({visited, [_ | remain]}, value), do: {visited, [value | remain]}

  @doc """
  Returns a list of the elements in the CLL. The order of elements will match the 
  original list the CLL was created from.

  ## Examples

      iex> CLL.init([1,2,3])
      ...> |> CLL.next(2)
      ...> |> CLL.prev()
      ...> |> CLL.to_list()
      [1, 2, 3]
  """
  @spec to_list(cll) :: list
  def to_list({visited, remain}), do: visited |> Enum.reverse() |> Enum.concat(remain)
end
