defmodule HOL.Unification.GeneralTests do
  @moduledoc false
  require Record
  use ExUnit.Case
  import LoggerHelper
  import PrettyPrint
  import HOL.Data
  import HOL.Terms
  import HOL.Unification
  import HOL.Substitution
  import HOL.Data.Unification

  doctest HOL.Unification

  setup do
    set_logger_warning()
  end

  setup_all do
    set_logger_warning()
    i = mk_type(:i, [])
    ii = mk_type(i, [i])
    o = mk_type(:o, [])
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

  @doc """
  Writes the unification problem as a tptp problem to disk
  """
  def write_problem_to_file(input, state) do
    test_name =
      state[:test]
      |> to_string()
      |> String.slice(5, 99)

    if(not File.exists?("exported_problems/")) do
      File.mkdir("exported_problems")
    end

    problem = TPTPParser.unification_problem_to_tptp(input)
    File.write("exported_problems/#{test_name}.p", problem)
  end

  @doc """
  Checks the lengths of the results and the amount of aborted branches
  """
  def assert_result_lengths(
        unification_results(solutions: solutions, max_depth_reached_count: count),
        sol_length,
        max_depths_reached
      ) do
    assert max_depths_reached == nil || count == max_depths_reached
    assert sol_length == nil || length(solutions) == sol_length
  end

  @doc """
  Checks the lengths of the results, including the lengths of the subst and flexflex lists
  """
  def assert_result_lengths(
        unification_results(solutions: solutions) = res,
        sol_length,
        max_depths_reached,
        subst_length,
        flex_length
      ) do
    assert_result_lengths(res, sol_length, max_depths_reached)

    if sol_length > 0 do
      Enum.map(solutions, fn unification_solution(substitutions: subst, flexlist: flex) ->
        assert subst_length == nil or length(subst) == subst_length
        assert flex_length == nil or length(flex) == flex_length
      end)
    end
  end

  @doc """
  Asserts that the given substitutions make the left and right input equal
  """
  def check_substitutions(input, unification_results(solutions: sol)) do
    check_substitutions(input, sol)
  end

  def check_substitutions(input, solutions) when is_list(input) do
    case solutions do
      [] ->
        Enum.map(input, fn {l, r} -> assert l == r end)

      _ ->
        Enum.map(input, fn {l, r} -> check_substitutions({l, r}, solutions) end)
    end
  end

  def check_substitutions({input_left, input_right}, solutions) when is_list(solutions) do
    Enum.map(solutions, fn res ->
      case res do
        # If it's a result without flexflex cases, check the substitutions
        unification_solution(substitutions: substitutions, flexlist: []) ->
          new_left = subst(substitutions, input_left)
          new_right = subst(substitutions, input_right)
          assert pp_term(new_left) == pp_term(new_right)
          assert new_left == new_right

        # If it has flexflex cases, it can't be checked
        _ ->
          log_debug("Skipping result with non empty flex list")
      end
    end)
  end

  @doc """
  Checks if an unordered tuple is in a list
  """
  def has_pair?(list, {l, r}) do
    assert {l, r} in list or {r, l} in list
  end

  @doc """
  Checks if an ordered tuple is in a list
  """
  def has_ordered_elem?(list, elem) do
    assert elem in list
  end

  test "trivial_0", state do
    t_x = mk_free_var_term("x", state[:i])

    input = {t_x, t_x}
    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result))

    # Expects one result, without any substitutions or flexflex cases
    assert_result_lengths(result, 1, 0, 0, 0)
    check_substitutions(input, result)
  end

  test "trivial_1", state do
    t_x = mk_free_var_term("x", state[:i])
    t_f = mk_const_term("f", state[:ii])
    appl_fx = mk_appl_term(t_f, t_x)

    input = {appl_fx, appl_fx}
    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result))

    # Expects one result, without any substitutions or flexflex cases
    assert_result_lengths(result, 1, 0, 0, 0)
    check_substitutions(input, result)
  end

  test "trivial_2", state do
    v_x = mk_free_var("x", state[:i])
    t_x = mk_term(v_x)
    v_y = mk_free_var("y", state[:i])
    t_y = mk_term(v_y)
    t_f = mk_const_term("f", state[:ii])
    abstr_fx = mk_appl_term(t_f, t_x) |> mk_abstr_term(v_x)
    abstr_fy = mk_appl_term(t_f, t_y) |> mk_abstr_term(v_y)

    input = {abstr_fx, abstr_fy}
    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result))

    # Expects one result, without any substitutions or flexflex cases
    assert_result_lengths(result, 1, 0, 0, 0)
    check_substitutions(input, result)
  end

  test "wrong_types", state do
    t_x = mk_free_var_term("x", state[:i])
    t_z = mk_free_var_term("z", state[:ii])

    input = {t_x, t_z}
    result = unify(input)
    write_problem_to_file(input, state)
    log_notice(pp_res(result))

    # Expects no results
    assert_result_lengths(result, 0, 0)
  end

  test "decomposition_fx_fy", state do
    t_x = mk_free_var_term("x", state[:i])
    t_y = mk_free_var_term("y", state[:i])
    t_f = mk_const_term("f", state[:ii])
    appl_fx = mk_appl_term(t_f, t_x)
    appl_fy = mk_appl_term(t_f, t_y)

    input = {appl_fx, appl_fy}
    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result))

    # Expects one result with empty subst and one flexflex: {v_x, v_y}
    assert_result_lengths(result, 1, 0, 0, 1)

    flexflex = get_flexlist(Enum.at(get_solutions(result), 0))
    has_pair?(flexflex, {t_x, t_y})

    check_substitutions(input, result)
  end

  test "decomposition_gzx_gzy", state do
    v_z = mk_free_var("z", state[:ii])
    t_z = mk_term(v_z)
    t_x = mk_free_var_term("x", state[:i])
    t_y = mk_free_var_term("y", state[:i])
    t_g = mk_const_term("g", state[:ii_ii])
    abstr_gzx = mk_appl_term(t_g, t_z) |> mk_appl_term(t_x) |> mk_abstr_term(v_z)
    abstr_gzy = mk_appl_term(t_g, t_z) |> mk_appl_term(t_y) |> mk_abstr_term(v_z)

    input = {abstr_gzx, abstr_gzy}
    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result))

    # Expects one result with empty subst and one flexflex
    assert_result_lengths(result, 1, 0, 0, 1)

    flexflex = get_flexlist(Enum.at(get_solutions(result), 0))

    has_pair?(
      flexflex,
      {mk_abstr_term(t_x, mk_free_var("", state[:ii])),
       mk_abstr_term(t_y, mk_free_var("", state[:ii]))}
    )

    check_substitutions(input, result)
  end

  test "decomposition_abstr", state do
    v_z = mk_free_var("z", state[:ii])
    t_z = mk_term(v_z)
    t_x = mk_free_var_term("x", state[:i])
    t_c = mk_const_term("c", state[:i])

    abstr_1x = mk_appl_term(t_z, t_x) |> mk_abstr_term(v_z)
    abstr_1c = mk_appl_term(t_z, t_c) |> mk_abstr_term(v_z)

    input = {abstr_1x, abstr_1c}
    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result))

    # Expects one result with one subst and empty flexflex
    assert_result_lengths(result, 1, 0, 1, 0)

    check_substitutions(input, result)
  end

  test "constant_unequal_heads", state do
    t_c = mk_const_term("c", state[:i])
    t_d = mk_const_term("d", state[:i])

    result = unify({t_c, t_d})
    log_notice(pp_res(result))

    # Expects no results
    assert_result_lengths(result, 0, 0)
  end

  test "flexflex_0", state do
    t_x = mk_free_var_term("x", state[:i])
    t_y = mk_free_var_term("y", state[:i])

    input = {t_y, t_x}
    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result))

    # Expects one result with empty subst and one flexflex: {t_x, t_y}
    assert_result_lengths(result, 1, 0, 0, 1)

    flexflex = get_flexlist(Enum.at(get_solutions(result), 0))
    has_pair?(flexflex, {t_x, t_y})
    check_substitutions(input, result)
  end

  test "flexflex_1", state do
    t_x = mk_free_var_term("x", state[:i])
    t_z = mk_free_var_term("z", state[:ii])
    t_c = mk_const_term("c", state[:i])
    appl_zc = mk_appl_term(t_z, t_c)

    input = {t_x, appl_zc}
    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result))

    # Expects one result with empty subst and one flexflex: {t_x, appl_zc}
    assert_result_lengths(result, 1, 0, 0, 1)

    flexflex = get_flexlist(Enum.at(get_solutions(result), 0))
    has_pair?(flexflex, input)
    check_substitutions(input, result)
  end

  test "bind_0", state do
    v_x = mk_free_var("x", state[:i])
    t_x = mk_term(v_x)
    t_y = mk_free_var_term("y", state[:i])
    t_z = mk_free_var_term("z", state[:ii])
    t_g = mk_const_term("g", state[:ii_ii])
    appl_gzy = t_g |> mk_appl_term(t_z) |> mk_appl_term(t_y)

    input = {t_x, appl_gzy}
    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result))

    # Expects one result with empty flexflex and one subst: {v_x, appl_gzy}
    assert_result_lengths(result, 1, 0, 1, 0)

    subst = get_substitutions(Enum.at(get_solutions(result), 0))

    has_ordered_elem?(subst, mk_substitution(v_x, appl_gzy))
    check_substitutions(input, result)
  end

  test "bind_1", state do
    t_x = mk_free_var_term("x", state[:i])
    t_z = mk_free_var_term("z", state[:ii])
    t_g = mk_const_term("g", state[:ii_ii])
    appl_gzx = t_g |> mk_appl_term(t_z) |> mk_appl_term(t_x)

    input = {t_x, appl_gzx}
    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result))

    # Expects no results
    assert_result_lengths(result, 0, 0)
    check_substitutions(input, result)
  end

  test "bind_swap_0", state do
    t_x = mk_free_var_term("x", state[:i])
    t_y = mk_free_var_term("y", state[:i])
    t_z = mk_free_var_term("z", state[:ii])
    t_g = mk_const_term("g", state[:ii_ii])
    appl_gzy = t_g |> mk_appl_term(t_z) |> mk_appl_term(t_y)

    assert unify({t_x, appl_gzy}) == unify({appl_gzy, t_x})
  end

  test "bind_swap_1", state do
    t_x = mk_free_var_term("x", state[:i])
    t_z = mk_free_var_term("z", state[:ii])
    t_g = mk_const_term("g", state[:ii_ii])
    appl_gzx = t_g |> mk_appl_term(t_z) |> mk_appl_term(t_x)

    assert unify({t_x, appl_gzx}) == unify({appl_gzx, t_x})
  end

  test "flexrigid_0", state do
    t_c = mk_const_term("c", state[:i])
    appl_zc = mk_appl_term(mk_free_var_term("z", state[:ii]), t_c)
    appl_fc = mk_appl_term(mk_const_term("f", state[:ii]), t_c)

    input = {appl_zc, appl_fc}
    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result))

    # Expects two results each with zero flexflex cases and one substitution.
    assert_result_lengths(result, 2, 0, 1, 0)

    check_substitutions(input, result)
  end

  test "flexrigid_swap_0", state do
    t_c = mk_const_term("c", state[:i])
    appl_zc = mk_appl_term(mk_free_var_term("z", state[:ii]), t_c)
    appl_fc = mk_appl_term(mk_const_term("f", state[:ii]), t_c)

    assert unify({appl_zc, appl_fc}) == unify({appl_fc, appl_zc})
  end

  test "flexbound_0", state do
    v_h = mk_free_var("h", state[:iii])
    t_h = mk_term(v_h)
    v_x = mk_free_var("x", state[:i])
    t_x = mk_term(v_x)
    v_y = mk_free_var("y", state[:i])
    t_y = mk_term(v_y)

    abstr_hxy =
      mk_appl_term(t_h, t_x) |> mk_appl_term(t_y) |> mk_abstr_term(v_y) |> mk_abstr_term(v_x)

    abstr_xy_x = t_x |> mk_abstr_term(v_y) |> mk_abstr_term(v_x)

    input = {abstr_hxy, abstr_xy_x}
    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result))

    # Expects one result with zero flexflex cases and one substitution.
    assert_result_lengths(result, 1, 0, 1, 0)

    subst = get_substitutions(Enum.at(get_solutions(result), 0))
    has_ordered_elem?(subst, mk_substitution(v_h, abstr_xy_x))

    check_substitutions(input, result)
  end

  test "test_xaa_faa", state do
    t_x = mk_free_var_term("x", state[:iii])
    t_a = mk_const_term("a", state[:i])
    t_f = mk_const_term("f", state[:iii])

    xaa = mk_appl_term(mk_appl_term(t_x, t_a), t_a)
    faa = mk_appl_term(mk_appl_term(t_f, t_a), t_a)

    input = {xaa, faa}
    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result))

    # Expects nine results each with zero flexflex cases.
    assert_result_lengths(result, 9, 0, 1, 0)

    check_substitutions(input, result)
  end

  test "test_xab_fba", state do
    t_a = mk_const_term("a", state[:i])
    t_b = mk_const_term("b", state[:i])
    t_x = mk_free_var_term("x", state[:iii])
    t_f = mk_const_term("f", state[:iii])

    xab = mk_appl_term(mk_appl_term(t_x, t_a), t_b)
    fba = mk_appl_term(mk_appl_term(t_f, t_b), t_a)

    input = {xab, fba}
    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result))

    # Expects four results each with zero flexflex cases.
    assert_result_lengths(result, 4, 0, 1, 0)

    check_substitutions(input, result)
  end

  test "test_xab_fcd", state do
    t_a = mk_const_term("a", state[:i])
    t_b = mk_const_term("b", state[:i])
    t_c = mk_const_term("c", state[:i])
    t_d = mk_const_term("d", state[:i])
    t_x = mk_free_var_term("x", state[:iii])
    t_f = mk_const_term("f", state[:iii])

    xab = mk_appl_term(mk_appl_term(t_x, t_a), t_b)
    fcd = mk_appl_term(mk_appl_term(t_f, t_c), t_d)

    input = {xab, fcd}
    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result))

    # Expects four results each with zero flexflex cases.
    assert_result_lengths(result, 1, 0, 1, 0)

    check_substitutions(input, result)
  end

  test "test_xfa_fxa_10", state do
    t_x = mk_free_var_term("x", state[:ii])
    t_f = mk_const_term("f", state[:ii])
    t_a = mk_const_term("a", state[:i])

    xfa = mk_appl_term(t_x, mk_appl_term(t_f, t_a))
    fxa = mk_appl_term(t_f, mk_appl_term(t_x, t_a))

    depth = 10
    input = {xfa, fxa}
    write_problem_to_file(input, state)
    result = unify(input, true, depth)
    log_notice(pp_res(result))

    # Expects depth - 1 results
    assert_result_lengths(result, depth - 1, nil, 1, 0)

    check_substitutions(input, result)
  end

  test "test_xfa_fxa_30", state do
    t_x = mk_free_var_term("x", state[:ii])
    t_f = mk_const_term("f", state[:ii])
    t_a = mk_const_term("a", state[:i])

    xfa = mk_appl_term(t_x, mk_appl_term(t_f, t_a))
    fxa = mk_appl_term(t_f, mk_appl_term(t_x, t_a))

    depth = 30
    input = {xfa, fxa}
    write_problem_to_file(input, state)
    result = unify(input, true, depth)
    log_notice(pp_res(result))

    # Expects depth - 1 results
    assert_result_lengths(result, depth - 1, nil, 1, 0)

    check_substitutions(input, result)
  end

  test "test_xfa_fxa_and_x_abstr_1", state do
    t_x = mk_free_var_term("x", state[:ii])
    t_f = mk_const_term("f", state[:ii])
    t_a = mk_const_term("a", state[:i])
    v_y = mk_free_var("y", state[:i])

    xfa = t_x |> mk_appl_term(mk_appl_term(t_f, t_a))
    fxa = t_f |> mk_appl_term(mk_appl_term(t_x, t_a))

    abstr_1 = mk_term(v_y) |> mk_abstr_term(v_y)

    input = [{xfa, fxa}, {t_x, abstr_1}]
    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result))

    assert_result_lengths(result, 1, 0, 1, 0)

    check_substitutions(input, result)
  end

  test "test_xfa_fxa_and_x_abstr_f1", state do
    t_x = mk_free_var_term("x", state[:ii])
    t_f = mk_const_term("f", state[:ii])
    t_a = mk_const_term("a", state[:i])
    v_y = mk_free_var("y", state[:i])

    xfa = t_x |> mk_appl_term(mk_appl_term(t_f, t_a))
    fxa = t_f |> mk_appl_term(mk_appl_term(t_x, t_a))

    abstr_f1 = t_f |> mk_appl_term(mk_term(v_y)) |> mk_abstr_term(v_y)

    input = [{xfa, fxa}, {t_x, abstr_f1}]
    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result))

    # Expects 1 result
    assert_result_lengths(result, 1, 0)

    check_substitutions(input, result)
  end

  test "test_x_y_and_x_c", state do
    v_x = mk_free_var("x", state[:i])
    t_x = mk_term(v_x)
    v_y = mk_free_var("y", state[:i])
    t_y = mk_term(v_y)
    t_c = mk_const_term("c", state[:i])

    input = [{t_x, t_y}, {t_x, t_c}]
    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result))

    # Expects 1 result with substitutions: x <- c, y <- c
    assert_result_lengths(result, 1, 0, 2, 0)

    subst = get_substitutions(Enum.at(get_solutions(result), 0))
    has_ordered_elem?(subst, mk_substitution(v_x, t_c))
    has_ordered_elem?(subst, mk_substitution(v_y, t_c))

    check_substitutions(input, result)
  end

  test "test_x_c_and_x_y", state do
    v_x = mk_free_var("x", state[:i])
    t_x = mk_term(v_x)
    v_y = mk_free_var("y", state[:i])
    t_y = mk_term(v_y)
    t_c = mk_const_term("c", state[:i])

    input = [{t_x, t_c}, {t_x, t_y}]
    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result))

    # Expects 1 result with substitutions: x <- c, y <- c
    assert_result_lengths(result, 1, 0, 2, 0)

    subst = get_substitutions(Enum.at(get_solutions(result), 0))
    has_ordered_elem?(subst, mk_substitution(v_x, t_c))
    has_ordered_elem?(subst, mk_substitution(v_y, t_c))

    check_substitutions(input, result)
  end
end
