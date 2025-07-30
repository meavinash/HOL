defmodule HOL.Terms do
  @moduledoc """
  This module gives functions for creating terms, applications and abstractions.

  ## Examples

      iex> var_x = HOL.Data.mk_free_var("x", mk_type(:i))
      iex> const_f = HOL.Data.mk_const("f", mk_type(:i, [mk_type(:i)]))
      iex> application = mk_appl_term(mk_term(const_f), mk_term(var_x))
      iex> PrettyPrint.pp_term(application)
      "(f x)"
      iex> abstraction = mk_abstr_term(application, var_x)
      iex> PrettyPrint.pp_term(abstraction)
      "(1. f 1)"
      iex> mk_appl_term(abstraction, mk_const_term("c", mk_type(:i))) |> PrettyPrint.pp_term()
      "(f c)"
  """
  require Record
  import LoggerHelper
  import PrettyPrint

  import HOL.Data

  defp log_level, do: :debug

  # Special, simple form of substitution
  # substVar(bv,var,term) replaces the free variable fvar by the bound variable bvar
  @spec substitute_var(
          HOL.Data.bound_var_decl(),
          HOL.Data.free_var_decl(),
          HOL.Data.hol_term(),
          [HOL.Data.bound_var_decl()]
        ) :: HOL.Data.hol_term()
  @spec substitute_var(
          HOL.Data.bound_var_decl(),
          HOL.Data.free_var_decl(),
          HOL.Data.hol_term()
        ) :: HOL.Data.hol_term()
  defp substitute_var(
         declaration(kind: :bv, type: var_type) = bvar,
         declaration(kind: :fv, type: var_type) = fvar,
         hol_term(
           bvars: bvars,
           head: head,
           args: args,
           fvars: fvars
         ) =
           term,
         extra_bvars \\ []
       ) do
    all_bvars = bvars ++ extra_bvars

    case {bvar in all_bvars, fvar not in fvars, head == fvar} do
      {true, _, _} ->
        raise "Variable Capture"

      # Variable to replace doesn't exist here
      {false, true, _} ->
        term

      # Variable to replace is head
      {false, false, true} ->
        new_args = Enum.map(args, fn a -> substitute_var(bvar, fvar, a, all_bvars) end)
        new_fvars = List.delete(fvars, fvar)
        hol_term(term, head: bvar, args: new_args, fvars: new_fvars)

      # Variable to replace is not head
      {false, false, false} ->
        new_args = Enum.map(args, fn a -> substitute_var(bvar, fvar, a, all_bvars) end)
        new_fvars = List.delete(fvars, fvar)
        hol_term(term, args: new_args, fvars: new_fvars)
    end
  end

  # Special function that raises the numbers of bound variables that are "free" in term by
  # a given number; exceptions are respected though
  defp raise_fbvars(0, term, _), do: term
  defp raise_fbvars(_, term, []), do: term

  defp raise_fbvars(
         num,
         hol_term(bvars: bvars, head: h, args: args) = term,
         bvars_to_raise
       ) do
    log_input(log_level(), fn ->
      " raise_fbvars Input: " <>
        to_string(num) <> " and " <> pp_term(term) <> " and " <> inspect(bvars_to_raise)
    end)

    filtered_bvars_to_raise = bvars_to_raise -- bvars

    new_args =
      Enum.map(args, fn t -> raise_fbvars(num, t, filtered_bvars_to_raise) end)

    # Check if head must be raised
    res_term =
      if h in filtered_bvars_to_raise do
        hol_term(term, head: raise_bound_var(num, h), args: new_args)
      else
        hol_term(term, args: new_args)
      end

    log_output(log_level(), fn -> "raise_fbvars Output: " <> pp_term(res_term) end)
    res_term
  end

  @spec raise_bound_var(integer(), HOL.Data.bound_var_decl()) :: HOL.Data.bound_var_decl()
  defp raise_bound_var(num, declaration(kind: :bv, name: n) = bvar) do
    declaration(bvar, name: n + num)
  end

  # Special function that raises the numbers of outer bound variables in term by a given number
  defp raise_outer_bvars(
         num,
         hol_term(bvars: bvars, head: h, args: args) = term
       ) do
    log_input(log_level(), fn ->
      "raise_outer_bvars Input: " <> to_string(num) <> " and " <> pp_term(term)
    end)

    new_args = Enum.map(args, fn t -> raise_fbvars(num, t, bvars) end)
    new_bvars = Enum.map(bvars, fn bv -> raise_bound_var(num, bv) end)
    max_bvars_num = Enum.map(new_bvars, fn bv -> declaration(bv, :name) end)
    new_max_num = Enum.max(max_bvars_num, fn -> 0 end)

    pre_res_term =
      hol_term(term,
        bvars: new_bvars,
        args: new_args,
        max_num: new_max_num
      )

    # Check if head must be raised
    res_term =
      if h in bvars do
        hol_term(pre_res_term, head: raise_bound_var(num, h))
      else
        pre_res_term
      end

    log_output(log_level(), fn -> "raise_outer_bvars Output: " <> pp_term(res_term) end)
    res_term
  end

  @spec raise_all_bvars(integer(), HOL.Data.hol_term()) :: HOL.Data.hol_term()
  defp raise_all_bvars(num, hol_term(bvars: bvars, head: head, args: args) = term) do
    new_bvars = Enum.map(bvars, &raise_bound_var(num, &1))

    new_head =
      if declaration(head, :kind) == :bv do
        raise_bound_var(num, head)
      else
        head
      end

    new_args = Enum.map(args, &raise_all_bvars(num, &1))

    new_max_num =
      Enum.max(
        Enum.map(new_bvars, &declaration(&1, :name)) ++
          Enum.map(new_args, &get_max_num(&1)),
        fn -> 0 end
      )

    hol_term(term, bvars: new_bvars, head: new_head, args: new_args, max_num: new_max_num)
  end

  @doc """
  Creates a term from a declaration with this declaration as the head. Terms are always eta-expanded.

  Also see `mk_free_var_term/2`and `mk_const_term/2` to create a term, without first creating a declaration.

  ## Example

      iex> mk_term(HOL.Data.mk_const("x", mk_type(:i)))
      {:term, [], {:decl, :co, "x", {:type, :i, []}}, [],  mk_type(:i), [], 0}
  """
  # Creates a term from a free variable of constant
  @spec mk_term(HOL.Data.declaration()) :: HOL.Data.hol_term()
  def mk_term(declaration(kind: kind, type: type) = decl) when kind != :bv do
    log_input(log_level(), fn -> "make_term Input: " <> pp_decl(decl) end)

    f_vars =
      if kind == :fv do
        [decl]
      else
        []
      end

    res_term =
      case type do
        type(args: []) ->
          hol_term(
            bvars: [],
            head: decl,
            args: [],
            type: type,
            fvars: f_vars,
            max_num: 0
          )

        type(goal: goal_type, args: arg_types) ->
          new_vars = Enum.map(arg_types, fn t -> mk_uniqe_var(t) end)
          new_args = Enum.map(new_vars, fn v -> mk_term(v) end)
          max_num = Enum.max(Enum.map(new_args, &get_max_num(&1)), fn -> 0 end)

          # Combine to Term
          new_term =
            hol_term(
              bvars: [],
              head: decl,
              args: new_args,
              type: mk_type(goal_type),
              fvars: f_vars ++ new_vars,
              max_num: max_num
            )

          List.foldr(new_vars, new_term, fn var, term -> mk_abstr_term(term, var) end)
      end

    log_output(log_level(), fn -> "make_term Output: " <> pp_term(res_term) end)
    res_term
  end

  @doc """
  Creates a term with a free variable as head, that has the given name and type.
  """
  @spec mk_free_var_term(String.t() | reference(), HOL.Data.type()) :: HOL.Data.hol_term()
  def mk_free_var_term(name, type) do
    mk_term(mk_free_var(name, type))
  end

  @doc """
  Creates a term with a free variable as head, that has the given name and type.
  """
  @spec mk_const_term(String.t(), HOL.Data.type()) :: HOL.Data.hol_term()
  def mk_const_term(name, type) do
    mk_term(mk_const(name, type))
  end

  # Turns a term into a lambda abstraction, by replacing a free variable with a bound one
  @doc """
  Abstracts a free variable from a term by replacing it with a bound variable.

  Only free variables can be abstracted.

  ## Parameters

    - term: Term in which to abstract a variable
    - var: Free Variable to abstract

  ## Examples

      iex> var_x = mk_free_var("x", mk_type(:i))
      iex> term_f = mk_const_term("f", mk_type(:i, [mk_type(:i)]))
      iex> application = mk_appl_term(term_f, mk_term(var_x))
      iex> PrettyPrint.pp_term(application)
      "(f x)"
      iex> abstraction = mk_abstr_term(application, var_x)
      iex> PrettyPrint.pp_term(abstraction)
      "(1. f 1)"
  """
  @spec mk_abstr_term(
          HOL.Data.hol_term(),
          HOL.Data.free_var_decl() | HOL.Data.bound_var_decl()
        ) :: HOL.Data.hol_term()
  def mk_abstr_term(
        hol_term(
          bvars: bvars,
          type: term_type,
          fvars: fvars,
          max_num: max_num
        ) = term,
        var
      ) do
    log_input(log_level(), fn ->
      "mk_abstr_term Input: " <> pp_decl(var) <> " and " <> pp_term(term)
    end)

    res_term =
      case {var, var in fvars} do
        # Free Variable exists in term
        {declaration(kind: :fv, type: var_type), true} ->
          bv = mk_bound_var(max_num + 1, var_type)
          new_term = substitute_var(bv, var, term)
          mk_abstr_term(new_term, bv)

        # Free Variable doesn't exist in term
        {declaration(kind: :fv, type: var_type), false} ->
          bv = mk_bound_var(max_num + 1, var_type)
          mk_abstr_term(term, bv)

        # Used only internally
        {declaration(kind: :bv, name: num, type: var_type), false} ->
          new_type = mk_type(term_type, [var_type])
          new_max_num = max(num, max_num)
          hol_term(term, bvars: [var | bvars], type: new_type, max_num: new_max_num)
      end

    log_output(log_level(), fn -> "mk_abstr_term Output: " <> pp_term(res_term) end)
    res_term
  end

  # Sets the saved maxNum Variable to be as high as necessary so there is no overlap with its args
  # Should be used sparsly and with care
  # Can break if there are unbound bound variables in the term
  @doc """
  Adjusts the outer layer of bound variables so that those bound variables are as
  small as possible without overlapping with bound variables defined in the arguments

  > #### Warning {: .warning}
  >
  > This function can break if it is applied to terms with bound variables that are not bound anywhere!

  This function is only needed when interacting with terms in unusual ways.
  Using `mk_abstr_term/2` or `mk_appl_term/2` applies this function automatically.
  """
  @spec adjust_outer_bound_vars(HOL.Data.hol_term()) :: HOL.Data.hol_term()
  def adjust_outer_bound_vars(hol_term(bvars: [], args: args) = term) do
    max_num_args = Enum.map(args, fn a -> get_max_num(a) end)
    new_max_num = Enum.max(max_num_args, fn -> 0 end)

    hol_term(term, max_num: new_max_num)
  end

  def adjust_outer_bound_vars(hol_term(bvars: bvars, args: args) = term) do
    log_input(log_level(), fn -> "adjust_outer_bound_vars Input: " <> pp_term(term) end)

    max_num_args = Enum.map(args, fn a -> get_max_num(a) end)
    max_num_bvars = Enum.map(bvars, fn a -> get_name(a) end)
    max_max_num_args = Enum.max(max_num_args, fn -> 0 end)
    min_max_num_bvars = Enum.min(max_num_bvars, fn -> 0 end)

    diff = min_max_num_bvars - max_max_num_args

    res_term =
      if diff != 1 do
        raise_outer_bvars(-diff + 1, term)
      else
        # max_num might still need to be adjusted
        hol_term(term, max_num: Enum.max([max_max_num_args | max_num_bvars]))
      end

    log_output(log_level(), fn -> "adjust_outer_bound_vars Output: " <> pp_term(res_term) end)
    res_term
  end

  @doc """
  Adjusts all bound variables so that the innermost terms have the lowest bound variables.

  > #### Warning {: .warning}
  >
  > This function can break if it is applied to terms with bound variables that are not bound anywhere!

  This function is only needed when interacting with terms in unusual ways.
  Using `mk_abstr_term/2` or `mk_appl_term/2` applies this function automatically.
  """
  @spec adjust_all_bound_vars(HOL.Data.hol_term()) :: HOL.Data.hol_term()
  def adjust_all_bound_vars(hol_term() = term) do
    log_input(log_level(), fn -> "adjust_all_bound_vars Input: " <> pp_term(term) end)

    term_to_adjust = raise_all_bvars(1_000_000_000, term)

    res_term = adjust_all_bound_vars_inner(term_to_adjust)

    if get_max_num(res_term) >= 1_000_000_000 do
      raise "Too many bound variables in term! more than 1_000_000_000 are not supported"
    end

    log_output(log_level(), fn -> "adjust_all_bound_vars Output: " <> pp_term(res_term) end)
    res_term
  end

  @spec adjust_all_bound_vars_inner(HOL.Data.hol_term()) :: HOL.Data.hol_term()
  defp adjust_all_bound_vars_inner(hol_term(args: args) = term) do
    adjusted_args = Enum.map(args, &adjust_all_bound_vars_inner(&1))

    unadjusted_term = hol_term(term, args: adjusted_args)

    # adjust_outer_bound_vars is here used on terms that can have free bVars.
    # Since we raise all bvars by one billion before in the adjust_all_bound_vars function,
    # this could only causes problems if terms have more than one billion bvars
    adjust_outer_bound_vars(unadjusted_term)
  end

  @doc """
  Applies one term to another.

  # Example

      iex> var_x = mk_free_var("x", mk_type(:i))
      iex> term_f = mk_const_term("f", mk_type(:i, [mk_type(:i)]))
      iex> application = mk_appl_term(term_f, mk_term(var_x))
      iex> PrettyPrint.pp_term(application)
      "(f x)"
      iex> abstraction = mk_abstr_term(application, var_x)
      iex> PrettyPrint.pp_term(abstraction)
      "(1. f 1)"
      iex> mk_appl_term(abstraction, mk_const_term("c", mk_type(:i))) |> PrettyPrint.pp_term()
      "(f c)"
  """
  @spec mk_appl_term(HOL.Data.hol_term(), HOL.Data.hol_term()) ::
          HOL.Data.hol_term()
  def mk_appl_term(term_left, term_right) do
    log_input(log_level(), fn ->
      "mk_appl_term Input: " <> pp_term(term_left) <> " and " <> pp_term(term_right)
    end)

    new_term_right = raise_all_bvars(get_max_num(term_left), term_right)

    pre_res_term = mk_appl_term_inner(term_left, new_term_right)

    res_term = adjust_all_bound_vars(pre_res_term)

    log_output(log_level(), fn -> "mk_appl_term Output: " <> pp_term(res_term) end)

    res_term
  end

  @spec mk_appl_term_inner(HOL.Data.hol_term(), HOL.Data.hol_term()) ::
          HOL.Data.hol_term()
  defp mk_appl_term_inner(term_left, term_right)

  # Case: Left term is the identity function
  defp mk_appl_term_inner(
         hol_term(bvars: [bvar], head: declaration(type: type) = bvar, args: []),
         hol_term(type: type) = term_right
       ) do
    term_right
  end

  # Case: Left term is only a head with one bound variable (with head != bound variable)
  defp mk_appl_term_inner(
         hol_term(
           bvars: [_],
           head: declaration(type: type),
           args: [],
           type: type(goal: goal_type)
         ) = term_left,
         hol_term(type: type)
       ) do
    hol_term(
      term_left,
      bvars: [],
      type: mk_type(goal_type),
      max_num: 0
    )
  end

  # Case: First bvar is head.
  defp mk_appl_term_inner(
         hol_term(
           bvars: [bvar | other_bvars],
           head: bvar,
           args: args_left,
           type: type(args: [type | _])
         ),
         hol_term(type: type) = term_right
       ) do
    # Turn each arg into an lambda term and apply term2 to it
    abstraced_args_left = Enum.map(args_left, fn arg -> mk_abstr_term(arg, bvar) end)

    new_args_left =
      Enum.map(abstraced_args_left, fn arg -> mk_appl_term_inner(arg, term_right) end)

    # Stack new args together with applications and add abstractions again
    new_appl_term =
      List.foldl(new_args_left, term_right, fn t, accu -> mk_appl_term_inner(accu, t) end)

    List.foldr(other_bvars, new_appl_term, fn v, term -> mk_abstr_term(term, v) end)
  end

  # Case: First bvar is not head.
  defp mk_appl_term_inner(
         hol_term(
           bvars: [bvar | other_bvars],
           head: head_left,
           args: args_left,
           type: type(goal: goal_type, args: [first_type | rest_types])
         ),
         hol_term(type: first_type) = term_right
       )
       when head_left !== bvar do
    res_type = mk_type(goal_type, rest_types)
    # Turn each arg into an lambda term and apply term2 to it
    abstraced_args_left = Enum.map(args_left, fn arg -> mk_abstr_term(arg, bvar) end)

    new_args_left =
      Enum.map(abstraced_args_left, fn arg -> mk_appl_term_inner(arg, term_right) end)

    # Find new maxNum Candidates by taking all bvar nums and maxNums of the new args
    # New maxNum is max of those
    new_max_num_candidates =
      Enum.map(other_bvars, fn bv -> declaration(bv, :name) end) ++
        Enum.map(new_args_left, fn arg -> get_max_num(arg) end)

    new_max_num = Enum.max(new_max_num_candidates, fn -> 0 end)

    # Find fvars that are left
    list_fvars =
      if declaration(head_left, :kind) == :fv do
        [head_left]
      else
        []
      end

    fvars =
      Enum.uniq(
        List.foldl(new_args_left, list_fvars, fn arg, acc ->
          get_fvars(arg) ++ acc
        end)
      )

    # Combine all values into datastructure
    hol_term(
      bvars: other_bvars,
      head: head_left,
      args: new_args_left,
      type: res_type,
      fvars: fvars,
      max_num: new_max_num
    )
  end
end
