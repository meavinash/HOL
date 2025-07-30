defmodule LogicVisualizer.CLI.Main do
  @moduledoc """
  Main entry point for the Logic Visualizer CLI application.
  """

  alias LogicVisualizer.CLI

  def main(args \\ []) do
    CLI.main(args)
  end

  def start_interactive do
    CLI.main(["-i"])
  end

  def quick_analyze(expression) do
    quick_analyze(expression, false)
  end

  def quick_analyze(expression, with_proof) when is_boolean(with_proof) do
    case LogicVisualizer.Parser.ExpressionParser.parse(expression) do
      {:ok, parsed} ->
        result = "Expression: #{expression}\n"
        result = result <> "Parsed: #{LogicVisualizer.Parser.ExpressionParser.stringify(parsed)}\n"
        result = result <> "--- Explanation ---\n"
        result = result <> explain_ast_string(parsed)
        
        if with_proof do
          result = result <> "\n--- Tree Structure ---\n"
          result = case LogicVisualizer.Visualization.TreeVisualizer.visualize_expression_tree(parsed) do
            {:ok, tree} -> result <> tree <> "\n"
            {:error, _} -> result <> "Could not generate tree visualization.\n"
          end
          
          result = result <> "\n--- HOL Representation ---\n"
          result = case LogicVisualizer.HOLIntegration.HOLConverter.convert(parsed) do
            {:ok, hol} -> result <> "#{inspect(hol, pretty: true)}\n"
            {:error, _} -> result <> "Could not convert to HOL.\n"
          end
          
          result = result <> "\n--- Proof Analysis ---\n"  
          case LogicVisualizer.Prover.prove(parsed) do
            {:ok, :tautology, steps, proof_tree} -> 
              result = result <> "\n--- Semantic Tableaux Proof Tree ---\n"
              result = result <> Enum.join(proof_tree, "\n")
              result = result <> "\n\nAll branches closed after #{steps} steps.\n"
              result <> "The expression is a tautology (always true).\n"
            {:ok, :contradiction, steps, proof_tree} -> 
              result = result <> "\n--- Semantic Tableaux Proof Tree ---\n"
              result = result <> Enum.join(proof_tree, "\n")
              result = result <> "\n\nAll branches closed after #{steps} steps.\n"
              result <> "The expression is a contradiction (always false).\n"
            {:ok, :contingent, steps, proof_tree} -> 
              result = result <> "\n--- Semantic Tableaux Proof Tree ---\n"
              result = result <> Enum.join(proof_tree, "\n")
              result = result <> "\n\nSome branches remain open after #{steps} steps.\n"
              result <> "The expression is contingent (can be true or false).\n"
          end
        else
          result
        end

      {:error, reason} ->
        "Error parsing expression: #{reason}"
    end
  rescue
    e ->
      "ERROR: #{inspect(e)}"
  end

  def batch_analyze(expressions) do
    CLI.main(["-f" | expressions])
  end

  def generate_report(expression, output_file) do
    CLI.main(["-D", "-o", output_file, expression])
  end

  def show_version do
    CLI.main(["-v"])
  end

  def show_help do
    CLI.main(["-h"])
  end

  defp explain_ast_string(ast) do
    case ast do
      %{type: :variable, name: name} -> 
        "Variable: #{name}\n"
      %{type: :identifier, name: name} ->
        "Identifier: #{name}\n"
      %{type: :typed_variable, var: var, type_annotation: type} ->
        var_str = case var do
          %{type: :variable, name: name} -> name
          %{type: :identifier, name: name} -> name  
          _ -> inspect(var)
        end
        type_str = case type do
          %{type: :variable, name: name} -> name
          %{type: :identifier, name: name} -> name  
          _ -> inspect(type)
        end
        "Typed Variable: #{var_str}:#{type_str}\n"
      %{type: :negation, expr: expr} ->
        result = "Negation: ¬\n"
        result = result <> LogicVisualizer.Education.explain(:negation) <> "\n"
        result <> explain_ast_string(expr)
      %{type: :binary_operation, operator: :equality, left: left, right: right} ->
        result = "Equality: =\n"
        result = result <> LogicVisualizer.Education.explain(:equality) <> "\n"
        result = result <> "Left: \n" <> explain_ast_string(left)
        result <> "Right: \n" <> explain_ast_string(right)
      %{type: :binary_operation, operator: op, left: left, right: right} ->
        result = "Binary Operation: #{op}\n"
        result = result <> LogicVisualizer.Education.explain(op) <> "\n"
        result = result <> "Left: \n" <> explain_ast_string(left)
        result <> "Right: \n" <> explain_ast_string(right)
      %{type: :quantified, quantifier: q, var: var, expr: expr} ->
        result = "Quantifier: #{q}\n"
        result = result <> LogicVisualizer.Education.explain(q) <> "\n"
        var_str = case var do
          %{type: :variable, name: name} -> name
          %{type: :identifier, name: name} -> name  
          %{type: :typed_variable, var: v, type_annotation: t} -> "#{LogicVisualizer.Parser.ExpressionParser.stringify(v)}:#{LogicVisualizer.Parser.ExpressionParser.stringify(t)}"
          _ -> inspect(var)
        end
        result = result <> "Variable: #{var_str}\n"
        if expr, do: result <> explain_ast_string(expr), else: result
      %{type: :lambda, var: var, expr: expr} ->
        result = "Lambda: λ\n"
        result = result <> LogicVisualizer.Education.explain(:lambda) <> "\n"
        var_str = case var do
          %{type: :variable, name: name} -> name
          %{type: :identifier, name: name} -> name  
          %{type: :typed_variable, var: v, type_annotation: t} -> "#{LogicVisualizer.Parser.ExpressionParser.stringify(v)}:#{LogicVisualizer.Parser.ExpressionParser.stringify(t)}"
          _ -> inspect(var)
        end
        result = result <> "Variable: #{var_str}\n"
        if expr, do: result <> explain_ast_string(expr), else: result
      %{type: :application, fun: fun, arg: arg} ->
        result = "Application: Function Application\n"
        result = result <> "Function: \n" <> explain_ast_string(fun)
        result <> "Argument: \n" <> explain_ast_string(arg)
      _ -> "Unknown expression type.\n"
    end
  end
end
