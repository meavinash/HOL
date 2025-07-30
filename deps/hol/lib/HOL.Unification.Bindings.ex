defmodule HOL.Unification.Bindings do
  @moduledoc """
  This module defines functions to determine the imitation and projection bindings neccessary
  for unification.
  """
  import LoggerHelper
  import PrettyPrint
  import HOL.Data
  import HOL.Terms

  defp log_level, do: :debug

  @typedoc """
  The two binding types available
  """
  @type binding_type() :: :imitation | :projection

  @doc """
  Gives the arity of a given type. The arity is the amount of argument types it has.
  """
  @spec arity(HOL.Data.type()) :: non_neg_integer()
  def arity(type(args: type)) do
    length(type)
  end

  # Creates an imitation binding if type = :imitation
  # Creates all projection bindings if type = :projection
  @doc """
  Returns the bindings determined by the two declarations given.

  It only creates the bindings that are requested in the binding_types list.
  """
  @spec generic_binding(HOL.Data.declaration(), HOL.Data.declaration(), [binding_type()]) ::
          [HOL.Data.substitution()]
  def generic_binding(left_head, right_head, binding_types) do
    log_input(log_level(), fn ->
      "Generic Binding Input: " <>
        pp_decl(left_head) <>
        " and " <>
        pp_decl(right_head) <> " type:" <> Kernel.inspect(binding_types)
    end)

    left_type = get_type(left_head)
    left_inputs = get_arg_types(left_type)

    left_arity = arity(left_type)

    x_vars =
      if left_arity == 0 do
        []
      else
        0..(left_arity - 1)
      end
      |> Enum.map(fn n -> mk_uniqe_var(Enum.at(left_inputs, n)) end)

    x_vars_terms = Enum.map(x_vars, &mk_term(&1))

    vars_to_use =
      case {:imitation in binding_types, :projection in binding_types} do
        {true, true} -> [right_head | x_vars]
        {true, false} -> [right_head]
        {false, true} -> x_vars
      end
      |> Enum.filter(fn var ->
        get_goal_type(get_type(var)) == get_goal_type(get_type(right_head))
      end)

    bindings_right_side =
      Enum.map(vars_to_use, fn var ->
        generic_binding_inner(var, left_inputs, x_vars, x_vars_terms)
      end)

    results =
      Enum.map(
        bindings_right_side,
        fn binding -> mk_substitution(left_head, binding) end
      )

    log_output(log_level(), fn -> "Generic Binding Output: {" <> pp_subst(results) <> "}" end)

    results
  end

  @spec generic_binding_inner(
          HOL.Data.free_var_decl(),
          [HOL.Data.type()],
          [HOL.Data.free_var_decl()],
          [HOL.Data.hol_term()]
        ) :: HOL.Data.substitution()
  defp generic_binding_inner(inner_var, left_inputs, x_vars, x_vars_terms) do
    to_use_type = get_type(inner_var)
    to_use_inputs = get_arg_types(to_use_type)
    to_use_arity = arity(to_use_type)

    h_vars =
      if to_use_arity == 0 do
        []
      else
        0..(to_use_arity - 1)
      end
      |> Enum.map(fn n ->
        mk_term(mk_uniqe_var(mk_type(Enum.at(to_use_inputs, n), left_inputs)))
      end)

    # Apply x_vars to all h_vars
    applied_h_vars = apply_list_to_list(h_vars, x_vars_terms)

    # Apply x_vars to all h_vars
    final_stack = apply_list(mk_term(inner_var), applied_h_vars)

    # Add Abstractions
    final_binding =
      Enum.reduce(Enum.reverse(x_vars), final_stack, fn x, acc -> mk_abstr_term(acc, x) end)

    final_binding
  end

  @spec apply_list_to_list([HOL.Data.declaration()], [HOL.Data.hol_term()]) ::
          [HOL.Data.hol_term()]
  defp apply_list_to_list(start_vars, to_apply) do
    if Enum.empty?(to_apply) do
      start_vars
    else
      Enum.map(start_vars, fn h ->
        apply_list(h, to_apply)
      end)
    end
  end

  @spec apply_list(HOL.Data.hol_term(), [HOL.Data.hol_term()]) :: HOL.Data.hol_term()
  defp apply_list(start_var, to_apply) do
    Enum.reduce(to_apply, start_var, fn x, acc -> mk_appl_term(acc, x) end)
  end
end
