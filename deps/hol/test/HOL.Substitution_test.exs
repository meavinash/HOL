defmodule HOL.Substitution.Tests do
  @moduledoc false
  use ExUnit.Case
  import LoggerHelper
  import HOL.Data
  import HOL.Terms
  import HOL.Substitution

  doctest HOL.Substitution

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

  test "simple_subst_0", state do
    v_x = mk_free_var("x", state[:i])
    t_x = mk_term(v_x)
    v_y = mk_free_var("y", state[:i])
    t_y = mk_term(v_y)

    subst = [mk_substitution(v_x, t_y)]

    result = subst(subst, t_x)
    assert result == t_y
  end

  test "simple_subst_1", state do
    v_x = mk_free_var("x", state[:i])
    t_x = mk_term(v_x)
    v_y = mk_free_var("y", state[:i])
    t_y = mk_term(v_y)
    c_f = mk_const("f", state[:ii])
    t_f = mk_term(c_f)
    appl_fy = mk_appl_term(t_f, t_y)

    subst = [mk_substitution(v_x, appl_fy)]

    result = subst(subst, t_x)
    assert result == appl_fy
  end

  test "appl_subst_0", state do
    v_x = mk_free_var("x", state[:i])
    t_x = mk_term(v_x)
    v_y = mk_free_var("y", state[:i])
    t_y = mk_term(v_y)
    c_f = mk_const("f", state[:ii])
    t_f = mk_term(c_f)
    appl_fx = mk_appl_term(t_f, t_x)
    appl_fy = mk_appl_term(t_f, t_y)

    subst = [mk_substitution(v_x, t_y)]

    result = subst(subst, appl_fx)
    assert result == appl_fy
  end

  test "appl_subst_1", state do
    v_x = mk_free_var("x", state[:i])
    t_x = mk_term(v_x)
    v_y = mk_free_var("y", state[:i])
    t_y = mk_term(v_y)
    c_f = mk_const("f", state[:ii])
    t_f = mk_term(c_f)
    appl_fx = mk_appl_term(t_f, t_x)
    appl_fy = mk_appl_term(t_f, t_y)

    subst = [mk_substitution(v_x, appl_fy)]

    result = subst(subst, appl_fx)
    assert result == mk_appl_term(t_f, appl_fy)
  end

  test "appl_subst_2", state do
    v_y = mk_free_var("y", state[:i])
    t_y = mk_term(v_y)
    v_z = mk_free_var("z", state[:ii])
    t_z = mk_term(v_z)
    c_f = mk_const("f", state[:ii])
    t_f = mk_term(c_f)
    c_g = mk_const("g", state[:ii_ii])
    t_g = mk_term(c_g)
    appl_gzy = t_g |> mk_appl_term(t_z) |> mk_appl_term(t_y)

    subst = [mk_substitution(v_z, t_f)]

    result = subst(subst, appl_gzy)
    assert result == mk_appl_term(t_g, t_f) |> mk_appl_term(t_y)
  end

  test "add_subst_0", state do
    v_x = mk_free_var("x", state[:i])
    v_y = mk_free_var("y", state[:i])
    t_y = mk_term(v_y)
    v_z = mk_free_var("z", state[:ii])
    c_f = mk_const("f", state[:ii])
    t_f = mk_term(c_f)

    substs = [mk_substitution(v_z, t_f)]
    new_subst = mk_substitution(v_x, t_y)

    result = add_subst(substs, new_subst)
    assert new_subst in result
    assert Enum.at(substs, 0) in result
  end

  test "add_subst_1", state do
    v_x = mk_free_var("x", state[:i])
    v_y = mk_free_var("y", state[:i])
    t_y = mk_term(v_y)
    c_c = mk_const("c", state[:i])
    t_c = mk_term(c_c)

    substs = [mk_substitution(v_x, t_y)]
    new_subst = mk_substitution(v_y, t_c)

    result = add_subst(substs, new_subst)
    assert new_subst in result
    assert mk_substitution(v_x, t_c) in result
  end

  test "add_subst_2", state do
    v_x = mk_free_var("x", state[:i])
    c_c = mk_const("c", state[:i])
    t_c = mk_term(c_c)
    helper_var = mk_uniqe_var(state[:i])
    helper_term = mk_term(helper_var)

    substs = [mk_substitution(v_x, helper_term)]
    new_subst = mk_substitution(helper_var, t_c)

    result = add_subst(substs, new_subst)
    assert result == [mk_substitution(v_x, t_c)]
  end

  test "add_subst_3", state do
    v_x = mk_free_var("x", state[:i])
    v_y = mk_free_var("y", state[:i])
    t_y = mk_term(v_y)
    v_z = mk_free_var("z", state[:ii])
    c_c = mk_const("c", state[:i])
    t_c = mk_term(c_c)
    c_f = mk_const("f", state[:ii])
    t_f = mk_term(c_f)

    substs = [mk_substitution(v_x, t_y)]

    new_subst_a = mk_substitution(v_z, t_f)
    new_subst_b = mk_substitution(v_y, t_c)

    result = add_subst(add_subst(substs, new_subst_a), new_subst_b)
    assert new_subst_a in result
    assert new_subst_b in result
    assert mk_substitution(v_x, t_c) in result
  end

  test "add_subst_4", state do
    v_x = mk_free_var("x", state[:i])
    t_x = mk_term(v_x)
    v_y = mk_free_var("y", state[:i])
    t_y = mk_term(v_y)
    v_w = mk_free_var("w", state[:i])
    c_c = mk_const("c", state[:i])
    t_c = mk_term(c_c)
    c_f = mk_const("f", state[:ii])
    t_f = mk_term(c_f)
    appl_fx = mk_appl_term(t_f, t_x)

    substs = [mk_substitution(v_x, t_y)]

    new_subst_a = mk_substitution(v_w, appl_fx)
    new_subst_b = mk_substitution(v_y, t_c)

    result = add_subst(add_subst(substs, new_subst_a), new_subst_b)
    assert new_subst_a in result
    assert new_subst_b in result
    assert mk_substitution(v_x, t_c) in result
  end
end
