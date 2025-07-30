#!/usr/bin/env elixir

# Test all logical expressions
expressions = [
  # Basic logical laws
  {"Simple LEM: Law of Excluded Middle", "A ∨ ¬A"},
  {"Reflexivity: Reflexivity of implication", "∀x:o. P x → P x"},
  {"Transitivity: Transitivity of implication", "(A → B) → ((B → C) → (A → C))"},
  {"Classical Duality: Duality between universal and existential quantifiers", "(¬(∀x:o. P x)) → (∃x:o. ¬P x)"},
  {"LEM Quantified: Law of Excluded Middle for quantified propositions", "(∀x:o. P x) ∨ (∃x:o. ¬P x)"},
  {"Modus Ponens: Modus Ponens rule", "(A ∧ (A → B)) → B"},
  
  # Basic connectives
  {"Negation: Simple negation", "¬P"},
  {"Conjunction: Logical AND", "P ∧ Q"},
  {"Disjunction: Logical OR", "P ∨ Q"},
  {"Implication: Logical implication", "P → Q"},
  {"Biconditional: Logical equivalence", "P ↔ Q"},
  {"Equality: Equality between terms", "a = b"},
  
  # Quantifiers
  {"Unique existence: Unique existential quantifier", "∃!x. P x"},
  {"Type-polymorphic quantifier: Polymorphic universal quantification", "∀α. φ α"},
  {"Predicate quantifier: Existential quantification over predicates", "∃P. φ P"},
  {"Higher-order quantifier: Higher-order quantification", "∀F. ∃x. F x = x"},
  
  # Lambda calculus
  {"Lambda abstraction: Lambda function definition", "λx. t x"},
  {"Curried application: Curried function application", "f x y"},
  {"Function composition: Function composition with equality", "(f ∘ g) x = f (g x)"},
  {"Beta-reduction example: Beta reduction", "(λx. f x) a"},
  {"Eta-conversion example: Eta conversion", "λx. f x"},
  
  # Classical logical laws
  {"De Morgan's Law 1: Negation of conjunction", "¬(P ∧ Q) ↔ (¬P ∨ ¬Q)"},
  {"De Morgan's Law 2: Negation of disjunction", "¬(P ∨ Q) ↔ (¬P ∧ ¬Q)"},
  {"Distribution Law: Distribution of conjunction over disjunction", "P ∧ (Q ∨ R) ↔ (P ∧ Q) ∨ (P ∧ R)"},
  {"Double Negation: Double negation elimination", "¬¬P ↔ P"},
  {"Contraposition: Contraposition law", "(P → Q) ↔ (¬Q → ¬P)"},
  
  # Typed expressions
  {"Typed variable: Variable with type annotation", "x:o"},
  {"Typed lambda: Identity function with type", "λx:i. x"},
  {"Polymorphic identity: Polymorphic identity function", "λα. λx:α. x"},
  
  # Mathematical expressions
  {"Addition commutativity: Commutativity of addition", "∀x:i. ∀y:i. x + y = y + x"},
  {"Multiplication distributivity: Distributivity over addition", "∀x:i. ∀y:i. ∀z:i. x × (y + z) = (x × y) + (x × z)"},
  
  # Paradoxes
  {"Liar Paradox: Formalization of Liar Paradox", "∀P:o. (P ↔ ¬P)"}
]

IO.puts("Testing #{length(expressions)} logical expressions...")
IO.puts("=" |> String.duplicate(80))

for {description, expr} <- expressions do
  IO.puts("\n#{description}")
  IO.puts("-" |> String.duplicate(String.length(description)))
  IO.puts("Expression: #{expr}")
  
  try do
    result = LogicVisualizer.CLI.Main.quick_analyze(expr, true)
    IO.puts(result)
  rescue
    e ->
      IO.puts("ERROR: #{inspect(e)}")
  catch
    :exit, reason ->
      IO.puts("EXIT: #{inspect(reason)}")
    kind, reason ->
      IO.puts("CAUGHT #{kind}: #{inspect(reason)}")
  end
  
  IO.puts("\n" <> ("=" |> String.duplicate(80)))
end

IO.puts("\nAll tests completed!")
