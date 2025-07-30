defmodule LogicVisualizerTest do
  use ExUnit.Case
  # doctest LogicVisualizer

  alias LogicVisualizer.Parser.ExpressionParser
  alias LogicVisualizer.Examples

  describe "Expression Parsing with new parser" do
    test "parses simple variables" do
      assert {:ok, parsed} = ExpressionParser.parse("A")
      assert parsed.type == :variable
      assert parsed.name == "A"
    end

    test "parses simple negation" do
      assert {:ok, parsed} = ExpressionParser.parse("¬A")
      assert parsed.type == :negation
      assert parsed.expr.type == :variable
      assert parsed.expr.name == "A"
    end

    test "stringify function works for simple expressions" do
      {:ok, parsed} = ExpressionParser.parse("A")
      assert ExpressionParser.stringify(parsed) == "A"
      
      {:ok, parsed} = ExpressionParser.parse("¬A")
      assert ExpressionParser.stringify(parsed) == "¬A"
    end
  end
end
