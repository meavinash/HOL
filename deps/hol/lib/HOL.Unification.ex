defmodule HOL.Unification do
  @moduledoc """
  This module provides the function `unify/3` that tries to unify two terms.
  """
  require Record
  import LoggerHelper
  import PrettyPrint
  import HOL.Data
  import HOL.Terms
  import HOL.Substitution
  import HOL.Unification.Bindings
  import HOL.Data.Unification

  defp log_level_helper, do: :debug
  defp log_level, do: :notice

  # Defined as shorthand for the return type of the unify_rec function
  @typep unify_rec_return :: [HOL.Data.Unification.unification_solution() | :max_depth]

  # Starts the unification with either one term pair or a list of pairs
  # Gives for each successfull branch a tuple of substitutions and the flexflex list
  @doc """
  This function tries to unify a set of terms with each other.

  Returns a `HOL.Data.Unification.unification_results/0` object that contains the
  summarized results.

  ## Parameters

    - terms: A tuple containing two terms or a list of such tuples.
    The function only allows tuples with two terms.
    - return_all_solutions: If true tries to find all possible solutions it can.
    If false stops execution after finding one solution.
    - max_depth: How deep the function should look for solutions. The amount of branches that
    abort due to this constraint are reported in the result. If this value is set to a
    negative integer this constraint is removed.

  > #### Warning {: .warning}
  >
  > This function is not guaranteed to terminate without a max_depth limit!

  ## Example

      # Create two terms to unify
      iex> type_i = mk_type(:i, [])
      iex> type_ii = mk_type(:i, [type_i])
      iex> term_a = mk_free_var_term("x", type_ii) |> mk_appl_term(mk_const_term("c", type_i))
      iex> PrettyPrint.pp_term(term_a)
      "(x c)"
      iex> term_b = mk_const_term("f", type_ii) |> mk_appl_term(mk_const_term("d", type_i))
      iex> PrettyPrint.pp_term(term_b)
      "(f d)"
      iex> input = {term_a, term_b}
      iex> result = unify(input)
      iex> PrettyPrint.pp_res(result)
      "{ max_depth reached 0 times; solutions: [{x <- (1. f d) , []}]}"
      iex> get_solutions(result) |> hd() |> PrettyPrint.pp_sol()
      "{x <- (1. f d) , []}"
  """
  @spec unify([HOL.Data.Unification.term_pair()] | HOL.Data.Unification.term_pair()) ::
          HOL.Data.Unification.unification_results()
  @spec unify(
          [HOL.Data.Unification.term_pair()] | HOL.Data.Unification.term_pair(),
          boolean()
        ) ::
          HOL.Data.Unification.unification_results()
  @spec unify(
          [HOL.Data.Unification.term_pair()] | HOL.Data.Unification.term_pair(),
          boolean(),
          non_neg_integer()
        ) ::
          HOL.Data.Unification.unification_results()
  def unify(terms, return_all_solutions \\ true, max_depth \\ 10) do
    if is_list(terms) do
      log_input(log_level(), fn -> "B: unify Input: " <> pp_tls(terms) end)
    end

    result =
      case terms do
        _ when is_list(terms) ->
          pre_result = unify_rec(terms, [], [], max_depth, return_all_solutions, "B")

          solutions =
            Enum.filter(pre_result, fn a -> not is_atom(a) end)

          unification_results(
            solutions: solutions,
            max_depth_reached_count: length(pre_result) - length(solutions)
          )

        {_, _} ->
          unify([terms], return_all_solutions, max_depth)
      end

    log_output(log_level(), fn -> "B: unify Output: " <> pp_res(result) end)
    result
  end

  # The recursive unification alogorithm
  @spec unify_rec(
          [HOL.Data.Unification.term_pair()],
          [HOL.Data.substitution()],
          [HOL.Data.Unification.term_pair()],
          non_neg_integer(),
          boolean(),
          String.t()
        ) ::
          unify_rec_return()
  # Returns if no terms are left. Helper-Variables get filtered from the substitution
  defp unify_rec([], subst, flex, _, _, branch_name) do
    result = [unification_solution(substitutions: subst, flexlist: flex)]

    log_output(log_level(), fn ->
      branch_name <> ": Termination with result: " <> pp_sol(result, true)
    end)

    result
  end

  # Max Depth reached
  defp unify_rec(_, _, _, 0, _, branch_name) do
    log_output(log_level(), fn -> branch_name <> ": Case Max Depth reached" end)
    [:max_depth]
  end

  defp unify_rec(
         [{hol_term(head: left_head) = left, hol_term(head: right_head) = right} | rest_list],
         subst,
         flex,
         remaining_depth,
         return_all_solutions,
         branch_name
       ) do
    log_input(log_level(), fn ->
      branch_name <> ": unify_rec Input: " <> pp_term(left) <> " and " <> pp_term(right)
    end)

    unify_rec_inner(
      {left, right},
      {left_head, right_head},
      {rest_list, subst, flex, remaining_depth, return_all_solutions},
      branch_name
    )
  end

  # Case Trivial
  defp unify_rec_inner(
         {left, left},
         _,
         {rest_list, subst, flex, remaining_depth, return_all_solutions},
         branch_name
       ) do
    log_output(log_level(), fn -> branch_name <> ": Case Trivial" end)
    unify_rec(rest_list, subst, flex, remaining_depth, return_all_solutions, branch_name)
  end

  # Case Wrong Types
  defp unify_rec_inner(
         {hol_term(type: type_a), hol_term(type: type_b)},
         _,
         _,
         branch_name
       )
       when not (type_a == type_b) do
    log_output(log_level(), fn ->
      branch_name <> ": Case Wrong Types " <> pp_type(type_a) <> " and" <> pp_type(type_b)
    end)

    []
  end

  # Case Constant Equal Heads
  defp unify_rec_inner(
         {left, right},
         {declaration(kind: :co) = c, declaration(kind: :co) = c},
         {rest_list, subst, flex, remaining_depth, return_all_solutions},
         branch_name
       ) do
    log_output(log_level(), fn -> branch_name <> ": Case Const Decompose" end)

    new_terms = decompose({left, right})

    unify_rec(
      rest_list ++ new_terms,
      subst,
      flex,
      remaining_depth,
      return_all_solutions,
      branch_name
    )
  end

  # Case bVar Equivalent Heads
  defp unify_rec_inner(
         {hol_term(max_num: l_mn) = left, hol_term(max_num: r_mn) = right},
         {declaration(kind: :bv, name: l_n), declaration(kind: :bv, name: r_n)},
         {rest_list, subst, flex, remaining_depth, return_all_solutions},
         branch_name
       )
       when l_mn - l_n == r_mn - r_n do
    log_output(log_level(), fn -> branch_name <> ": Case BVar Decompose" end)

    new_terms = decompose({left, right})

    unify_rec(
      rest_list ++ new_terms,
      subst,
      flex,
      remaining_depth,
      return_all_solutions,
      branch_name
    )
  end

  defp unify_rec_inner(
         {left, right},
         {declaration(kind: :fv), declaration(kind: :fv)},
         {rest_list, subst, flex, remaining_depth, return_all_solutions},
         branch_name
       ) do
    # Case FlexFlex
    log_output(log_level(), fn -> branch_name <> ": Case FlexFlex" end)

    unify_rec(
      rest_list,
      subst,
      [{left, right} | flex],
      remaining_depth,
      return_all_solutions,
      branch_name
    )
  end

  # Bind
  defp unify_rec_inner(
         {hol_term(bvars: [], args: []), hol_term(fvars: fvars) = right},
         {declaration(kind: :fv) = var, _},
         data,
         branch_name
       ) do
    log_output(log_level(), fn -> branch_name <> ": Case Bind" end)
    bind(var, fvars, right, data, branch_name)
  end

  # Bind Reversed
  defp unify_rec_inner(
         {hol_term(fvars: fvars) = left, hol_term(bvars: [], args: [])},
         {_, declaration(kind: :fv) = var},
         data,
         branch_name
       ) do
    log_output(log_level(), fn -> branch_name <> ": Case Bind Reversed" end)
    bind(var, fvars, left, data, branch_name)
  end

  # Case FlexRigid
  defp unify_rec_inner(
         {left, right},
         {declaration(kind: :fv), declaration(kind: :co)},
         data,
         branch_name
       ) do
    log_output(log_level(), fn -> branch_name <> ": Case FlexRigid" end)

    do_bindings(
      [:imitation, :projection],
      {left, right},
      data,
      branch_name
    )
  end

  # Case FlexRigid Reversed
  defp unify_rec_inner(
         {left, right},
         {declaration(kind: :co), declaration(kind: :fv)},
         data,
         branch_name
       ) do
    log_output(log_level(), fn -> branch_name <> ": Case FlexRigid Reversed" end)

    do_bindings(
      [:imitation, :projection],
      {right, left},
      data,
      branch_name
    )
  end

  # Case FlexBound
  defp unify_rec_inner(
         {left, right},
         {declaration(kind: :fv), declaration(kind: :bv)},
         data,
         branch_name
       ) do
    log_output(log_level(), fn -> branch_name <> ": Case FlexBound" end)

    do_bindings(
      [:projection],
      {left, right},
      data,
      branch_name
    )
  end

  # Case FlexBound Reversed
  defp unify_rec_inner(
         {left, right},
         {declaration(kind: :bv), declaration(kind: :fv)},
         data,
         branch_name
       ) do
    log_output(log_level(), fn -> branch_name <> ": Case FlexBound Reversed" end)

    do_bindings(
      [:projection],
      {right, left},
      data,
      branch_name
    )
  end

  # Case No Matching Case
  defp unify_rec_inner(
         _,
         _,
         _,
         branch_name
       ) do
    log_output(log_level(), fn -> branch_name <> ": No matching Case found" end)
    []
  end

  @spec bind(
          HOL.Data.free_var_decl(),
          [HOL.Data.free_var_decl()],
          HOL.Data.hol_term(),
          {[HOL.Data.Unification.term_pair()], [HOL.Data.substitution()],
           [HOL.Data.Unification.term_pair()], non_neg_integer(), boolean()},
          String.t()
        ) :: unify_rec_return()
  defp bind(
         var,
         fvars,
         term,
         {rest_list, subst, flex, remaining_depth, return_all_solutions},
         branch_name
       ) do
    if var in fvars do
      log_output(log_level_helper(), fn -> branch_name <> ": Bind Failed!" end)
      # Variable Capture
      []
    else
      {new_terms, new_subst, new_flex} =
        add_new_substitution(
          mk_substitution(var, term),
          subst,
          rest_list,
          flex
        )

      unify_rec(
        new_terms,
        new_subst,
        new_flex,
        remaining_depth,
        return_all_solutions,
        branch_name
      )
    end
  end

  @spec do_bindings(
          [HOL.Unification.Bindings.binding_type()],
          HOL.Data.Unification.term_pair(),
          {[HOL.Data.Unification.term_pair()], [HOL.Data.substitution()],
           [HOL.Data.Unification.term_pair()], non_neg_integer(), boolean()},
          String.t()
        ) :: unify_rec_return()
  defp do_bindings(
         binding_types,
         {left, right},
         {rest_list, subst, flex, remaining_depth, return_all_solutions},
         branch_name
       ) do
    left_head = get_head(left)
    right_head = get_head(right)

    new_bindings = generic_binding(left_head, right_head, binding_types)

    log_output(log_level(), fn -> "do_binding Bindings: " <> pp_subst(new_bindings) end)

    new =
      Enum.map(new_bindings, fn s ->
        add_new_substitution(s, subst, [{left, right} | rest_list], flex)
      end)

    new_with_names =
      Enum.zip(
        new,
        Enum.map(1..length(new), fn n -> branch_name <> "_" <> to_string(n) end)
      )

    results =
      Enum.reduce(new_with_names, [], fn {{new_terms, new_subst, new_flex}, n}, res ->
        if not return_all_solutions and
             not Enum.empty?(Enum.filter(res, &Record.is_record(&1))) do
          res
        else
          branch_results =
            unify_rec(
              new_terms,
              new_subst,
              new_flex,
              remaining_depth - 1,
              return_all_solutions,
              n
            )

          branch_results ++ res
        end
      end)

    List.flatten(results)
  end

  # Function to add a new substitution and update both the term list and flex list
  @spec add_new_substitution(
          HOL.Data.substitution(),
          [HOL.Data.substitution()],
          [HOL.Data.Unification.term_pair()],
          [HOL.Data.Unification.term_pair()]
        ) :: {
          [HOL.Data.Unification.term_pair()],
          [HOL.Data.substitution()],
          [HOL.Data.Unification.term_pair()]
        }
  defp add_new_substitution(new_subst_pair, old_subst_list, term_list, flex_list) do
    new_subst = add_subst(old_subst_list, new_subst_pair)

    {new_flex, additional_terms} =
      Enum.reduce(flex_list, {[], []}, fn {left, right}, {acc_same, acc_to_terms} ->
        new_left = subst(new_subst_pair, left)
        new_right = subst(new_subst_pair, right)

        # If heads are still both variables
        if get_kind(get_head(new_left)) == :fv and get_kind(get_head(new_right)) == :fv do
          {[{new_left, new_right} | acc_same], acc_to_terms}
        else
          {acc_same, [{new_left, new_right} | acc_to_terms]}
        end
      end)

    new_terms =
      additional_terms ++
        Enum.map(
          term_list,
          fn {t_left, t_right} ->
            {subst(new_subst_pair, t_left), subst(new_subst_pair, t_right)}
          end
        )

    {new_terms, new_subst, new_flex}
  end

  @spec decompose(HOL.Data.Unification.term_pair()) :: [HOL.Data.Unification.term_pair()]
  defp decompose({left, right}) do
    # Case Decompose
    left_args = get_args(left)
    right_args = get_args(right)

    if length(left_args) != length(right_args) do
      raise "Decompose called with unequal argument lengths!"
    end

    left_bvars = Enum.reverse(get_bvars(left))
    right_bvars = Enum.reverse(get_bvars(right))

    apply_bound_vars = fn bvars, term ->
      if Enum.empty?(bvars) do
        term
      else
        adjust_outer_bound_vars(Enum.reduce(bvars, term, &mk_abstr_term(&2, &1)))
      end
    end

    left_terms = Enum.map(left_args, &apply_bound_vars.(left_bvars, &1))
    right_terms = Enum.map(right_args, &apply_bound_vars.(right_bvars, &1))

    new_terms = Enum.zip(left_terms, right_terms)
    log_output(log_level_helper(), fn -> "Decompose new Terms: " <> pp_tls(new_terms) end)
    new_terms
  end
end
