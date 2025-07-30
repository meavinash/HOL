defmodule LogicVisualizer.CLI do
  @moduledoc """
  Command-line interface for the Logic Visualizer.
  """

  alias LogicVisualizer.Parser.ExpressionParser
  alias LogicVisualizer.Education
  alias LogicVisualizer.Prover

  def main(args) do
    args |> parse_args() |> process()
  end

  defp parse_args(args) do
    OptionParser.parse(args,
      switches: [
        help: :boolean,
        version: :boolean,
        explain: :string
      ],
      aliases: [
        h: :help,
        v: :version,
        e: :explain
      ]
    )
  end

  defp process({opts, args, []}) do
    cond do
      opts[:help] -> show_help()
      opts[:version] -> show_version()
      opts[:explain] -> explain(opts[:explain])
      length(args) == 1 -> analyze_expression(hd(args))
      true -> show_help()
    end
  end

  defp process({_, _, errors}) do
    IO.puts("Error parsing arguments:")
    Enum.each(errors, fn error -> IO.puts("  #{error}") end)
    show_help()
  end

  def show_help do
    IO.puts("""
    Logic Visualizer - A comprehensive tool for parsing and visualizing logical expressions
    
    Usage: logic_visualizer [options] <expression>
           logic_visualizer [options] -e <concept>
    
    Options:
      -h, --help               Show this help message
      -v, --version            Show version information
      -e, --explain <concept>  Explain a logical concept (e.g., negation, forall)
    """)
  end

  def show_version do
    IO.puts("Logic Visualizer v0.1.0")
  end

  defp explain(concept) do
    IO.puts(Education.explain(String.to_atom(concept)))
  end

  def analyze_expression(expression) do
    case ExpressionParser.parse(expression) do
      {:ok, parsed} ->
        IO.puts("Expression: #{expression}")
        IO.puts("Parsed: #{ExpressionParser.stringify(parsed)}")
        IO.puts("--- Explanation ---")
        explain_ast(parsed)
        IO.puts("--- Tree Structure ---")
        case LogicVisualizer.Visualization.TreeVisualizer.visualize_expression_tree(parsed) do
          {:ok, tree} -> IO.puts(tree)
          {:error, reason} -> IO.puts("Tree visualization failed: #{reason}")
        end
        
        IO.puts("\n--- HOL Representation ---")
        case LogicVisualizer.HOLIntegration.HOLConverter.convert(parsed) do
          {:ok, hol} -> IO.puts(inspect(hol, pretty: true))
          {:error, reason} -> IO.puts("HOL conversion failed: #{reason}")
        end
        
        IO.puts("\n--- Proof Analysis ---")
        case Prover.prove(parsed) do
          {:ok, :tautology, steps, proof_tree} -> 
            IO.puts("\n--- Semantic Tableaux Proof Tree ---")
            IO.puts(Enum.join(proof_tree, "\n"))
            IO.puts("\nAll branches closed after #{steps} steps.")
            IO.puts("The expression is a tautology (always true).")
          {:ok, :contradiction, steps, proof_tree} -> 
            IO.puts("\n--- Semantic Tableaux Proof Tree ---")
            IO.puts(Enum.join(proof_tree, "\n"))
            IO.puts("\nAll branches closed after #{steps} steps.")
            IO.puts("The expression is a contradiction (always false).")
          {:ok, :contingent, steps, proof_tree} -> 
            IO.puts("\n--- Semantic Tableaux Proof Tree ---")
            IO.puts(Enum.join(proof_tree, "\n"))
            IO.puts("\nSome branches remain open after #{steps} steps.")
            IO.puts("The expression is contingent (can be true or false).")
        end
      {:error, reason} ->
        IO.puts("Error parsing expression: #{reason}")
    end
  end

  defp explain_ast(ast) do
    case ast do
      %{type: :variable, name: name} -> 
        IO.puts("Variable: #{name}")
      %{type: :identifier, name: name} ->
        IO.puts("Identifier: #{name}")
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
        IO.puts("Typed Variable: #{var_str}:#{type_str}")
      %{type: :negation, expr: expr} ->
        IO.puts("Negation: ¬")
        IO.puts(Education.explain(:negation))
        explain_ast(expr)
      %{type: :binary_operation, operator: :equality, left: left, right: right} ->
        IO.puts("Equality: =")
        IO.puts(Education.explain(:equality))
        IO.puts("Left: ")
        explain_ast(left)
        IO.puts("Right: ")
        explain_ast(right)
      %{type: :binary_operation, operator: :addition, left: left, right: right} ->
        IO.puts("Addition: +")
        IO.puts(Education.explain(:addition))
        IO.puts("Left: ")
        explain_ast(left)
        IO.puts("Right: ")
        explain_ast(right)
      %{type: :binary_operation, operator: :multiplication, left: left, right: right} ->
        IO.puts("Multiplication: ×")
        IO.puts(Education.explain(:multiplication))
        IO.puts("Left: ")
        explain_ast(left)
        IO.puts("Right: ")
        explain_ast(right)
      %{type: :binary_operation, operator: :composition, left: left, right: right} ->
        IO.puts("Function Composition: ∘")
        IO.puts(Education.explain(:composition))
        IO.puts("Left: ")
        explain_ast(left)
        IO.puts("Right: ")
        explain_ast(right)
      %{type: :binary_operation, operator: op, left: left, right: right} ->
        IO.puts("Binary Operation: #{op}")
        IO.puts(Education.explain(op))
        IO.puts("Left: ")
        explain_ast(left)
        IO.puts("Right: ")
        explain_ast(right)
      %{type: :quantified, quantifier: q, var: var, expr: expr} ->
        IO.puts("Quantifier: #{q}")
        IO.puts(Education.explain(q))
        var_str = case var do
          %{type: :variable, name: name} -> name
          %{type: :identifier, name: name} -> name  
          %{type: :typed_variable, var: v, type_annotation: t} -> "#{ExpressionParser.stringify(v)}:#{ExpressionParser.stringify(t)}"
          _ -> inspect(var)
        end
        IO.puts("Variable: #{var_str}")
        if expr, do: explain_ast(expr)
      %{type: :lambda, var: var, expr: expr} ->
        IO.puts("Lambda: λ")
        IO.puts(Education.explain(:lambda))
        var_str = case var do
          %{type: :variable, name: name} -> name
          %{type: :identifier, name: name} -> name  
          %{type: :typed_variable, var: v, type_annotation: t} -> "#{ExpressionParser.stringify(v)}:#{ExpressionParser.stringify(t)}"
          _ -> inspect(var)
        end
        IO.puts("Variable: #{var_str}")
        if expr, do: explain_ast(expr)
      %{type: :application, fun: fun, arg: arg} ->
        IO.puts("Application: Function Application")
        IO.puts("Function: ")
        explain_ast(fun)
        IO.puts("Argument: ")
        explain_ast(arg)
      _ -> IO.puts("Unknown expression type.")
    end
  end
end
