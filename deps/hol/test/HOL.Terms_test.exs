defmodule HOL.Terms.Tests do
  @moduledoc false
  use ExUnit.Case
  import LoggerHelper
  import PrettyPrint
  import HOL.Data
  import HOL.Terms

  doctest HOL.Terms

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
  Special function that returns a term with a bvar as head of type i
  """
  def mk_bvar_term_i(num) when num > 0 do
    hol_term(
      bvars: [],
      head: mk_bound_var(num, mk_type(:i)),
      args: [],
      type: mk_type(:i),
      fvars: [],
      max_num: 0
    )
  end

  @doc """
  Special function that returns a term with a bvar as head of type i -> i
  """
  def mk_bvar_term_ii(num) when num > 1 do
    hol_term(
      bvars: [mk_bound_var(1, mk_type(:i))],
      head: mk_bound_var(num, mk_type(:i, [mk_type(:i)])),
      args: [mk_bvar_term_i(1)],
      type: mk_type(:i, [mk_type(:i)]),
      fvars: [],
      max_num: 1
    )
  end

  @doc """
  Special function that returns a term with a bvar as head of type (i -> i) -> i -> i
  """
  def mk_bvar_term_ii_ii(num) when num > 3 do
    hol_term(
      bvars: [mk_bound_var(3, mk_type(:i, [mk_type(:i)])), mk_bound_var(2, mk_type(:i))],
      head: mk_bound_var(num, mk_type(:i, [mk_type(:i, [mk_type(:i)]), mk_type(:i)])),
      args: [mk_bvar_term_ii(3), mk_bvar_term_i(2)],
      type: mk_type(:i, [mk_type(:i, [mk_type(:i)]), mk_type(:i)]),
      fvars: [],
      max_num: 3
    )
  end

  test "basic_free_var_term", state do
    v_x = mk_free_var("x", state[:i])
    t_x = mk_term(v_x)

    assert get_bvars(t_x) == []
    assert get_head(t_x) == v_x
    assert get_args(t_x) == []
    assert get_term_type(t_x) == get_type(v_x)
    assert get_fvars(t_x) == [v_x]
    assert get_max_num(t_x) == 0
  end

  test "basic_const_term", state do
    c_c = mk_const("c", state[:i])
    t_c = mk_term(c_c)

    assert get_bvars(t_c) == []
    assert get_head(t_c) == c_c
    assert get_args(t_c) == []
    assert get_term_type(t_c) == get_type(c_c)
    assert get_fvars(t_c) == []
    assert get_max_num(t_c) == 0
  end

  test "eta_free_var_term_0", state do
    v_z = mk_free_var("z", state[:ii])
    t_z = mk_term(v_z)

    assert length(get_bvars(t_z)) == 1
    assert get_head(t_z) == v_z

    assert get_args(t_z) == [mk_bvar_term_i(1)]

    assert get_term_type(t_z) == get_type(v_z)
    assert get_fvars(t_z) == [v_z]
    assert get_max_num(t_z) == 1
  end

  test "eta_const_term_0", state do
    c_f = mk_const("f", state[:ii])
    t_f = mk_term(c_f)

    assert length(get_bvars(t_f)) == 1
    assert get_head(t_f) == c_f

    assert get_args(t_f) == [mk_bvar_term_i(1)]

    assert get_term_type(t_f) == get_type(c_f)
    assert get_fvars(t_f) == []
    assert get_max_num(t_f) == 1
  end

  test "eta_free_var_term_1", state do
    v_u = mk_free_var("u", state[:ii_ii])
    t_u = mk_term(v_u)

    assert length(get_bvars(t_u)) == 2
    assert get_head(t_u) == v_u
    assert length(get_args(t_u)) == 2
    assert Enum.at(get_args(t_u), 0) == mk_bvar_term_ii(3)
    assert Enum.at(get_args(t_u), 1) == mk_bvar_term_i(2)
    assert get_term_type(t_u) == get_type(v_u)
    assert get_fvars(t_u) == [v_u]
    assert get_max_num(t_u) == 3
  end

  test "eta_long_const_term_1", state do
    c_g = mk_const("g", state[:ii_ii])
    t_g = mk_term(c_g)

    assert length(get_bvars(t_g)) == 2
    assert get_head(t_g) == c_g
    assert length(get_args(t_g)) == 2
    assert Enum.at(get_args(t_g), 0) == mk_bvar_term_ii(3)
    assert Enum.at(get_args(t_g), 1) == mk_bvar_term_i(2)
    assert get_term_type(t_g) == get_type(c_g)
    assert get_fvars(t_g) == []
    assert get_max_num(t_g) == 3
  end

  test "appl_gzy", state do
    v_y = mk_free_var("y", state[:i])
    v_z = mk_free_var("z", state[:ii])
    c_g = mk_const("g", state[:ii_ii])
    y = mk_term(v_y)
    z = mk_term(v_z)
    g = mk_term(c_g)

    gzy = mk_appl_term(mk_appl_term(g, z), y)

    assert pp_term(gzy, true) == "(g (1. z 1) y)"
    assert get_bvars(gzy) == []
    assert get_head(gzy) == c_g
    assert length(get_args(gzy)) == 2
    assert Enum.at(get_args(gzy), 0) == z
    assert Enum.at(get_args(gzy), 1) == y
    assert get_term_type(gzy) == state[:i]
    assert length(get_fvars(gzy)) == 2
    assert v_z in get_fvars(gzy)
    assert v_y in get_fvars(gzy)
    assert get_max_num(gzy) == 1
  end

  test "appl_fx", state do
    v_x = mk_free_var("x", state[:i])
    c_f = mk_const("f", state[:ii])
    t_x = mk_term(v_x)
    t_f = mk_term(c_f)

    fx = mk_appl_term(t_f, t_x)

    assert pp_term(fx, true) == "(f x)"
    assert get_bvars(fx) == []
    assert get_head(fx) == c_f
    assert length(get_args(fx)) == 1
    assert Enum.at(get_args(fx), 0) == t_x
    assert get_term_type(fx) == state[:i]
    assert length(get_fvars(fx)) == 1
    assert v_x in get_fvars(fx)
    assert get_max_num(fx) == 0
  end

  test "appl_abstr_z_abstr_1", state do
    v_z = mk_free_var("z", state[:ii])
    t_z = mk_term(v_z)

    abstr_z = mk_abstr_term(t_z, mk_free_var("", state[:ii_ii]))
    abstr_1 = mk_abstr_term(t_z, v_z)

    term = mk_appl_term(abstr_z, abstr_1)

    assert pp_term(term, true) == "(1. z 1)"
    assert length(get_bvars(term)) == 1
    assert get_head(term) == v_z
    assert length(get_args(term)) == 1
    # assert Enum.at(get_args(term), 0) == t_x
    assert get_term_type(term) == state[:ii]
    assert length(get_fvars(term)) == 1
    assert v_z in get_fvars(term)
    assert get_max_num(term) == 1
  end

  test "appl_hxy", state do
    v_x = mk_free_var("x", state[:i])
    v_y = mk_free_var("y", state[:i])
    v_h = mk_free_var("h", state[:iii])
    t_x = mk_term(v_x)
    t_y = mk_term(v_y)
    t_h = mk_term(v_h)

    hxy = mk_appl_term(mk_appl_term(t_h, t_x), t_y)

    assert pp_term(hxy, true) == "(h x y)"
    assert get_bvars(hxy) == []
    assert get_head(hxy) == v_h
    assert length(get_args(hxy)) == 2
    assert Enum.at(get_args(hxy), 0) == t_x
    assert Enum.at(get_args(hxy), 1) == t_y
    assert get_term_type(hxy) == state[:i]
    assert length(get_fvars(hxy)) == 3
    assert v_x in get_fvars(hxy)
    assert v_y in get_fvars(hxy)
    assert v_h in get_fvars(hxy)
    assert get_max_num(hxy) == 0
  end

  test "abstr_0", state do
    v_x = mk_free_var("x", state[:i])
    c_f = mk_const("f", state[:ii])
    t_x = mk_term(v_x)
    t_f = mk_term(c_f)

    fx = mk_appl_term(t_f, t_x)
    term = mk_abstr_term(fx, v_x)

    assert pp_term(term, true) == "(1. f 1)"
    assert length(get_bvars(term)) == 1
    assert Enum.at(get_bvars(term), 0) == mk_bound_var(1, state[:i])
    assert get_head(term) == c_f
    assert length(get_args(term)) == 1
    assert Enum.at(get_args(term), 0) == mk_bvar_term_i(1)
    assert get_term_type(term) == state[:ii]
    assert get_fvars(term) == []
    assert get_max_num(term) == 1
  end

  test "abstr_1", state do
    v_x = mk_free_var("x", state[:i])
    v_y = mk_free_var("y", state[:i])
    v_h = mk_free_var("h", state[:iii])
    t_x = mk_term(v_x)
    t_y = mk_term(v_y)
    t_h = mk_term(v_h)

    hxy = mk_appl_term(mk_appl_term(t_h, t_x), t_y)
    term = mk_abstr_term(hxy, v_x)

    assert pp_term(term, true) == "(1. h 1 y)"
    assert length(get_bvars(term)) == 1
    assert Enum.at(get_bvars(term), 0) == mk_bound_var(1, state[:i])
    assert get_head(term) == v_h
    assert length(get_args(term)) == 2
    assert Enum.at(get_args(term), 0) == mk_bvar_term_i(1)
    assert Enum.at(get_args(term), 1) == t_y
    assert get_term_type(term) == state[:ii]
    assert length(get_fvars(term)) == 2
    assert v_y in get_fvars(hxy)
    assert v_h in get_fvars(hxy)
    assert get_max_num(term) == 1
  end

  test "abstr_2", state do
    v_x = mk_free_var("x", state[:i])
    v_y = mk_free_var("y", state[:i])
    v_h = mk_free_var("h", state[:iii])
    t_x = mk_term(v_x)
    t_y = mk_term(v_y)
    t_h = mk_term(v_h)

    hxy = mk_appl_term(mk_appl_term(t_h, t_x), t_y)
    term = mk_abstr_term(hxy, v_y)

    assert pp_term(term, true) == "(1. h x 1)"
    assert length(get_bvars(term)) == 1
    assert Enum.at(get_bvars(term), 0) == mk_bound_var(1, state[:i])
    assert get_head(term) == v_h
    assert length(get_args(term)) == 2
    assert Enum.at(get_args(term), 0) == t_x
    assert Enum.at(get_args(term), 1) == mk_bvar_term_i(1)
    assert get_term_type(term) == state[:ii]
    assert length(get_fvars(term)) == 2
    assert v_x in get_fvars(hxy)
    assert v_h in get_fvars(hxy)
    assert get_max_num(term) == 1
  end

  test "abstr_order_0", state do
    v_x = mk_free_var("x", state[:i])
    v_y = mk_free_var("y", state[:i])
    v_h = mk_free_var("h", state[:iii])
    t_x = mk_term(v_x)
    t_y = mk_term(v_y)
    t_h = mk_term(v_h)

    hxy =
      t_h
      |> mk_appl_term(t_x)
      |> mk_appl_term(t_y)

    term =
      hxy
      |> mk_abstr_term(v_y)
      |> mk_abstr_term(v_x)

    assert pp_term(term, true) == "(2 1. h 2 1)"
    assert length(get_bvars(term)) == 2
    assert Enum.at(get_bvars(term), 0) == mk_bound_var(2, state[:i])
    assert Enum.at(get_bvars(term), 1) == mk_bound_var(1, state[:i])
    assert get_head(term) == v_h
    assert length(get_args(term)) == 2
    assert Enum.at(get_args(term), 0) == mk_bvar_term_i(2)
    assert Enum.at(get_args(term), 1) == mk_bvar_term_i(1)
    assert get_term_type(term) == state[:iii]
    assert length(get_fvars(term)) == 1
    assert v_h in get_fvars(term)
    assert get_max_num(term) == 2
  end

  test "abstr_order_1", state do
    v_x = mk_free_var("x", state[:i])
    v_y = mk_free_var("y", state[:i])
    v_h = mk_free_var("h", state[:iii])
    t_x = mk_term(v_x)
    t_y = mk_term(v_y)
    t_h = mk_term(v_h)

    hxy =
      t_h
      |> mk_appl_term(t_y)
      |> mk_appl_term(t_x)

    term =
      hxy
      |> mk_abstr_term(v_y)
      |> mk_abstr_term(v_x)

    assert pp_term(term, true) == "(2 1. h 1 2)"
    assert length(get_bvars(term)) == 2
    assert Enum.at(get_bvars(term), 0) == mk_bound_var(2, state[:i])
    assert Enum.at(get_bvars(term), 1) == mk_bound_var(1, state[:i])
    assert get_head(term) == v_h
    assert length(get_args(term)) == 2
    assert Enum.at(get_args(term), 0) == mk_bvar_term_i(1)
    assert Enum.at(get_args(term), 1) == mk_bvar_term_i(2)
    assert get_term_type(term) == state[:iii]
    assert length(get_fvars(term)) == 1
    assert v_h in get_fvars(term)
    assert get_max_num(term) == 2
  end

  test "appl_321.u321_21.21", state do
    v_z = mk_free_var("z", state[:ii])
    t_z = mk_term(v_z)
    v_x = mk_free_var("x", state[:i])
    t_x = mk_term(v_x)

    v_s = mk_free_var("s", mk_type(state[:ii_ii], [state[:ii_ii]]))
    t_s = mk_term(v_s)

    abstr_21 =
      t_z
      |> mk_appl_term(t_x)
      |> mk_abstr_term(v_x)
      |> mk_abstr_term(v_z)

    term = mk_appl_term(t_s, abstr_21)

    assert pp_term(term, true) == "(4 3. s (2 1. 2 1) (1. 4 1) 3)"
    assert length(get_bvars(term)) == 2
    assert Enum.at(get_bvars(term), 0) == mk_bound_var(4, state[:ii])
    assert Enum.at(get_bvars(term), 1) == mk_bound_var(3, state[:i])
    assert get_head(term) == v_s
    assert length(get_args(term)) == 3
    assert Enum.at(get_args(term), 0) == abstr_21
    assert Enum.at(get_args(term), 1) == mk_bvar_term_ii(4)
    assert Enum.at(get_args(term), 2) == mk_bvar_term_i(3)
    assert get_term_type(term) == state[:ii_ii]
    assert length(get_fvars(term)) == 1
    assert v_s in get_fvars(term)
    assert get_max_num(term) == 4
  end

  test "test_eta_long", state do
    v_s = mk_free_var("s", state[:ii_ii])
    t_s = mk_term(v_s)

    term = mk_abstr_term(t_s, v_s)

    assert pp_term(term, true) == "(4 3 2. 4 (1. 3 1) 2)"
    assert length(get_bvars(term)) == 3
    assert Enum.at(get_bvars(term), 0) == mk_bound_var(4, state[:ii_ii])
    assert Enum.at(get_bvars(term), 1) == mk_bound_var(3, state[:ii])
    assert Enum.at(get_bvars(term), 2) == mk_bound_var(2, state[:i])
    assert get_head(term) == mk_bound_var(4, state[:ii_ii])
    assert length(get_args(term)) == 2
    assert Enum.at(get_args(term), 0) == mk_bvar_term_ii(3)
    assert Enum.at(get_args(term), 1) == mk_bvar_term_i(2)
    assert get_term_type(term) == mk_type(state[:ii_ii], [state[:ii_ii]])
    assert get_fvars(term) == []
    assert get_max_num(term) == 4
  end

  test "adjust_outer_bound_vars_0", state do
    v_x = mk_free_var("x", state[:i])
    t_x = mk_term(v_x)
    v_z = mk_free_var("z", state[:ii])
    t_z = mk_term(v_z)

    appl = mk_appl_term(t_z, t_x)
    term = mk_abstr_term(mk_abstr_term(appl, v_x), v_z)
    adjusted_term = adjust_outer_bound_vars(term)

    log_notice(fn -> pp_term(term, true) end)
    log_notice(fn -> pp_term(adjusted_term, true) end)

    assert pp_term(term, true) == pp_term(adjusted_term, true)
    assert term == adjusted_term
  end

  test "adjust_outer_bound_vars_1", state do
    v_x = mk_free_var("x", state[:i])
    t_x = mk_term(v_x)
    v_z = mk_free_var("z", state[:ii])
    t_z = mk_term(v_z)

    appl = mk_appl_term(t_z, t_x)
    term = mk_abstr_term(mk_abstr_term(appl, v_z), v_x)
    adjusted_term = adjust_outer_bound_vars(term)

    log_notice(fn -> pp_term(term, true) end)
    log_notice(fn -> pp_term(adjusted_term, true) end)

    assert pp_term(term, true) == pp_term(adjusted_term, true)
    assert term == adjusted_term
  end

  test "test_eta_long_2", state do
    type = mk_type(state[:ii_ii], [state[:ii_ii]])
    v_s = mk_free_var("s", type)
    t_s = mk_term(v_s)

    term = mk_abstr_term(t_s, v_s)

    assert pp_term(term, true) == "(7 6 5 4. 7 (3 2. 6 (1. 3 1) 2) (1. 5 1) 4)"
    assert length(get_bvars(term)) == 4
    assert Enum.at(get_bvars(term), 0) == mk_bound_var(7, type)
    assert Enum.at(get_bvars(term), 1) == mk_bound_var(6, state[:ii_ii])
    assert Enum.at(get_bvars(term), 2) == mk_bound_var(5, state[:ii])
    assert Enum.at(get_bvars(term), 3) == mk_bound_var(4, state[:i])
    assert get_head(term) == mk_bound_var(7, type)
    assert length(get_args(term)) == 3
    assert Enum.at(get_args(term), 0) == mk_bvar_term_ii_ii(6)
    assert Enum.at(get_args(term), 1) == mk_bvar_term_ii(5)
    assert Enum.at(get_args(term), 2) == mk_bvar_term_i(4)
    assert get_term_type(term) == mk_type(type, [type])
    assert get_fvars(term) == []
    assert get_max_num(term) == 7
  end

  test "test_eta_long_3", state do
    type = state[:ii_ii]
    term = mk_bvar_term_ii_ii(4)

    assert pp_term(term, true) == "(3 2. 4 (1. 3 1) 2)"
    assert length(get_bvars(term)) == 2
    assert Enum.at(get_bvars(term), 0) == mk_bound_var(3, state[:ii])
    assert Enum.at(get_bvars(term), 1) == mk_bound_var(2, state[:i])
    assert get_head(term) == mk_bound_var(4, type)
    assert length(get_args(term)) == 2
    assert Enum.at(get_args(term), 0) == mk_bvar_term_ii(3)
    assert Enum.at(get_args(term), 1) == mk_bvar_term_i(2)
    assert get_term_type(term) == type
    assert get_fvars(term) == []
    assert get_max_num(term) == 3
  end

  test "test_eta_long_4", state do
    type = state[:ii_ii]
    v_x = mk_free_var("x", type)
    term_x = mk_term(v_x)
    assert pp_term(term_x, true) == "(3 2. x (1. 3 1) 2)"

    t_y = mk_free_var_term("y", state[:ii])
    term_xy = mk_appl_term(term_x, t_y)
    assert pp_term(term_xy, true) == "(2. x (1. y 1) 2)"

    t_z = mk_free_var_term("z", state[:i])
    term = mk_appl_term(term_xy, t_z)
    assert pp_term(term, true) == "(x (1. y 1) z)"

    assert get_bvars(term) == []
    assert get_head(term) == v_x
    assert length(get_args(term)) == 2
    assert Enum.at(get_args(term), 0) == t_y
    assert Enum.at(get_args(term), 1) == t_z
    assert get_term_type(term) == state[:i]
    assert length(get_fvars(term)) == 3
    assert get_max_num(term) == 1
  end

  test "big_appl", state do
    v_7 = mk_free_var("z", mk_type(state[:ii_ii], [state[:ii_ii]]))
    t_7 = mk_term(v_7)
    v_6 = mk_free_var("s", state[:ii_ii])
    t_6 = mk_term(v_6)
    v_5 = mk_free_var("f", state[:ii])
    t_5 = mk_term(v_5)
    v_4 = mk_free_var("v", state[:i])
    t_4 = mk_term(v_4)

    term_left = mk_abstr_term(t_7, v_7)

    assert pp_term(term_left, true) == "(7 6 5 4. 7 (3 2. 6 (1. 3 1) 2) (1. 5 1) 4)"

    t_x = mk_free_var_term("x", mk_type(state[:ii], [state[:ii_ii], state[:ii], state[:i]]))
    t_y = mk_free_var_term("y", state[:i])

    appl_x = mk_appl_term(mk_appl_term(mk_appl_term(t_x, t_6), t_5), t_4)

    unabstr_term_right = mk_appl_term(mk_appl_term(t_6, appl_x), t_y)

    term_right =
      mk_abstr_term(mk_abstr_term(mk_abstr_term(unabstr_term_right, v_4), v_5), v_6)

    assert pp_term(term_right, true) ==
             "(7 6 5. 7 (4. x (3 2. 7 (1. 3 1) 2) (1. 6 1) 5 4) y)"

    result = mk_appl_term(term_left, term_right)
    log_notice(pp_term(result, true))

    unabstr_expected_result =
      mk_appl_term(mk_appl_term(t_6, appl_x), t_y)

    expected_result =
      mk_abstr_term(mk_abstr_term(mk_abstr_term(unabstr_expected_result, v_4), v_5), v_6)

    assert pp_term(result, true) ==
             "(7 6 5. 7 (4. x (3 2. 7 (1. 3 1) 2) (1. 6 1) 5 4) y)"

    assert pp_term(result, true) == pp_term(expected_result, true)

    assert result == expected_result
  end

  test "big_appl_1", state do
    v_7 = mk_free_var("z", mk_type(state[:ii_ii], [state[:ii_ii]]))
    t_7 = mk_term(v_7)
    v_6 = mk_free_var("s", state[:ii_ii])
    t_6 = mk_term(v_6)
    v_5 = mk_free_var("f", state[:ii])
    t_5 = mk_term(v_5)
    v_4 = mk_free_var("v", state[:i])
    t_4 = mk_term(v_4)

    unabstr_term_left =
      mk_appl_term(
        t_5,
        mk_appl_term(t_5, mk_appl_term(mk_appl_term(mk_appl_term(t_7, t_6), t_5), t_4))
      )

    term_left =
      mk_abstr_term(
        mk_abstr_term(mk_abstr_term(mk_abstr_term(unabstr_term_left, v_4), v_5), v_6),
        v_7
      )

    assert pp_term(term_left, true) == "(7 6 5 4. 5 (5 (7 (3 2. 6 (1. 3 1) 2) (1. 5 1) 4)))"

    t_x = mk_free_var_term("x", mk_type(state[:ii], [state[:ii_ii], state[:ii], state[:i]]))
    t_y = mk_free_var_term("y", mk_type(state[:i], [state[:ii_ii], state[:ii], state[:i]]))

    appl_x = mk_appl_term(mk_appl_term(mk_appl_term(t_x, t_6), t_5), t_4)
    appl_y = mk_appl_term(mk_appl_term(mk_appl_term(t_y, t_6), t_5), t_4)

    unabstr_term_right = mk_appl_term(mk_appl_term(t_6, appl_x), appl_y)

    term_right =
      mk_abstr_term(mk_abstr_term(mk_abstr_term(unabstr_term_right, v_4), v_5), v_6)

    assert pp_term(term_right, true) ==
             "(7 6 5. 7 (4. x (3 2. 7 (1. 3 1) 2) (1. 6 1) 5 4) (y (3 2. 7 (1. 3 1) 2) (1. 6 1) 5))"

    result = mk_appl_term(term_left, term_right)
    log_notice(pp_term(result, true))

    unabstr_expected_result =
      mk_appl_term(t_5, mk_appl_term(t_5, mk_appl_term(mk_appl_term(t_6, appl_x), appl_y)))

    expected_result =
      mk_abstr_term(mk_abstr_term(mk_abstr_term(unabstr_expected_result, v_4), v_5), v_6)

    assert pp_term(result, true) == pp_term(expected_result, true)

    assert pp_term(result, true) ==
             "(7 6 5. 6 (6 (7 (4. x (3 2. 7 (1. 3 1) 2) (1. 6 1) 5 4) (y (3 2. 7 (1. 3 1) 2) (1. 6 1) 5))))"

    assert result == expected_result
  end

  test "adjust_outer_bound_vars_3", state do
    t_x = mk_free_var_term("x", state[:ii_ii])
    t_y = mk_free_var_term("y", mk_type(state[:ii], [state[:ii_ii]]))

    v_c = mk_free_var("c", state[:i])
    t_c = mk_term(v_c)

    correct_term = mk_abstr_term(mk_appl_term(mk_appl_term(t_y, t_x), t_c), v_c)

    wrong_term =
      hol_term(correct_term,
        bvars: [{:decl, :bv, 2, state[:i]}],
        args:
          Enum.reverse([
            mk_bvar_term_i(2) | tl(Enum.reverse(get_args(correct_term)))
          ]),
        max_num: 2
      )

    log_notice(pp_term(correct_term, true))
    log_notice(pp_term(wrong_term, true))

    result = adjust_outer_bound_vars(wrong_term)
    log_notice(pp_term(result, true))

    assert result == correct_term
  end

  test "bvar_overlap_bug", state do
    vl_3 = mk_uniqe_var(state[:ii_ii])
    vl_2 = mk_uniqe_var(state[:i])
    vl_1 = mk_uniqe_var(state[:i])
    cl_c = mk_const("c", state[:i])

    tl_3 = mk_term(vl_3)
    tl_2 = mk_term(vl_2)
    tl_c = mk_term(cl_c)

    term_left =
      tl_3
      |> mk_appl_term(mk_abstr_term(tl_2, vl_1))
      |> mk_appl_term(tl_c)
      |> mk_abstr_term(vl_2)
      |> mk_abstr_term(vl_3)

    assert pp_term(term_left, true) == "(3 2. 3 (1. 2 ) c)"

    vr_x = mk_free_var("x", state[:ii_ii])

    tr_x = mk_term(vr_x)

    term_right = tr_x

    assert pp_term(term_right, true) == "(3 2. x (1. 3 1) 2)"

    result = mk_appl_term(term_left, term_right)
    log_notice(pp_term(result, true))

    expected_result =
      tr_x
      |> mk_appl_term(mk_abstr_term(tl_2, vl_1))
      |> mk_appl_term(tl_c)
      |> mk_abstr_term(vl_2)

    assert pp_term(result, true) ==
             "(2. x (1. 2 ) c)"

    assert pp_term(result, true) == pp_term(expected_result, true)

    assert result == expected_result
  end
end
