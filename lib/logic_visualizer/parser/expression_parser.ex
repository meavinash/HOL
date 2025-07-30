defmodule LogicVisualizer.Parser.ExpressionParser do
  @moduledoc """
  A simplified, robust parser for propositional logic.
  This parser handles basic logical connectives and operator precedence.
  """

  import NimbleParsec

  # ##################################################################
  # # UTILITY & WHITESPACE PARSERS
  # ##################################################################

  ws = repeat(string(" ")) |> ignore()

  # ##################################################################
  # # ATOMIC EXPRESSION PARSERS (Highest Precedence)
  # ##################################################################

  general_identifier_chars = [?a..?z, ?A..?Z, ?0..?9, ?_, 0x03B1..0x03C9] # Basic Latin and Greek small letters
  identifier = utf8_string(general_identifier_chars, min: 1) |> map({__MODULE__, :make_identifier, []})
  variable = ascii_string([?A..?Z], 1) |> map({__MODULE__, :make_var, []})
  
  type_annotation = ignore(string(":")) |> choice([identifier, variable])

  typed_variable_parser =
    choice([variable, identifier])
    |> concat(type_annotation)
    |> wrap()
    |> map({__MODULE__, :make_typed_variable, []})

  # Define parenthesized expression and atom with proper recursion
  parenthesized_expr = ignore(string("(")) |> ignore(ws) |> parsec(:expr) |> ignore(ws) |> ignore(string(")"))
  
  defparsec :atom, choice([parenthesized_expr, typed_variable_parser, variable, identifier])

  # ##################################################################
  # # UNARY OPERATOR
  # ##################################################################

  defparsec :term, choice([parsec(:negation), parsec(:application)])

  defparsec :application, 
    parsec(:atom) 
    |> repeat(ignore(ws) |> concat(parsec(:atom))) 
    |> reduce({__MODULE__, :make_application, []})
  
  defparsec :negation, 
    ignore(string("¬")) 
    |> ignore(ws) 
    |> parsec(:term) # Negation can apply to any term (including other negations)
    |> map({__MODULE__, :make_negation, []})

  # ##################################################################
  # # BINARY OPERATOR PRECEDENCE
  # ##################################################################

  # Operator definitions
  conjunction_op = string("∧") |> replace(:conjunction)
  disjunction_op = string("∨") |> replace(:disjunction)
  implication_op = choice([string("→"), string("⇒")]) |> replace(:implication)
  biconditional_op = choice([string("↔"), string("⇔")]) |> replace(:biconditional)

  equality_op = string("=") |> replace(:equality)
  addition_op = string("+") |> replace(:addition)
  multiplication_op = choice([string("×"), string("*")]) |> replace(:multiplication)
  composition_op = string("∘") |> replace(:composition)

  # Parser hierarchy (arithmetic operators have higher precedence than logical operators)
  defparsec :multiplication,
    parsec(:term)
    |> repeat(ws |> concat(multiplication_op) |> concat(ws) |> parsec(:term))
    |> reduce({__MODULE__, :reduce_op_list, []})

  defparsec :addition,
    parsec(:multiplication)
    |> repeat(ws |> concat(addition_op) |> concat(ws) |> parsec(:multiplication))
    |> reduce({__MODULE__, :reduce_op_list, []})

  defparsec :composition,
    parsec(:addition)
    |> repeat(ws |> concat(composition_op) |> concat(ws) |> parsec(:addition))
    |> reduce({__MODULE__, :reduce_op_list, []})

  defparsec :equality, 
    parsec(:composition)
    |> repeat(ws |> concat(equality_op) |> concat(ws) |> parsec(:composition))
    |> reduce({__MODULE__, :reduce_op_list, []})

  defparsec :conjunction, 
    parsec(:equality)
    |> repeat(ws |> concat(conjunction_op) |> concat(ws) |> parsec(:equality))
    |> reduce({__MODULE__, :reduce_op_list, []})

  defparsec :disjunction, 
    parsec(:conjunction)
    |> repeat(ws |> concat(disjunction_op) |> concat(ws) |> parsec(:conjunction))
    |> reduce({__MODULE__, :reduce_op_list, []})

  defparsec :implication, 
    parsec(:disjunction)
    |> repeat(ws |> concat(implication_op) |> concat(ws) |> parsec(:disjunction))
    |> reduce({__MODULE__, :reduce_op_list, []})

  defparsec :biconditional, 
    parsec(:implication)
    |> repeat(ws |> concat(biconditional_op) |> concat(ws) |> parsec(:implication))
    |> reduce({__MODULE__, :reduce_op_list, []})

  # ##################################################################
  # # QUANTIFIERS & LAMBDA ABSTRACTIONS
  # ##################################################################

  quantifier_op = choice([
    string("∀") |> replace(:forall),
    string("∃!") |> replace(:exists_unique),
    string("∃") |> replace(:exists)
  ])

  lambda_op = string("λ") |> replace(:lambda)

  binder = choice([typed_variable_parser, variable, identifier])

  quantifier_body = ignore(ws) |> ignore(string(".")) |> ignore(ws) |> parsec(:expr)

  defparsec :quantifier,
    quantifier_op
    |> ignore(ws)
    |> concat(binder)
    |> concat(quantifier_body)
    |> wrap()
    |> map({__MODULE__, :make_quantified, []})

  defparsec :lambda,
    lambda_op
    |> ignore(ws)
    |> concat(binder)
    |> concat(quantifier_body)
    |> wrap()
    |> map({__MODULE__, :make_lambda, []})

  # ##################################################################
  # # FINAL EXPRESSION PARSER
  # ##################################################################

  defparsec :expr, choice([
    parsec(:quantifier),
    parsec(:lambda),
    parsec(:biconditional) # Lowest precedence binary op
  ])

  defparsec :parse_expr, ws |> parsec(:expr) |> ignore(ws) |> eos()

  # ##################################################################
  # # AST NODE BUILDER HELPERS
  # ##################################################################

  def make_var(name), do: %{type: :variable, name: name}
  def make_identifier(name), do: %{type: :identifier, name: name}
  def make_typed_variable([var, type_ann]), do: %{type: :typed_variable, var: var, type_annotation: type_ann}
  def make_negation(expr), do: %{type: :negation, expr: expr}
  
  def make_application([fun | args]) when args != [], do: Enum.reduce(args, fun, fn arg, acc -> %{type: :application, fun: acc, arg: arg} end)
  def make_application([single]), do: single
  def make_application(other), do: other

  def reduce_op_list([first | rest]) when rest != [] do
    # Parse pairs of [operator, operand] from the rest
    pairs = Enum.chunk_every(rest, 2)
    Enum.reduce(pairs, first, fn [op, right], acc -> 
      %{type: :binary_operation, operator: op, left: acc, right: right} 
    end)
  end
  def reduce_op_list([single]), do: single
  def reduce_op_list(other), do: other

  def make_quantified([quantifier, var, expr]), do: %{type: :quantified, quantifier: quantifier, var: var, expr: expr}
  def make_quantified([quantifier, var]), do: %{type: :quantified, quantifier: quantifier, var: var, expr: nil}
  def make_quantified(list) when is_list(list), do: %{type: :quantified, error: "Invalid quantifier format", data: list}
  
  def make_lambda([_lambda, var, expr]), do: %{type: :lambda, var: var, expr: expr}
  def make_lambda([_lambda, var]), do: %{type: :lambda, var: var, expr: nil}
  def make_lambda(list) when is_list(list), do: %{type: :lambda, error: "Invalid lambda format", data: list}

  # ##################################################################
  # # PUBLIC API
  # ##################################################################

  def parse(expression) when is_binary(expression) do
    case parse_expr(expression) do
      {:ok, [ast], "", _, _, _} -> {:ok, ast}
      {:ok, _, rest, _, _, _} -> {:error, "Incomplete parse, remaining: '#{rest}'"}
      {:error, reason, rest, _, {line, col}, _} ->
        {:error, "Parse error: #{reason} at line #{line}, col #{col}. Remaining: '#{rest}'"}
    end
  end

  def stringify(ast) do
    case ast do
      %{type: :variable, name: name} -> name
      %{type: :identifier, name: name} -> name
      %{type: :typed_variable, var: var, type_annotation: type_ann} -> "#{stringify(var)}:#{stringify(type_ann)}" 
      %{type: :application, fun: fun, arg: arg} -> "#{stringify(fun)}(#{stringify(arg)})"
      %{type: :negation, expr: expr} -> "¬(#{stringify(expr)})"
      %{type: :binary_operation, operator: op, left: left, right: right} ->
        op_str = case op do
          :conjunction -> "∧"
          :disjunction -> "∨"
          :implication -> "→"
          :biconditional -> "↔"
          :equality -> "="
          :addition -> "+"
          :multiplication -> "×"
          :composition -> "∘"
        end
        "(#{stringify(left)} #{op_str} #{stringify(right)})"
      %{type: :quantified, quantifier: q, var: var, expr: expr} ->
        q_str = case q do
          :forall -> "∀"
          :exists_unique -> "∃!"
          :exists -> "∃"
        end
        "#{q_str}#{stringify(var)}. (#{stringify(expr)})"
      %{type: :lambda, var: var, expr: expr} ->
        "λ#{stringify(var)}. (#{stringify(expr)})"
      _ -> inspect(ast)
    end
  end
end
