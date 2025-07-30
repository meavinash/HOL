defmodule TPTPParser do
  @moduledoc """
  This module currently only contains functions to express a unification problem as a
  TPTP-Problem (see `unification_problem_to_tptp`/1) and some helper functions.
  """

  import HOL.Data

  @doc """
  Transform a type into a TPTP parsable type string
  """
  @spec type_to_tptp(HOL.Data.type()) :: String.t()
  @spec type_to_tptp(HOL.Data.type(), boolean()) :: String.t()
  def type_to_tptp(type, brackets_around \\ false)

  def type_to_tptp(type(goal: goal, args: []), _), do: "$" <> to_string(goal)

  def type_to_tptp(type(goal: goal, args: args), brackets_around) do
    args_string =
      Enum.map_join(args, " > ", &type_to_tptp(&1, true)) <> " > "

    goal_string = "$" <> to_string(goal)

    if brackets_around do
      "(" <> args_string <> goal_string <> ")"
    else
      args_string <> goal_string
    end
  end

  @doc """
  Outputs a variable name as a string that can be used inside of TPTP Problems.

  Bound Variables have a `BV_` prepended before the number.

  Constant names are unchanged.

  Free Variables are forced into uppercase.

  > #### Warning {: .warning}
  >
  > Variable names are generally case sensitive ("x" != "X"). This is not possible in TPTP and may cause issues.
  """
  @spec get_var_name(HOL.Data.declaration()) :: String.t()
  def get_var_name(declaration(kind: :bv, name: num)), do: "BV_" <> to_string(num)
  def get_var_name(declaration(kind: :fv, name: name)), do: String.upcase(to_string(name))
  def get_var_name(declaration(kind: :co, name: name)), do: "'#{name}'"

  @doc """
  Transform a variable into a TPTP parsable variable string
  """
  @spec vars_to_tptp_declaration([HOL.Data.declaration()]) :: String.t()
  def vars_to_tptp_declaration(vars) do
    Enum.map_join(vars, ", ", fn declaration(type: type) = v ->
      "#{get_var_name(v)}: #{type_to_tptp(type)}"
    end)
  end

  @doc """
  Transform a term into a TPTP parsable term string
  """
  @spec term_to_tptp(HOL.Data.hol_term()) :: String.t()
  def term_to_tptp(hol_term(bvars: [], head: head, args: [])), do: get_var_name(head)

  def term_to_tptp(hol_term(bvars: [], head: head, args: args)) do
    args_string =
      Enum.map_join(args, " @ ", &term_to_tptp(&1))

    "( #{get_var_name(head)} @ #{args_string} )"
  end

  def term_to_tptp(hol_term(bvars: bvars, head: head, args: [])) do
    bvars_declaration = vars_to_tptp_declaration(bvars)

    "( ^ [#{bvars_declaration}] : #{get_var_name(head)} )"
  end

  def term_to_tptp(hol_term(bvars: bvars, head: head, args: args)) do
    args_string =
      Enum.map_join(args, " @ ", &term_to_tptp(&1))

    bvars_declaration = vars_to_tptp_declaration(bvars)

    "( ^ [#{bvars_declaration}] : ( #{get_var_name(head)} @ #{args_string} ) )"
  end

  defp get_constants_in_input(hol_term(head: declaration(kind: kind) = head, args: args)) do
    Enum.map(args, &get_constants_in_input(&1)) ++
      if kind == :co do
        [head]
      else
        []
      end
  end

  defp get_constants_in_input(input) do
    input
    |> Enum.map(fn {l, r} -> get_constants_in_input(l) ++ get_constants_in_input(r) end)
    |> List.flatten()
    |> Enum.uniq()
  end

  @doc """
  Transform an unification problem into a TPTP parsable problem
  """
  @spec unification_problem_to_tptp(
          [HOL.Data.Unification.term_pair()]
          | HOL.Data.Unification.term_pair()
        ) :: String.t()
  def unification_problem_to_tptp({_, _} = input), do: unification_problem_to_tptp([input])

  def unification_problem_to_tptp(input) do
    fvars_statement =
      input
      |> Enum.map(fn {l, r} -> get_fvars(l) ++ get_fvars(r) end)
      |> List.flatten()
      |> Enum.uniq()
      |> vars_to_tptp_declaration()

    equalities =
      Enum.map_join(input, "\n    & ", fn {left, right} ->
        "( #{term_to_tptp(left)} = #{term_to_tptp(right)} )"
      end)

    all_consts = get_constants_in_input(input)

    const_statements =
      all_consts
      |> Enum.map(fn c ->
        "thf(#{get_name(c)}_type,type,\n    #{vars_to_tptp_declaration([c])} )."
      end)

    main_problem =
      "thf(problem,conjecture,\n    ? [#{fvars_statement}] :\n    ( #{equalities} ) )."

    full_problem =
      (const_statements ++ [main_problem])
      |> Enum.join("\n\n")

    full_problem
  end
end
