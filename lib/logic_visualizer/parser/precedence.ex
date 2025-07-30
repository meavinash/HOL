defmodule LogicVisualizer.Parser.Precedence do
  @moduledoc """
  Handles operator precedence for logical expressions.
  
  This module provides utilities for managing operator precedence when parsing
  and evaluating logical expressions.
  """

  # Operator precedence levels (higher number = higher precedence)
  @precedence %{
    :lambda => 1,
    :forall => 2,
    :exists => 2,
    :exists_unique => 2,
    :implication => 3,
    :biconditional => 3,
    :disjunction => 4,
    :conjunction => 5,
    :negation => 6,
    :equality => 7,
    :composition => 8,
    :arrow => 9,
    :equivalence => 9,
    :application => 10
  }

  # Operator associativity
  @associativity %{
    :lambda => :right,
    :forall => :right,
    :exists => :right,
    :exists_unique => :right,
    :implication => :right,
    :biconditional => :left,
    :disjunction => :left,
    :conjunction => :left,
    :negation => :right,
    :equality => :left,
    :composition => :left,
    :arrow => :left,
    :equivalence => :left,
    :application => :left
  }

  @doc """
  Get the precedence level of an operator.
  
  ## Examples
  
      iex> Precedence.get_precedence(:conjunction)
      5
      iex> Precedence.get_precedence(:implication)
      3
  """
  def get_precedence(operator) do
    Map.get(@precedence, operator, 0)
  end

  @doc """
  Get the associativity of an operator.
  
  ## Examples
  
      iex> Precedence.get_associativity(:conjunction)
      :left
      iex> Precedence.get_associativity(:implication)
      :right
  """
  def get_associativity(operator) do
    Map.get(@associativity, operator, :left)
  end

  @doc """
  Compare precedence between two operators.
  
  Returns :higher, :lower, :equal, or :unknown
  
  ## Examples
  
      iex> Precedence.compare(:conjunction, :disjunction)
      :higher
      iex> Precedence.compare(:implication, :conjunction)
      :lower
  """
  def compare(op1, op2) do
    prec1 = get_precedence(op1)
    prec2 = get_precedence(op2)
    
    cond do
      prec1 > prec2 -> :higher
      prec1 < prec2 -> :lower
      prec1 == prec2 -> :equal
      true -> :unknown
    end
  end

  @doc """
  Check if an operator needs parentheses when used with another operator.
  
  ## Examples
  
      iex> Precedence.needs_parentheses?(:conjunction, :implication, :left)
      true
      iex> Precedence.needs_parentheses?(:conjunction, :disjunction, :left)
      false
  """
  def needs_parentheses?(outer_op, inner_op, position) do
    outer_prec = get_precedence(outer_op)
    inner_prec = get_precedence(inner_op)
    
    cond do
      outer_prec > inner_prec -> true
      outer_prec < inner_prec -> false
      outer_prec == inner_prec ->
        outer_assoc = get_associativity(outer_op)
        inner_assoc = get_associativity(inner_op)
        
        case position do
          :left -> outer_assoc != :left or inner_assoc != :left
          :right -> outer_assoc != :right or inner_assoc != :right
        end
      true -> false
    end
  end

  @doc """
  Apply precedence rules to a flat expression list.
  
  This function takes a flat list of expressions and operators and applies
  precedence rules to build a proper AST.
  
  ## Examples
  
      iex> exprs = [%{type: :variable, name: "A"}, :conjunction, %{type: :variable, name: "B"}, :implication, %{type: :variable, name: "C"}]
      iex> Precedence.apply_precedence(exprs)
      %{type: :binary_operation, operator: :implication, left: %{type: :binary_operation, operator: :conjunction, left: %{type: :variable, name: "A"}, right: %{type: :variable, name: "B"}}, right: %{type: :variable, name: "C"}}
  """
  def apply_precedence(expressions) do
    # Convert to postfix notation using shunting yard algorithm
    postfix = shunting_yard(expressions)
    
    # Build AST from postfix notation
    build_ast(postfix)
  end

  # Shunting yard algorithm implementation
  defp shunting_yard(expressions) do
    shunting_yard(expressions, [], [])
  end

  defp shunting_yard([], output, stack) do
    output ++ Enum.reverse(stack)
  end

  defp shunting_yard([expr | rest], output, stack) when is_map(expr) do
    shunting_yard(rest, output ++ [expr], stack)
  end

  defp shunting_yard([op | rest], output, stack) do
    case stack do
      [] ->
        shunting_yard(rest, output, [op | stack])
      [top_op | _] when is_atom(top_op) ->
        case compare_precedence_for_shunting_yard(op, top_op) do
          :pop ->
            [popped | new_stack] = stack
            shunting_yard([op | rest], output ++ [popped], new_stack)
          :push ->
            shunting_yard(rest, output, [op | stack])
        end
      _ ->
        shunting_yard(rest, output, [op | stack])
    end
  end

  defp compare_precedence_for_shunting_yard(op1, op2) do
    case compare(op1, op2) do
      :higher -> :push
      :lower -> :pop
      :equal ->
        case get_associativity(op1) do
          :left -> :pop
          :right -> :push
        end
      :unknown -> :push
    end
  end

  # Build AST from postfix notation
  defp build_ast(postfix) do
    build_ast(postfix, [])
  end

  defp build_ast([], [result]) do
    result
  end

  defp build_ast([expr | rest], stack) when is_map(expr) do
    build_ast(rest, [expr | stack])
  end

  defp build_ast([op | rest], stack) when is_atom(op) do
    case stack do
      [right, left | remaining_stack] ->
        new_expr = %{type: :binary_operation, operator: op, left: left, right: right}
        build_ast(rest, [new_expr | remaining_stack])
      _ ->
        raise "Invalid postfix expression"
    end
  end
end