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
      ...> |> CLL.prev()
      ...> |> CLL.value()
      4
  """

  @type cll :: {list, list}
  @type value :: any

  @spec init(list) :: cll
  def init(list), do: {[], list}

  @spec next(cll) :: cll
  def next({[], []}), do: {[], []}

  def next({visited, []}) do
    [a | remain] = Enum.reverse(visited)
    {[a], remain}
  end

  def next({visited, [a | remain]}), do: {[a] ++ visited, remain}

  @spec next(cll, number) :: cll
  def next(state, 0), do: state
  def next(state, 1), do: next(state)
  def next(state, offset) when offset < 0, do: prev(state, -offset)
  def next(state, offset), do: next(next(state), offset - 1)

  @spec prev(cll) :: cll
  def prev({[], []}), do: {[], []}
  def prev({[], remain}), do: {Enum.reverse(remain), []} |> prev()
  def prev({[a | visited], remain}), do: {visited, [a] ++ remain}

  @spec prev(cll, number) :: cll
  def prev(state, 0), do: state
  def prev(state, 1), do: prev(state)
  def prev(state, offset) when offset < 0, do: next(state, -offset)
  def prev(state, offset), do: prev(prev(state), offset - 1)

  @spec value(cll) :: cll
  @spec value(cll, number) :: cll
  def value(state, offset \\ 0)

  def value({[], []}, _), do: nil

  def value({_, remain} = state, offset) when offset >= length(remain),
    do: value(state, offset - len(state))

  def value({visited, _} = state, offset) when offset < -length(visited),
    do: value(state, offset + len(state))

  def value({visited, _}, offset) when offset < 0, do: Enum.at(visited, -offset - 1)
  def value({_, remain}, offset), do: Enum.at(remain, offset)

  @spec len(cll) :: non_neg_integer
  def len({visited, remain}), do: length(visited) + length(remain)

  @spec empty?(cll) :: boolean
  def empty?({[], []}), do: true
  def empty?(_), do: false

  @spec offset(cll) :: non_neg_integer
  def offset({visited, _}), do: length(visited)

  @spec done?(cll) :: boolean
  def done?({_, []}), do: true
  def done?(_), do: false

  @spec reset(cll) :: cll
  def reset({_, _} = state) do
    state |> to_list() |> init()
  end

  @spec remove(cll) :: cll
  def remove({[], []}), do: {[], []}
  def remove({visited, []}), do: {Enum.drop(visited, -1), []}
  def remove({visited, [_ | remain]}), do: {visited, remain}

  @spec insert(cll, any) :: cll
  def insert({visited, remain}, value), do: {[value | visited], remain}

  @spec replace(cll, any) :: cll
  def replace({[], []}, _), do: {[], []}
  def replace({visited, []}, value), do: {Enum.drop(visited, -1) ++ [value], []}
  def replace({visited, [_ | remain]}, value), do: {visited, [value | remain]}

  @spec to_list(cll) :: list
  def to_list({visited, remain}), do: visited |> Enum.reverse() |> Enum.concat(remain)
end
