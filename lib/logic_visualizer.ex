defmodule LogicVisualizer do
  @moduledoc """
  Logic Visualizer - A comprehensive tool for parsing and visualizing logical expressions.
  
  This module provides the main entry point for the Logic Visualizer application.
  It integrates parsing, HOL representation, and visualization of logical expressions.
  """

  alias LogicVisualizer.Parser.ExpressionParser
  alias LogicVisualizer.HOLIntegration.HOLConverter
  alias LogicVisualizer.Visualization.TreeVisualizer
  alias LogicVisualizer.Processing.StepProcessor

  @doc """
  Parse a logical expression string and return its structured representation.
  
  ## Examples
  
      iex> LogicVisualizer.parse("A ∨ ¬A")
      {:ok, %{type: :binary_operation, operator: :disjunction, left: %{type: :variable, name: "A"}, right: %{type: :negation, expr: %{type: :variable, name: "A"}}}}
  """
  def parse(expression_string) do
    ExpressionParser.parse(expression_string)
  end

  @doc """
  Convert a parsed expression to HOL (Higher Order Logic) representation.
  
  ## Examples
  
      iex> parsed_expr = %{type: :disjunction, left: %{type: :variable, name: "A"}, right: %{type: :negation, expr: %{type: :variable, name: "A"}}}
      iex> LogicVisualizer.to_hol(parsed_expr)
      {:ok, hol_term}
  """
  def to_hol(parsed_expression) do
    HOLConverter.convert(parsed_expression)
  end

  def stringify(parsed_expression) do
    ExpressionParser.stringify(parsed_expression)
  end

  @doc """
  Generate a step-by-step processing visualization for a logical expression.
  
  ## Examples
  
      iex> LogicVisualizer.visualize_steps("A ∨ ¬A")
      {:ok, visualization_steps}
  """
  def visualize_steps(expression_string) do
    with {:ok, parsed} <- parse(expression_string),
         {:ok, hol_term} <- to_hol(parsed),
         {:ok, steps} <- StepProcessor.process_steps(parsed, hol_term) do
      TreeVisualizer.generate_visualization(steps)
    end
  end

  @doc """
  Get a tree visualization of a logical expression.
  
  ## Examples
  
      iex> LogicVisualizer.visualize_tree("A ∨ ¬A")
      {:ok, tree_string}
  """
  def visualize_tree(expression_string) do
    with {:ok, parsed} <- parse(expression_string) do
      TreeVisualizer.visualize_expression_tree(parsed)
    end
  end

  @doc """
  Process and display a logical expression with full analysis.
  
  ## Examples
  
      iex> LogicVisualizer.analyze_expression("A ∨ ¬A")
      {:ok, analysis_result}
  """
  def analyze_expression(expression_string) do
    with {:ok, parsed} <- parse(expression_string),
         {:ok, hol_term} <- to_hol(parsed),
         {:ok, steps} <- StepProcessor.process_steps(parsed, hol_term),
         {:ok, tree} <- TreeVisualizer.visualize_expression_tree(parsed),
         {:ok, visualization} <- TreeVisualizer.generate_visualization(steps) do
      {:ok, %{
        expression: expression_string,
        parsed: parsed,
        hol_term: hol_term,
        steps: steps,
        tree: tree,
        visualization: visualization
      }}
    end
  end
end