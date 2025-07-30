defmodule LogicVisualizer.Processing.StepProcessor do
  @moduledoc """
  Processes parsed expressions and HOL terms to generate proof steps.
  
  This module creates a sequence of readable steps that describe the logical
  transformations, such as quantifier instantiation, negation handling, and
  the application of logical rules.
  """

  alias LogicVisualizer.Parser.ExpressionParser

  @doc """
  Process a parsed expression and its HOL representation to generate steps.

  ## Examples

      iex> ast = %{type: :variable, name: "A"}
      iex> hol = %{hol_type: :variable, name: "A", type_annotation: :proposition}
      iex> StepProcessor.process_steps(ast, hol)
      {:ok, [%{step: 1, description: "Initial formula", formula: "A"}]}
  """
  def process_steps(ast, hol_term) do
    steps = [
      %{step: 1, description: "Initial formula", formula: ExpressionParser.stringify(ast), hol: hol_term},
      %{step: 2, description: "Semantic analysis of the formula", formula: "Analyzing...", analysis: analyze(ast)}
    ]
    {:ok, steps}
  end

  defp analyze(ast) do
    case ast do
      %{type: :negation, expr: expr} -> "The formula is a negation. We need to evaluate the inner expression: #{ExpressionParser.stringify(expr)}."
      %{type: :binary_operation, operator: op, left: l, right: r} ->
        "This is a #{op}. Left side is #{ExpressionParser.stringify(l)}, right is #{ExpressionParser.stringify(r)}."
      %{type: :quantified, quantifier: q, var: var, expr: expr} ->
        "This is a #{q} quantified formula. Variable is #{ExpressionParser.stringify(var)}. Body is #{ExpressionParser.stringify(expr)}."
      %{type: :lambda, var: var, expr: expr} ->
        "Lambda abstraction with variable #{ExpressionParser.stringify(var)} and body #{ExpressionParser.stringify(expr)}."
      %{type: :application, fun: fun, arg: arg} ->
        "Function application of #{ExpressionParser.stringify(fun)} to #{ExpressionParser.stringify(arg)}."
      _ -> "The formula is a basic term."
    end
  end
end
