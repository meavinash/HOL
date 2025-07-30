defmodule HOL.Substitution do
  @moduledoc """
  This module implements the substitution.
  It can be used to replace free variables in a term with any other terms.

  ## Example

      # Create Term
      iex> x = mk_free_var("x", mk_type(:i, [mk_type(:i)]))
      iex> term = mk_term(x) |> mk_appl_term(mk_const_term("c", mk_type(:i)))
      iex> PrettyPrint.pp_term(term)
      "(x c)"
      # Create substitution
      iex> term_y = mk_free_var_term("y", mk_type(:i, [mk_type(:i)]))
      iex> substitution = mk_substitution(x, term_y)
      iex> subst(substitution, term) |> PrettyPrint.pp_term()
      "(y c)"
  """
  import LoggerHelper
  import PrettyPrint
  import HOL.Data
  import HOL.Terms

  defp log_level, do: :debug

  # Substitutes a free variable for a term
  # It turns the substituted variable into a bound one and applies the second term to it
  @spec substitute_var(
          HOL.Data.substitution(),
          HOL.Data.hol_term()
        ) :: HOL.Data.hol_term()
  defp substitute_var(
         substitution(
           fvar: declaration(kind: :fv, type: ty) = f_var,
           term: hol_term(type: ty) = subst_term
         ) = s,
         hol_term(fvars: fvars) = term
       ) do
    log_input(log_level(), fn ->
      "substitute_var Input: " <> pp_subst(s) <> " and " <> pp_term(term)
    end)

    res_term =
      if f_var in fvars do
        # If variable to replace exists in term
        mk_appl_term(mk_abstr_term(term, f_var), subst_term)
      else
        # If variable to replace doesn't exist in term
        term
      end

    log_output(log_level(), fn -> "substitute_var Output: " <> pp_term(res_term) end)
    res_term
  end

  @doc """
  Applies a singular substitution or a list of substitutions to a term

  ## Example

      # Create Term
      iex> x = mk_free_var("x", mk_type(:i, [mk_type(:i)]))
      iex> term = mk_term(x) |> mk_appl_term(mk_const_term("c", mk_type(:i)))
      iex> PrettyPrint.pp_term(term)
      "(x c)"
      # Create substitution
      iex> term_y = mk_free_var_term("y", mk_type(:i, [mk_type(:i)]))
      iex> substitution = mk_substitution(x, term_y)
      iex> subst(substitution, term) |> PrettyPrint.pp_term()
      "(y c)"
  """
  @spec subst(
          [HOL.Data.substitution()] | HOL.Data.substitution(),
          HOL.Data.hol_term()
        ) ::
          HOL.Data.hol_term()
  def subst(substitutions, term) do
    case substitutions do
      [] ->
        term

      [substitution | rest_list] ->
        subst(rest_list, substitute_var(substitution, term))

      substitution() ->
        substitute_var(substitutions, term)
    end
  end

  @doc """
  Adds a single substitution to a list of substitutions.
  The new substitution is applied to all terms in the other substitutions, keeping the list idempotent.

  Substitutions using free variables with references as names are not added to the list,
  but still apply their substitution to the terms.

  ## Example

      iex> x = mk_free_var("x", mk_type(:i))
      iex> y = mk_free_var("y", mk_type(:i))
      iex> subst_list = [mk_substitution(y, mk_term(x))]
      iex> new_subst = mk_substitution(x, mk_const_term("c", mk_type(:i)))
      iex> add_subst(subst_list, new_subst) |> PrettyPrint.pp_subst()
      "x <- c | y <- c"
  """
  @spec add_subst([HOL.Data.substitution()], HOL.Data.substitution()) :: [HOL.Data.substitution()]
  def add_subst(substs, new_subst) do
    log_input(log_level(), fn ->
      "Input add_subst: " <> pp_subst(substs) <> " and " <> pp_subst(new_subst)
    end)

    applied =
      Enum.map(
        substs,
        fn substitution(term: t) = s -> substitution(s, term: subst(new_subst, t)) end
      )

    declaration(kind: :fv, name: name) = get_fvar(new_subst)

    result =
      if is_reference(name) do
        applied
      else
        [new_subst | applied]
      end

    log_input(log_level(), fn -> "Input add_subst: " <> pp_subst(result) end)
    result
  end
end
