defmodule HOL.ChurchNumerals do
  @moduledoc """
  This module gives an implementation for creating church numerals and the terms needed for addition and multiplication.

  ## Examples

      iex> mk_num(1) |> PrettyPrint.pp_term(true)
      "(2 1. 2 1)"

      iex> plus(mk_num(1), mk_num(2)) |> PrettyPrint.pp_term(true)
      "(2 1. 2 (2 (2 1)))"

      iex> mult(mk_num(2), mk_num(3)) |> PrettyPrint.pp_term(true)
      "(2 1. 2 (2 (2 (2 (2 (2 1))))))"

      iex> mult_term() |> PrettyPrint.pp_term(true)
      "(6 5 4 3. 6 (2. 5 (1. 4 1) 2) 3)"
  """

  import HOL.Data
  import HOL.Terms

  defp i, do: mk_type(:i, [])
  defp ii, do: mk_type(i(), [i()])
  defp ii_ii, do: mk_type(i(), [ii(), i()])
  defp v_x, do: mk_free_var("x", i())
  defp t_x, do: mk_term(v_x())
  defp v_f, do: mk_free_var("f", ii())
  defp t_f, do: mk_term(v_f())
  defp v_n, do: mk_free_var("n", ii_ii())
  defp t_n, do: mk_term(v_n())
  defp v_m, do: mk_free_var("m", ii_ii())
  defp t_m, do: mk_term(v_m())

  # n0: \lam f.\lam x. x
  # n1: \lam f.\lam x. f x
  # n2: \lam f.\lam x. f (f x)
  # n3: \lam f.\lam x. f (f (f x))
  # ....
  @doc """
  Returns a lambda term representing the given integer as a church numeral
  """
  @spec mk_num(non_neg_integer()) :: HOL.Data.hol_term()
  def mk_num(n) do
    list_of_fs = List.duplicate(t_f(), n)
    appl_term = List.foldl(list_of_fs, t_x(), fn t, accu -> mk_appl_term(t, accu) end)

    appl_term
    |> mk_abstr_term(v_x())
    |> mk_abstr_term(v_f())
  end

  @doc """
  Returns the lamda term that represents the successor function: "λ 4 3 2. 3 (4 (1. 3 1) 2)"
  """
  @spec succ_term() :: HOL.Data.hol_term()
  def succ_term do
    # succ: \lam n.\lam f.\lam x. f (n f x)}
    t_f()
    |> mk_appl_term(
      t_n()
      |> mk_appl_term(t_f())
      |> mk_appl_term(t_x())
    )
    |> mk_abstr_term(v_x())
    |> mk_abstr_term(v_f())
    |> mk_abstr_term(v_n())
  end

  @doc """
  Applies the `succ_term()` to a given number.

  Shorthand for `mk_appl_term(succ_term(), n)`
  """
  @spec succ(HOL.Data.hol_term()) :: HOL.Data.hol_term()
  def succ(n), do: mk_appl_term(succ_term(), n)

  @doc """
  Returns the lamda term that represents the addition function: "λ 5 4 3 2. 5 (1. 3 1) (4 (1. 3 1) 2"
  """
  @spec plus_term() :: HOL.Data.hol_term()
  def plus_term do
    # plus: {\lam m.\lam n.\lam f.\lam x.m f (n f x)
    t_m()
    |> mk_appl_term(t_f())
    |> mk_appl_term(
      t_n()
      |> mk_appl_term(t_f())
      |> mk_appl_term(t_x())
    )
    |> mk_abstr_term(v_x())
    |> mk_abstr_term(v_f())
    |> mk_abstr_term(v_n())
    |> mk_abstr_term(v_m())
  end

  @doc """
  Applies the `plus_term()` to the given numbers.

  Shorthand for `mk_appl_term(mk_appl_term(plus_term(), m), n)`
  """
  @spec plus(HOL.Data.hol_term(), HOL.Data.hol_term()) :: HOL.Data.hol_term()
  def plus(m, n), do: mk_appl_term(mk_appl_term(plus_term(), m), n)

  @doc """
  Returns the lamda term that represents the multiplication function: `λ 6 5 4 3. 6 (2. 5 (1. 4 1) 2) 3`
  """
  @spec mult_term() :: HOL.Data.hol_term()
  def mult_term do
    # mult: \lam m. \lam n. \lam f. \lam x. ((m (n f)) x)
    t_m()
    |> mk_appl_term(
      t_n()
      |> mk_appl_term(t_f())
    )
    |> mk_appl_term(t_x())
    |> mk_abstr_term(v_x())
    |> mk_abstr_term(v_f())
    |> mk_abstr_term(v_n())
    |> mk_abstr_term(v_m())
  end

  @doc """
  Applies the `mult_term()` to the given numbers.

  Shorthand for `mk_appl_term(mk_appl_term(mult_term(), m), n)`
  """
  @spec mult(HOL.Data.hol_term(), HOL.Data.hol_term()) :: HOL.Data.hol_term()
  def mult(m, n), do: mk_appl_term(mk_appl_term(mult_term(), m), n)

  # @spec exp_term() :: HOL.Data.hol_term()
  # def exp_term do
  # exp: \lam m.\lam n.\lam f.\lam x. (n m) f x
  #   # Causes Error: Types of m and n are incompatible! (i->i)->i->i
  #   t_n()
  #   |> mk_appl_term(t_m())
  #   |> mk_appl_term(t_f())
  #   |> mk_appl_term(t_x())
  #   |> mk_abstr_term(v_x())
  #   |> mk_abstr_term(v_f())
  #   |> mk_abstr_term(v_n())
  #   |> mk_abstr_term(v_m())
  # end

  # @spec exp(HOL.Data.hol_term(), HOL.Data.hol_term()) :: HOL.Data.hol_term()
  # def exp(m, n), do: mk_appl_term(mk_appl_term(exp_term(), m), n)
end
