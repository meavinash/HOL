defmodule PrettyPrint do
  @moduledoc """
    Defines functions to turn various datatypes into strings
  """
  import HOL.Data
  import HOL.Data.Unification

  defp type_delimiter, do: ">"

  @spec pp_type(HOL.Data.type()) :: String.t()
  def pp_type(type(goal: goal, args: [])) when is_atom(goal), do: Atom.to_string(goal)

  def pp_type(type(goal: goal, args: args)) do
    pp_args = Enum.map(args, fn arg -> pp_type(arg) end)
    pp_goal = Atom.to_string(goal)
    "(" <> Enum.join(pp_args, type_delimiter()) <> type_delimiter() <> pp_goal <> ")"
  end

  @spec pp_decl(HOL.Data.declaration()) :: String.t()
  @spec pp_decl(HOL.Data.declaration(), boolean()) :: String.t()
  def pp_decl(declaration(name: name, type: type), short \\ true) do
    pp_name =
      if is_reference(name) do
        "<" <> String.slice(Kernel.inspect(name), 35, 99)
      else
        to_string(name)
      end

    if short do
      pp_name
    else
      pp_name <> "_" <> pp_type(type)
    end
  end

  @spec pp_term(HOL.Data.hol_term()) :: String.t()
  @spec pp_term(HOL.Data.hol_term(), boolean()) :: String.t()
  def pp_term(hol_term(type: ty, max_num: num) = term, short \\ true) do
    {main, ending} =
      case term do
        # Term with only a head
        hol_term(bvars: [], head: h, args: []) ->
          {pp_decl(h, short), ""}

        # Term with arguments, but no bound variables
        hol_term(bvars: [], head: h, args: args) ->
          pp_args = Enum.map_join(args, " ", fn arg -> pp_term(arg, short) end)
          {"(" <> pp_decl(h, short) <> " " <> pp_args <> ")", ")"}

        # Term with both bound variables and arguments
        hol_term(bvars: bvars, head: h, args: args) ->
          pp_bvars = Enum.map_join(bvars, " ", fn var -> pp_decl(var, short) end)
          pp_args = Enum.map_join(args, " ", fn arg -> pp_term(arg, short) end)

          {"(" <> pp_bvars <> ". " <> pp_decl(h, short) <> " " <> pp_args <> ")", ""}
      end

    if short do
      main
    else
      main <> "^" <> to_string(num) <> "_" <> pp_type(ty) <> ending
    end
  end

  @spec pp_subst([HOL.Data.substitution()] | HOL.Data.substitution()) :: String.t()
  @spec pp_subst([HOL.Data.substitution()] | HOL.Data.substitution(), boolean()) :: String.t()
  def pp_subst(substitutions, short \\ true) do
    case substitutions do
      # Single Substitution
      substitution() ->
        pp_subst([substitutions])

      # Empty List
      [] ->
        ""

      # One Substitution
      [substitution(fvar: f_var, term: subst_term)] ->
        pp_decl(f_var, short) <> " <- " <> pp_term(subst_term, short)

      # Multiple Substitutions
      [first | rest] ->
        pp_subst([first], short) <> " | " <> pp_subst(rest, short)
    end
  end

  @spec pp_tls([HOL.Data.Unification.term_pair()]) :: String.t()
  @spec pp_tls([HOL.Data.Unification.term_pair()], boolean()) :: String.t()
  def pp_tls(tuple_list, short \\ true) when is_list(tuple_list) do
    "[" <>
      List.to_string(
        Enum.map(tuple_list, fn {l, r} ->
          "{" <> pp_term(l, short) <> "," <> pp_term(r, short) <> "}"
        end)
      ) <> "]"
  end

  @spec pp_sol(
          [HOL.Data.Unification.unification_solution()]
          | HOL.Data.Unification.unification_solution()
        ) :: String.t()
  @spec pp_sol(
          [HOL.Data.Unification.unification_solution()]
          | HOL.Data.Unification.unification_solution(),
          boolean()
        ) :: String.t()
  def pp_sol(solutions, short \\ true)

  def pp_sol(solutions, short) when is_list(solutions) do
    "[" <> Enum.map_join(solutions, ",", &pp_sol(&1, short)) <> "]"
  end

  def pp_sol(unification_solution(substitutions: subst, flexlist: flexlist), short) do
    sub_text = pp_subst(subst, short)
    flex_text = pp_tls(flexlist, short)
    "{" <> sub_text <> " , " <> flex_text <> "}"
  end

  @spec pp_res(HOL.Data.Unification.unification_results()) :: String.t()
  @spec pp_res(HOL.Data.Unification.unification_results(), boolean()) :: String.t()
  def pp_res(
        unification_results(solutions: solutions, max_depth_reached_count: count),
        short \\ true
      ) do
    "{ max_depth reached " <>
      Kernel.to_string(count) <> " times; solutions: " <> pp_sol(solutions, short) <> "}"
  end
end
