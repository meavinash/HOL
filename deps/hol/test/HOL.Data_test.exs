defmodule HOL.Data.Tests do
  @moduledoc false
  use ExUnit.Case
  import LoggerHelper
  import HOL.Data

  doctest HOL.Data

  setup do
    set_logger_warning()
  end

  setup_all do
    i = mk_type(:i)
    ii = mk_type(i, [i])
    o = mk_type(:o)
    io = mk_type(o, [i])
    ii_ii = mk_type(i, [ii, i])
    iii = mk_type(i, [i, i])

    {:ok,
     %{
       i: i,
       ii: ii,
       ii_ii: ii_ii,
       iii: iii,
       o: o,
       io: io
     }}
  end

  test "basic_types", state do
    assert get_goal_type(state[:i]) == :i
    assert get_arg_types(state[:i]) == []
    assert get_goal_type(state[:ii]) == :i
    assert get_arg_types(state[:ii]) == [state[:i]]
    assert get_goal_type(state[:ii_ii]) == :i
    assert get_arg_types(state[:ii_ii]) == [state[:ii], state[:i]]
    assert get_goal_type(state[:io]) == :o
    assert get_arg_types(state[:io]) == [state[:i]]
  end

  test "type_creation_0", state do
    type = mk_type(state[:ii], [state[:ii]])
    assert get_goal_type(type) == :i
    assert get_arg_types(type) == [state[:ii], state[:i]]
  end

  test "type_creation_1", state do
    type = mk_type(state[:ii_ii], [state[:ii_ii]])
    assert get_goal_type(type) == :i
    assert get_arg_types(type) == [state[:ii_ii], state[:ii], state[:i]]
  end
end
