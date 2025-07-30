Code.require_file("test/HOL.Unification.General_test.exs")

defmodule HOL.Unification.ChurchNumeralTests do
  @moduledoc false
  use ExUnit.Case
  import LoggerHelper
  import PrettyPrint
  import HOL.Data
  import HOL.Terms
  import HOL.Unification
  import HOL.ChurchNumerals
  import HOL.Unification.GeneralTests
  import HOL.Data.Unification

  setup do
    set_logger_warning()
  end

  setup_all do
    set_logger_warning()
    # Define Types used in Tests
    i = mk_type(:i, [])
    ii = mk_type(i, [i])
    ii_ii = mk_type(i, [ii, i])

    {:ok,
     %{
       i: i,
       ii: ii,
       ii_ii: ii_ii
     }}
  end

  test "succ(x)=2", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {succ(t_x), mk_num(2)}
    ]

    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result, true))

    assert_result_lengths(result, 1, 0, 1, 0)

    check_substitutions(input, result)

    s = get_substitutions(Enum.at(get_solutions(result), 0))
    has_ordered_elem?(s, mk_substitution(v_x, mk_num(1)))
  end

  test "succ(x)=5", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {succ(t_x), mk_num(5)}
    ]

    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result, true))

    assert_result_lengths(result, 1, 0, 1, 0)

    check_substitutions(input, result)

    s = get_substitutions(Enum.at(get_solutions(result), 0))
    has_ordered_elem?(s, mk_substitution(v_x, mk_num(4)))
  end

  test "succ(x)=0", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {succ(t_x), mk_num(0)}
    ]

    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result, true))

    assert_result_lengths(result, 0, 0)
  end

  test "x+1=2", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {plus(t_x, mk_num(1)), mk_num(2)}
    ]

    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result, true))

    assert_result_lengths(result, 1, 0, 1, 0)

    check_substitutions(input, result)

    s = get_substitutions(Enum.at(get_solutions(result), 0))
    has_ordered_elem?(s, mk_substitution(v_x, mk_num(1)))
  end

  test "1+x=2", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {plus(mk_num(1), t_x), mk_num(2)}
    ]

    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result, true))

    assert_result_lengths(result, 1, 0, 1, 0)

    check_substitutions(input, result)

    s = get_substitutions(Enum.at(get_solutions(result), 0))
    has_ordered_elem?(s, mk_substitution(v_x, mk_num(1)))
  end

  test "x+4=7", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {plus(t_x, mk_num(4)), mk_num(7)}
    ]

    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result, true))

    assert_result_lengths(result, 1, 0, 1, 0)

    check_substitutions(input, result)

    s = get_substitutions(Enum.at(get_solutions(result), 0))
    has_ordered_elem?(s, mk_substitution(v_x, mk_num(3)))
  end

  test "4+x=7", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {plus(mk_num(4), t_x), mk_num(7)}
    ]

    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result, true))

    assert_result_lengths(result, 1, 0, 1, 0)

    check_substitutions(input, result)

    s = get_substitutions(Enum.at(get_solutions(result), 0))
    has_ordered_elem?(s, mk_substitution(v_x, mk_num(3)))
  end

  test "4+x=3", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {plus(mk_num(4), t_x), mk_num(3)}
    ]

    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result, true))

    assert_result_lengths(result, 0, 0)
  end

  test "3*x=15", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {mult(mk_num(3), t_x), mk_num(15)}
    ]

    write_problem_to_file(input, state)
    result = unify(input, true, 20)
    log_notice(pp_res(result, true))

    assert_result_lengths(result, 1, 0, 1, 0)

    check_substitutions(input, result)

    s = get_substitutions(Enum.at(get_solutions(result), 0))
    has_ordered_elem?(s, mk_substitution(v_x, mk_num(5)))
  end

  test "x*3=15", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {mult(t_x, mk_num(3)), mk_num(15)}
    ]

    write_problem_to_file(input, state)
    result = unify(input, true, 20)
    log_notice(pp_res(result, true))

    assert_result_lengths(result, 1, 0, 1, 0)

    check_substitutions(input, result)

    s = get_substitutions(Enum.at(get_solutions(result), 0))
    has_ordered_elem?(s, mk_substitution(v_x, mk_num(5)))
  end

  test "x*1=4", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {mult(t_x, mk_num(1)), mk_num(4)}
    ]

    write_problem_to_file(input, state)
    result = unify(input, true, 20)
    log_notice(pp_res(result, true))

    assert_result_lengths(result, 1, 0, 1, 0)

    check_substitutions(input, result)

    s = get_substitutions(Enum.at(get_solutions(result), 0))
    has_ordered_elem?(s, mk_substitution(v_x, mk_num(4)))
  end

  test "1*x=4", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {mult(mk_num(1), t_x), mk_num(4)}
    ]

    write_problem_to_file(input, state)
    result = unify(input, true, 20)
    log_notice(pp_res(result, true))

    assert_result_lengths(result, 1, 0, 1, 0)

    check_substitutions(input, result)

    s = get_substitutions(Enum.at(get_solutions(result), 0))
    has_ordered_elem?(s, mk_substitution(v_x, mk_num(4)))
  end

  test "0*x=0", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {mult(mk_num(0), t_x), mk_num(0)}
    ]

    write_problem_to_file(input, state)
    result = unify(input, true, 20)
    log_notice(pp_res(result, true))

    # Gives the empty result
    assert_result_lengths(result, 1, 0, 0, 0)

    check_substitutions(input, result)
  end

  test "x*0=0", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {mult(t_x, mk_num(0)), mk_num(0)}
    ]

    write_problem_to_file(input, state)
    result = unify(input, true, 100)
    log_notice(pp_res(result, true))

    # Gives many results (each number once)
    assert_result_lengths(result, nil, nil, 1, 0)

    check_substitutions(input, result)
  end

  test "x*10=1000", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {mult(t_x, mk_num(10)), mk_num(1000)}
    ]

    write_problem_to_file(input, state)
    result = unify(input, true, 1000)
    log_notice(pp_res(result, true))

    assert_result_lengths(result, 1, 0, 1, 0)

    check_substitutions(input, result)

    s = get_substitutions(Enum.at(get_solutions(result), 0))
    has_ordered_elem?(s, mk_substitution(v_x, mk_num(100)))
  end

  test "x*x=0", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {mult(t_x, t_x), mk_num(0)}
    ]

    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result, true))

    # Gives one result (x=0)
    assert_result_lengths(result, 1, 0, 1, 0)

    check_substitutions(input, result)

    s = get_substitutions(Enum.at(get_solutions(result), 0))
    has_ordered_elem?(s, mk_substitution(v_x, mk_num(0)))
  end

  test "x*x=1", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {mult(t_x, t_x), mk_num(1)}
    ]

    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result, true))

    assert_result_lengths(result, 1, 0, 1, 0)

    check_substitutions(input, result)

    s = get_substitutions(Enum.at(get_solutions(result), 0))
    has_ordered_elem?(s, mk_substitution(v_x, mk_num(1)))
  end

  test "x*y=4", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)
    v_y = mk_free_var("y", state[:ii_ii])
    t_y = mk_term(v_y)

    input = [
      {mult(t_x, t_y), mk_num(4)}
    ]

    write_problem_to_file(input, state)
    result = unify(input, true, 40)
    log_notice(pp_res(result, true))

    # 1*4=4 & 4*1=4 & 2*2=4
    assert_result_lengths(result, 3, nil, 2, 0)

    check_substitutions(input, result)
  end

  test "x*5=30", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {mult(t_x, mk_num(5)), mk_num(30)}
    ]

    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result, true))

    assert_result_lengths(result, 1, 0, 1, 0)

    check_substitutions(input, result)

    s = get_substitutions(Enum.at(get_solutions(result), 0))
    has_ordered_elem?(s, mk_substitution(v_x, mk_num(6)))
  end

  test "x*x=16", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {mult(t_x, t_x), mk_num(16)}
    ]

    write_problem_to_file(input, state)
    result = unify(input, true, 20)
    log_notice(pp_res(result, true))

    assert_result_lengths(result, 1, 0, 1, 0)

    check_substitutions(input, result)

    s = get_substitutions(Enum.at(get_solutions(result), 0))
    has_ordered_elem?(s, mk_substitution(v_x, mk_num(4)))
  end

  test "x*x=6", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)

    input = [
      {mult(t_x, t_x), mk_num(6)}
    ]

    write_problem_to_file(input, state)
    result = unify(input)
    log_notice(pp_res(result, true))

    assert_result_lengths(result, 0, 0)
  end

  test "xy+z=21, x+y+z=10, xz+y=9", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)
    v_y = mk_free_var("y", state[:ii_ii])
    t_y = mk_term(v_y)
    v_z = mk_free_var("z", state[:ii_ii])
    t_z = mk_term(v_z)

    input = [
      {plus(mult(t_x, t_y), t_z), mk_num(21)},
      {plus(plus(t_x, t_y), t_z), mk_num(10)},
      {plus(mult(t_x, t_z), t_y), mk_num(9)}
    ]

    write_problem_to_file(input, state)
    result = unify(input, true, 50)
    log_notice(pp_res(result, true))

    # x=4, y=5, z=1
    assert_result_lengths(result, 2, nil, 3, 0)

    check_substitutions(input, result)
  end

  test "xy=20, x+y=9", state do
    # x is unknown number
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)
    v_y = mk_free_var("y", state[:ii_ii])
    t_y = mk_term(v_y)

    input = [
      {mult(t_x, t_y), mk_num(20)},
      {plus(t_x, t_y), mk_num(9)}
    ]

    write_problem_to_file(input, state)
    result = unify(input, true, 20)
    log_notice(pp_res(result, true))

    # x=4, y=5 (or swapped)
    assert_result_lengths(result, 2, nil, 2, 0)

    check_substitutions(input, result)
  end

  test "3x+1y+2z=16, 1x+2y+5z=14, 5x+3y+1z=22", state do
    v_x = mk_free_var("x", state[:ii_ii])
    t_x = mk_term(v_x)
    v_y = mk_free_var("y", state[:ii_ii])
    t_y = mk_term(v_y)
    v_z = mk_free_var("z", state[:ii_ii])
    t_z = mk_term(v_z)

    input = [
      {plus(mult(mk_num(3), t_x), plus(mult(mk_num(1), t_y), mult(mk_num(2), t_z))), mk_num(16)},
      {plus(mult(mk_num(1), t_x), plus(mult(mk_num(2), t_y), mult(mk_num(5), t_z))), mk_num(14)},
      {plus(mult(mk_num(5), t_x), plus(mult(mk_num(3), t_y), mult(mk_num(1), t_z))), mk_num(22)}
    ]

    write_problem_to_file(input, state)
    result = unify(input, true, 20)
    log_notice(pp_res(result, true))

    # x=4, y=0, z=2
    assert_result_lengths(result, 1, 0, 3, 0)

    check_substitutions(input, result)
  end

  test("succ", state) do
    # Variable that takes a number and gives a number
    t_x = mk_free_var_term("x", mk_type(state[:ii_ii], [state[:ii_ii]]))

    input = [
      {mk_appl_term(t_x, mk_num(0)), mk_num(1)},
      {mk_appl_term(t_x, mk_num(1)), mk_num(2)}
    ]

    write_problem_to_file(input, state)

    result = unify(input, true, 6)

    # set_logger_notice()
    log_notice(pp_res(result), true)

    assert_result_lengths(result, nil, nil, 1, 0)

    check_substitutions(input, result)
  end

  test("succ_first", state) do
    # Variable that takes a number and gives a number
    t_x = mk_free_var_term("x", mk_type(state[:ii_ii], [state[:ii_ii]]))

    input = [
      {mk_appl_term(t_x, mk_num(0)), mk_num(1)},
      {mk_appl_term(t_x, mk_num(1)), mk_num(2)}
    ]

    write_problem_to_file(input, state)
    result = unify(input, false, 6)

    # set_logger_notice()
    log_notice(pp_res(result), true)

    assert_result_lengths(result, 1, nil, 1, 0)

    check_substitutions(input, result)
  end
end
