# CLL - Circular Linked List for Elixir

[![Build Status](https://travis-ci.org/pkinney/cll_ex.svg?branch=master)](https://travis-ci.org/pkinney/cll_ex)
[![Hex.pm](https://img.shields.io/hexpm/v/cll_ex.svg)](https://hex.pm/packages/cll_ex)

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

## Installation

```elixir
defp deps do
  [{:cll, "~> 0.1.0"}]
end
```

## Usage

**[Full Documentation](https://hexdocs.pm/cll/CLL.html)**

A list can be created by passing a List to the `init/2` function along with
an boolean defining if the resulting Doubly-Linked-List is circular or not.
Once created, you can traverse through the list one or more steps at a time.

```elixir
list = [1, 2, 3, 4, 5] |> CLL.init()
list |> CLL.value() # => 1
list |> CLL.next() |> CLL.next() |> CLL.value() # => 3
list |> CLL.next(3) |> CLL.prev(2) |> CLL.next(7) CLL.value() # => 4
```

You can also modify the list by inserting, replacing, or removing the current
element.  Finally, if desired, you can convert the CLL back into a List.

```elixir
list = [1, 2, 3, 4, 5] |> CLL.init()
list |> CLL.next(2) |> CLL.remove() |> CLL.to_list() # => [1, 2, 4, 5]
list |> CLL.prev(2)|> CLL.replace(:foo)|> CLL.to_list() #=> [1, 2, 3, :foo, 5]
list |> CLL.next(3) |> CLL.insert(3.5) |> CLL.insert(3.75) |> CLL.to_list() # => [1, 2, 3, 3.5, 3.75, 4, 5]
```

To help with use cases where iterating through the list once is useful, CLL
keeps track of the "start" of the list so that you can determine when a list
has been fully traversed.  A list can also be reset to the initial start
position at any time.

```elixir
list = [1, 2, 3, 4, 5] |> CLL.init()
list |> CLL.next(3)|> CLL.prev(2) |> CLL.next() |> CLL.offset() # => 2
list |> CLL.next(5) |> CLL.done?() # => true
list |> CLL.next(4) |> CLL.reset() |> CLL.value() # => 1
```