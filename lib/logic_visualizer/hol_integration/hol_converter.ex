defmodule LogicVisualizer.HOLIntegration.HOLConverter do
  @moduledoc """
  Converts parsed logical expressions to Higher Order Logic (HOL) representation.
  
  This module provides conversion from the internal AST representation to a 
  HOL-compatible format suitable for formal reasoning and proof generation.
  """

  alias LogicVisualizer.Parser.ExpressionParser

  @doc """
  Convert a parsed expression to HOL representation.
  
  ## Examples
  
      iex> ast = %{type: :variable, name: "A"}
      iex> HOLConverter.convert(ast)
      {:ok, %{hol_type: :variable, name: "A", type_annotation: :proposition}}
  """
  def convert(ast) do
    try do
      hol_term = do_convert(ast)
      {:ok, hol_term}
    rescue
      e -> {:error, "HOL conversion failed: #{inspect(e)}"}
    end
  end

  defp do_convert(%{type: :variable, name: name}) do
    %{
      hol_type: :variable,
      name: name,
      type_annotation: :proposition
    }
  end

  defp do_convert(%{type: :identifier, name: name}) do
    %{
      hol_type: :constant,
      name: name,
      type_annotation: infer_type(name)
    }
  end

  defp do_convert(%{type: :typed_variable, var: var, type_annotation: type}) do
    %{
      hol_type: :typed_variable,
      variable: do_convert(var),
      type_annotation: convert_type(type)
    }
  end

  defp do_convert(%{type: :negation, expr: expr}) do
    %{
      hol_type: :application,
      function: %{hol_type: :constant, name: "¬", type_annotation: :negation_op},
      argument: do_convert(expr)
    }
  end

  defp do_convert(%{type: :binary_operation, operator: op, left: left, right: right}) do
    %{
      hol_type: :application,
      function: %{
        hol_type: :application,
        function: %{hol_type: :constant, name: operator_symbol(op), type_annotation: binary_op_type(op)},
        argument: do_convert(left)
      },
      argument: do_convert(right)
    }
  end

  defp do_convert(%{type: :quantified, quantifier: q, var: var, expr: expr}) do
    %{
      hol_type: :abstraction,
      quantifier: q,
      bound_variable: do_convert(var),
      body: do_convert(expr)
    }
  end

  defp do_convert(%{type: :lambda, var: var, expr: expr}) do
    %{
      hol_type: :lambda_abstraction,
      bound_variable: do_convert(var),
      body: do_convert(expr)
    }
  end

  defp do_convert(%{type: :application, fun: fun, arg: arg}) do
    %{
      hol_type: :application,
      function: do_convert(fun),
      argument: do_convert(arg)
    }
  end

  defp do_convert(ast) do
    # Fallback for unknown types
    %{
      hol_type: :unknown,
      original: ast
    }
  end

  defp operator_symbol(:conjunction), do: "∧"
  defp operator_symbol(:disjunction), do: "∨"
  defp operator_symbol(:implication), do: "→"
  defp operator_symbol(:biconditional), do: "↔"
  defp operator_symbol(:equality), do: "="
  defp operator_symbol(:addition), do: "+"
  defp operator_symbol(:multiplication), do: "×"
  defp operator_symbol(:composition), do: "∘"
  defp operator_symbol(op), do: to_string(op)

  defp binary_op_type(:conjunction), do: :logical_binary_op
  defp binary_op_type(:disjunction), do: :logical_binary_op
  defp binary_op_type(:implication), do: :logical_binary_op
  defp binary_op_type(:biconditional), do: :logical_binary_op
  defp binary_op_type(:equality), do: :equality_op
  defp binary_op_type(:addition), do: :arithmetic_binary_op
  defp binary_op_type(:multiplication), do: :arithmetic_binary_op
  defp binary_op_type(:composition), do: :function_composition_op
  defp binary_op_type(_), do: :unknown_binary_op

  defp convert_type(%{type: :variable, name: "o"}), do: :proposition
  defp convert_type(%{type: :variable, name: "i"}), do: :individual
  defp convert_type(%{type: :identifier, name: "o"}), do: :proposition
  defp convert_type(%{type: :identifier, name: "i"}), do: :individual
  defp convert_type(%{name: name}), do: String.to_atom(name)
  defp convert_type(type) when is_atom(type), do: type
  defp convert_type(_), do: :unknown

  defp infer_type(name) do
    cond do
      String.starts_with?(name, "c_") -> :individual
      String.contains?(name, "_sk_") -> :skolem_constant
      String.length(name) == 1 and name >= "A" and name <= "Z" -> :proposition
      String.length(name) == 1 and name >= "a" and name <= "z" -> :individual
      true -> :unknown
    end
  end
end
