defmodule Benchmarking.Unification do
  @moduledoc false
  import HOL.Data
  import HOL.Terms
  import HOL.Unification
  import HOL.ChurchNumerals

  @spec xfa_fxa(boolean(), non_neg_integer()) :: HOL.Data.Unification.unification_results()
  def xfa_fxa(find_all, depth) do
    i = mk_type(:i)
    ii = mk_type(i, [i])
    t_x = mk_free_var_term("x", ii)
    t_f = mk_const_term("f", ii)
    t_a = mk_const_term("a", i)

    xfa = mk_appl_term(t_x, mk_appl_term(t_f, t_a))
    fxa = mk_appl_term(t_f, mk_appl_term(t_x, t_a))

    input = {xfa, fxa}

    unify(input, find_all, depth)
  end

  @spec succ(boolean(), non_neg_integer()) :: HOL.Data.Unification.unification_results()
  def succ(find_all, depth) do
    # Variable that takes a number and gives a number
    i = mk_type(:i)
    ii = mk_type(i, [i])
    ii_ii = mk_type(ii, [ii])
    t_x = mk_free_var_term("x", mk_type(ii_ii, [ii_ii]))

    input = [
      {mk_appl_term(t_x, mk_num(0)), mk_num(1)},
      {mk_appl_term(t_x, mk_num(1)), mk_num(2)}
    ]

    unify(input, find_all, depth)
  end

  @spec xaa_faa(boolean()) :: HOL.Data.Unification.unification_results()
  def xaa_faa(find_all) do
    i = mk_type(:i)
    t_a = mk_const_term("a", i)
    t_x = mk_free_var_term("x", mk_type(i, [i, i]))
    t_f = mk_const_term("f", mk_type(i, [i, i]))

    xaa = mk_appl_term(mk_appl_term(t_x, t_a), t_a)
    faa = mk_appl_term(mk_appl_term(t_f, t_a), t_a)

    input = {xaa, faa}
    unify(input, find_all)
  end
end
