defmodule LogicVisualizer.Visualization.TreeVisualizer do
  @moduledoc """
  Generates textual visualizations of logical expression trees.
  
  This module creates tree-like string representations of the AST to make it
  easier to understand the structure of complex logical formulas.
  """

  alias LogicVisualizer.Parser.ExpressionParser

  @doc """
  Generate a tree visualization for a parsed expression.
  """
  def visualize_expression_tree(ast) do
    try do
      tree_string = generate_tree(ast, "")
      {:ok, tree_string}
    rescue
      e -> {:error, "Tree visualization failed: #{inspect(e)}"}
    end
  end

  @doc """
  Generate a visualization from a series of processing steps.
  """
  def generate_visualization(steps) do
    # In a real implementation, this would generate a more complex visualization,
    # like an animated sequence or a detailed graph.
    # For now, we just format the steps in a readable way.
    formatted_steps = Enum.map_join(steps, "\n", fn step ->
      "Step #{step[:step]}: #{step[:description]}\n  Formula: #{step[:formula]}"
    end)
    {:ok, formatted_steps}
  end

  defp generate_tree(ast, prefix) do
    case ast do
      %{type: :binary_operation, operator: op, left: left, right: right} ->
        "#{prefix}#{node_label(op)}\n" <>
        "#{prefix}├─ #{generate_tree(left, prefix <> "|  ")}\n" <>
        "#{prefix}└─ #{generate_tree(right, prefix <> "   ")}"
      %{type: :negation, expr: expr} ->
        "#{prefix}¬\n" <>
        "#{prefix}└─ #{generate_tree(expr, prefix <> "   ")}"
      %{type: :quantified, quantifier: q, var: var, expr: expr} ->
        "#{prefix}#{node_label(q)} #{ExpressionParser.stringify(var)}\n" <>
        "#{prefix}└─ #{generate_tree(expr, prefix <> "   ")}"
      %{type: :application, fun: fun, arg: arg} ->
        "#{prefix}Apply\n" <>
        "#{prefix}├─ #{generate_tree(fun, prefix <> "|  ")}\n" <>
        "#{prefix}└─ #{generate_tree(arg, prefix <> "   ")}"
      _ ->
        ExpressionParser.stringify(ast)
    end
  end

  defp node_label(:conjunction), do: "AND (∧)"
  defp node_label(:disjunction), do: "OR (∨)"
  defp node_label(:implication), do: "IMPLIES (→)"
  defp node_label(:biconditional), do: "EQUIV (↔)"
  defp node_label(:equality), do: "EQUALS (=)"
  defp node_label(:forall), do: "FORALL (∀)"
  defp node_label(:exists), do: "EXISTS (∃)"
  defp node_label(other), do: to_string(other)
end
