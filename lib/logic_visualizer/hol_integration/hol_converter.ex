defmodule LogicVisualizer.HOLIntegration.HOLConverter do
  @moduledoc """
  Converts parsed logical expressions to Higher Order Logic (HOL) representation.
  
  This module provides conversion from the internal AST representation to a 
  HOL-compatible format suitable for formal reasoning and proof generation.
  """

  # alias LogicVisualizer.Parser.ExpressionParser  # Not used directly

  @doc """
  Convert a parsed expression to HOL representation.
  
  ## Examples
  
      iex> ast = %{type: :identifier, name: "A"}
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

  # Handle both :variable and :identifier as variables (parser produces :identifier, :variable for uppercase letters)
  defp do_convert(%{type: :variable, name: name}) do
    # Check if this is actually a predicate constant based on the name
    if name in ["P", "Q", "R", "S", "T"] and String.length(name) == 1 do
      %{
        hol_type: :constant,
        name: name,
        type_annotation: arrow_type(:individual, :proposition)
      }
    else
      %{
        hol_type: :variable,
        name: name,
        type_annotation: infer_variable_type(name)
      }
    end
  end

  defp do_convert(%{type: :identifier, name: name}) do
    %{
      hol_type: if(is_variable_name?(name), do: :variable, else: :constant),
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
      function: %{hol_type: :constant, name: "¬", type_annotation: arrow_type(:proposition, :proposition)},
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
      bound_variable: convert_binder(var),
      body: do_convert(expr)
    }
  end

  defp do_convert(%{type: :lambda, var: var, expr: expr}) do
    %{
      hol_type: :lambda_abstraction,
      bound_variable: convert_binder(var),
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

  defp binary_op_type(:conjunction), do: arrow_type(:proposition, arrow_type(:proposition, :proposition))
  defp binary_op_type(:disjunction), do: arrow_type(:proposition, arrow_type(:proposition, :proposition))
  defp binary_op_type(:implication), do: arrow_type(:proposition, arrow_type(:proposition, :proposition))
  defp binary_op_type(:biconditional), do: arrow_type(:proposition, arrow_type(:proposition, :proposition))
  defp binary_op_type(:equality), do: arrow_type(:individual, arrow_type(:individual, :proposition))
  defp binary_op_type(:addition), do: arrow_type(:individual, arrow_type(:individual, :individual))
  defp binary_op_type(:multiplication), do: arrow_type(:individual, arrow_type(:individual, :individual))
  defp binary_op_type(:composition), do: arrow_type(arrow_type(:individual, :individual), arrow_type(arrow_type(:individual, :individual), arrow_type(:individual, :individual)))
  defp binary_op_type(_), do: :unknown

  defp convert_type(%{type: :variable, name: "o"}), do: :proposition
  defp convert_type(%{type: :variable, name: "i"}), do: :individual
  defp convert_type(%{type: :identifier, name: "o"}), do: :proposition
  defp convert_type(%{type: :identifier, name: "i"}), do: :individual
  defp convert_type(%{name: name}), do: String.to_atom(name)
  defp convert_type(type) when is_atom(type), do: type
  defp convert_type(_), do: :unknown

  defp infer_type(name) do
    cond do
      # Function symbols need arrow types based on their usage context
      name in ["f", "g", "h"] -> arrow_type(:individual, :individual)
      # Common predicate letters - should be individual -> proposition
      name in ["P", "Q", "R", "S", "T"] and String.length(name) == 1 -> arrow_type(:individual, :proposition)
      String.starts_with?(name, "c_") -> :individual
      String.contains?(name, "_sk_") -> :skolem_constant
      # Single uppercase letters that aren't predicates are propositional variables
      String.length(name) == 1 and name >= "A" and name <= "Z" and name not in ["P", "Q", "R", "S", "T"] -> :proposition
      String.length(name) == 1 and name >= "a" and name <= "z" -> :individual
      # Default predicates to individual -> proposition
      String.match?(name, ~r/^[A-Z][a-z]*$/) -> arrow_type(:individual, :proposition)
      # Default functions to individual -> individual  
      String.match?(name, ~r/^[a-z][a-z]*$/) -> arrow_type(:individual, :individual)
      true -> :unknown
    end
  end

  defp infer_variable_type(name) do
    cond do
      String.length(name) == 1 and name >= "A" and name <= "Z" -> :proposition
      true -> :individual
    end
  end

  defp is_variable_name?(name) do
    String.length(name) == 1 and name >= "A" and name <= "Z"
  end

  # Helper function to create arrow types
  defp arrow_type(from, to) do
    %{type: :arrow, from: from, to: to}
  end

  # Convert binder variables (for quantifiers and lambda abstractions)
  defp convert_binder(%{type: :typed_variable, var: var, type_annotation: type}) do
    %{
      hol_type: :typed_variable,
      variable: do_convert(var),
      type_annotation: convert_type(type)
    }
  end

  defp convert_binder(var) do
    do_convert(var)
  end
end
