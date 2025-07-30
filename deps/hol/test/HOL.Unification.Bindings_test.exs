defmodule HOL.Unification.Bindings.Tests do
  @moduledoc false
  use ExUnit.Case
  import LoggerHelper
  import HOL.Data
  import HOL.Unification.Bindings

  doctest HOL.Unification.Bindings

  setup do
    set_logger_warning()
  end

  setup_all do
    i = mk_type(:i, [])
    ii = mk_type(i, [i])
    o = mk_type(:o, [])
    io = mk_type(o, [i])
    ii_ii = mk_type(i, [ii, i])

    {:ok,
     %{
       i: i,
       ii: ii,
       ii_ii: ii_ii,
       o: o,
       io: io
     }}
  end

  test "arity_0", state do
    assert arity(state[:i]) == 0
    assert arity(state[:o]) == 0
  end

  test "arity_1", state do
    assert arity(state[:ii]) == 1
    assert arity(state[:io]) == 1
  end

  test "arity_2", state do
    assert arity(state[:ii_ii]) == 2
  end

  test "arity_3", state do
    assert arity(mk_type(state[:ii_ii], [state[:ii_ii]])) == 3
  end

  defp test_imitation_general(typeA, typeB, expectedA, expectedB) do
    v_x = mk_free_var("x", typeA)
    v_y = mk_const("y", typeB)

    [substitution(fvar: left, term: right) = s | []] = generic_binding(v_x, v_y, [:imitation])

    assert left == v_x
    assert get_head(right) == v_y
    assert length(get_bvars(right)) == expectedA
    assert length(get_args(right)) == expectedB
    assert get_head(right) == v_y
    {v_x, v_y, s}
  end

  defp test_projection_general(typeA, typeB, expected_results, expected_bVars \\ 0) do
    v_x = mk_free_var("x", typeA)
    v_y = mk_const("y", typeB)

    results = generic_binding(v_x, v_y, [:projection])

    assert length(results) == expected_results

    Enum.map(results, fn substitution(fvar: left, term: right) ->
      assert left == v_x
      assert length(get_bvars(right)) == expected_bVars
      right_head = get_head(right)
      assert Enum.member?(get_bvars(right), right_head)
    end)
  end

  test "imitation_binding_0_0", state do
    test_imitation_general(state[:i], state[:o], 0, 0)
  end

  test "imitation_binding_0_1", state do
    test_imitation_general(state[:i], state[:io], 0, 1)
  end

  test "imitation_binding_1_0", state do
    test_imitation_general(state[:ii], state[:o], 1, 0)
  end

  test "imitation_binding_1_1", state do
    test_imitation_general(state[:ii], state[:io], 1, 1)
  end

  test "imitation_binding_2_0", state do
    test_imitation_general(state[:ii_ii], state[:i], 2, 0)
  end

  test "imitation_binding_2_1", state do
    test_imitation_general(state[:ii_ii], state[:io], 2, 1)
  end

  test "imitation_binding_2_2", state do
    test_imitation_general(state[:ii_ii], state[:ii_ii], 2, 2)
  end

  test "imitation_binding_0_2", state do
    test_imitation_general(state[:i], state[:ii_ii], 0, 2)
  end

  test "imitation_binding_1_2", state do
    test_imitation_general(state[:io], state[:ii_ii], 1, 2)
  end

  test "projection_binding_i-o", state do
    test_projection_general(state[:i], state[:o], 0)
  end

  test "projection_binding_i-i", state do
    test_projection_general(state[:i], state[:i], 0)
  end

  test "projection_binding_i-io", state do
    test_projection_general(state[:i], state[:io], 0)
  end

  test "projection_binding_i-ii", state do
    test_projection_general(state[:i], state[:ii], 0)
  end

  test "projection_binding_ii-o", state do
    test_projection_general(state[:ii], state[:o], 0)
  end

  test "projection_binding_ii-i", state do
    test_projection_general(state[:ii], state[:i], 1, 1)
  end

  test "projection_binding_ii-io", state do
    test_projection_general(state[:ii], state[:io], 0)
  end

  test "projection_binding_ii-ii", state do
    test_projection_general(state[:ii], state[:ii], 1, 1)
  end

  test "projection_binding_ii_ii-i", state do
    test_projection_general(state[:ii_ii], state[:i], 2, 2)
  end

  test "projection_binding_ii_ii-io", state do
    test_projection_general(state[:ii_ii], state[:io], 0)
  end

  test "projection_binding_ii_ii-ii", state do
    test_projection_general(state[:ii_ii], state[:ii], 2, 2)
  end

  test "projection_binding_ii_ii-ii_ii", state do
    test_projection_general(state[:ii_ii], state[:ii_ii], 2, 2)
  end

  test "projection_binding_i-ii_ii", state do
    test_projection_general(state[:i], state[:ii_ii], 0)
  end

  test "projection_binding_io-ii_ii", state do
    test_projection_general(state[:io], state[:ii_ii], 1, 1)
  end
end
