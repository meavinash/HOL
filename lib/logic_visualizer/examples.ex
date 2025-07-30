defmodule LogicVisualizer.Examples do
  @moduledoc """
  Collection of example logical expressions for testing and demonstration.
  
  This module provides a comprehensive set of example expressions covering
  various logical constructs supported by the Logic Visualizer.
  """

  @doc """
  Get all example expressions with descriptions.
  
  ## Examples
  
      iex> Examples.get_all_examples()
      [%{name: "Simple LEM", expression: "A ∨ ¬A"}, ...]
  """
  def get_all_examples do
    [
      # Basic propositional logic examples
      %{
        name: "Simple LEM",
        expression: "A ∨ ¬A",
        description: "Law of Excluded Middle - a proposition is either true or false",
        category: :propositional_logic,
        complexity: :simple
      },
      %{
        name: "Reflexivity",
        expression: "∀x:o. P x → P x",
        description: "Reflexivity of implication - any proposition implies itself",
        category: :propositional_logic,
        complexity: :simple
      },
      %{
        name: "Transitivity",
        expression: "(A → B) → ((B → C) → (A → C))",
        description: "Transitivity of implication - if A implies B and B implies C, then A implies C",
        category: :propositional_logic,
        complexity: :medium
      },
      %{
        name: "Classical Duality",
        expression: "(¬(∀x:o. P x)) → (∃x:o. ¬P x)",
        description: "Duality between universal and existential quantifiers",
        category: :quantified_logic,
        complexity: :medium
      },
      %{
        name: "LEM Quantified",
        expression: "(∀x:o. P x) ∨ (∃x:o. ¬P x)",
        description: "Law of Excluded Middle for quantified propositions",
        category: :quantified_logic,
        complexity: :medium
      },
      %{
        name: "Modus Ponens",
        expression: "(A ∧ (A → B)) → B",
        description: "Modus Ponens - if A is true and A implies B, then B is true",
        category: :propositional_logic,
        complexity: :simple
      },
      
      # Core logical connective forms
      %{
        name: "Negation: ¬P",
        expression: "¬P",
        description: "Simple negation of a proposition",
        category: :connectives,
        complexity: :simple
      },
      %{
        name: "Conjunction: P ∧ Q",
        expression: "P ∧ Q",
        description: "Logical AND between two propositions",
        category: :connectives,
        complexity: :simple
      },
      %{
        name: "Disjunction: P ∨ Q",
        expression: "P ∨ Q",
        description: "Logical OR between two propositions",
        category: :connectives,
        complexity: :simple
      },
      %{
        name: "Implication: P ⇒ Q",
        expression: "P ⇒ Q",
        description: "Logical implication from P to Q",
        category: :connectives,
        complexity: :simple
      },
      %{
        name: "Biconditional: P ↔ Q",
        expression: "P ↔ Q",
        description: "Logical equivalence between P and Q",
        category: :connectives,
        complexity: :simple
      },
      %{
        name: "Equality: a = b",
        expression: "a = b",
        description: "Equality between two terms",
        category: :connectives,
        complexity: :simple
      },
      %{
        name: "Unique existence: ∃!x. P(x)",
        expression: "∃!x. P(x)",
        description: "Unique existential quantifier - there exists exactly one x such that P(x)",
        category: :quantified_logic,
        complexity: :medium
      },
      
      # Quantifiers at various types
      %{
        name: "Type‐polymorphic quantifier: ∀α. φ(α)",
        expression: "∀α. φ(α)",
        description: "Polymorphic universal quantification over types",
        category: :higher_order,
        complexity: :advanced
      },
      %{
        name: "Predicate quantifier: ∃P. φ(P)",
        expression: "∃P. φ(P)",
        description: "Existential quantification over predicates",
        category: :higher_order,
        complexity: :advanced
      },
      %{
        name: "Higher‐order quantifier: ∀F. ∃x. F x = x",
        expression: "∀F. ∃x. F x = x",
        description: "Higher-order quantification with function application",
        category: :higher_order,
        complexity: :advanced
      },
      
      # Lambda calculus constructs
      %{
        name: "Lambda abstraction: λx. t(x)",
        expression: "λx. t(x)",
        description: "Lambda abstraction defining a function",
        category: :lambda_calculus,
        complexity: :medium
      },
      %{
        name: "Curried application: f x y",
        expression: "f x y",
        description: "Curried function application",
        category: :lambda_calculus,
        complexity: :medium
      },
      %{
        name: "Function composition: (f ∘ g)(x)",
        expression: "(f ∘ g)(x) = f(g(x))",
        description: "Function composition with equality",
        category: :lambda_calculus,
        complexity: :medium
      },
      %{
        name: "Beta‐reduction example: (λx. f x) a ⇒ f a",
        expression: "(λx. f x) a",
        description: "Beta reduction example",
        category: :lambda_calculus,
        complexity: :medium
      },
      %{
        name: "Eta‐conversion example: λx. f x ⇔ f",
        expression: "λx. f x",
        description: "Eta conversion example",
        category: :lambda_calculus,
        complexity: :medium
      },
      
      # Complex logical theorems
      %{
        name: "De Morgan's Law 1",
        expression: "¬(P ∧ Q) ↔ (¬P ∨ ¬Q)",
        description: "First De Morgan's law - negation of conjunction",
        category: :theorems,
        complexity: :medium
      },
      %{
        name: "De Morgan's Law 2",
        expression: "¬(P ∨ Q) ↔ (¬P ∧ ¬Q)",
        description: "Second De Morgan's law - negation of disjunction",
        category: :theorems,
        complexity: :medium
      },
      %{
        name: "Distribution Law",
        expression: "P ∧ (Q ∨ R) ↔ (P ∧ Q) ∨ (P ∧ R)",
        description: "Distribution of conjunction over disjunction",
        category: :theorems,
        complexity: :medium
      },
      %{
        name: "Double Negation",
        expression: "¬¬P ↔ P",
        description: "Double negation elimination",
        category: :theorems,
        complexity: :simple
      },
      %{
        name: "Contraposition",
        expression: "(P → Q) ↔ (¬Q → ¬P)",
        description: "Contraposition law",
        category: :theorems,
        complexity: :medium
      },
      
      # Type theory examples
      %{
        name: "Typed variable",
        expression: "x:o",
        description: "Variable with type annotation",
        category: :type_theory,
        complexity: :simple
      },
      %{
        name: "Typed lambda",
        expression: "λx:i. x",
        description: "Identity function with type annotation",
        category: :type_theory,
        complexity: :medium
      },
      %{
        name: "Polymorphic identity",
        expression: "λα. λx:α. x",
        description: "Polymorphic identity function",
        category: :type_theory,
        complexity: :advanced
      },
      
      # Mathematical examples
      %{
        name: "Addition commutativity",
        expression: "∀x:i. ∀y:i. x + y = y + x",
        description: "Commutativity of addition",
        category: :mathematical,
        complexity: :medium
      },
      %{
        name: "Multiplication distributivity",
        expression: "∀x:i. ∀y:i. ∀z:i. x × (y + z) = (x × y) + (x × z)",
        description: "Distributivity of multiplication over addition",
        category: :mathematical,
        complexity: :advanced
      },
      
      # Paradoxes and interesting cases
      %{
        name: "Liar Paradox",
        expression: "∀P:o. (P ↔ ¬P)",
        description: "Formalization of the Liar Paradox",
        category: :paradoxes,
        complexity: :advanced
      },
      %{
        name: "Russell's Paradox",
        expression: "∃R. ∀x. R x ↔ ¬x x",
        description: "Russell's paradox in set theory",
        category: :paradoxes,
        complexity: :advanced
      }
    ]
  end

  @doc """
  Get examples by category.
  
  ## Examples
  
      iex> Examples.get_by_category(:propositional_logic)
      [%{name: "Simple LEM", expression: "A ∨ ¬A"}, ...]
  """
  def get_by_category(category) do
    get_all_examples()
    |> Enum.filter(fn example -> example.category == category end)
  end

  @doc """
  Get examples by complexity level.
  
  ## Examples
  
      iex> Examples.get_by_complexity(:simple)
      [%{name: "Simple LEM", expression: "A ∨ ¬A"}, ...]
  """
  def get_by_complexity(complexity) do
    get_all_examples()
    |> Enum.filter(fn example -> example.complexity == complexity end)
  end

  @doc """
  Get example expressions only (without metadata).
  
  ## Examples
  
      iex> Examples.get_expressions_only()
      ["A ∨ ¬A", "∀x:o. P x → P x", ...]
  """
  def get_expressions_only do
    get_all_examples()
    |> Enum.map(fn example -> example.expression end)
  end

  @doc """
  Get a random example expression.
  
  ## Examples
  
      iex> Examples.get_random_example()
      %{name: "Simple LEM", expression: "A ∨ ¬A", ...}
  """
  def get_random_example do
    all_examples = get_all_examples()
    Enum.random(all_examples)
  end

  @doc """
  Get examples suitable for testing.
  
  Returns a list of expressions that are good for testing the parser
  and visualization components.
  """
  def get_test_examples do
    [
      "A ∨ ¬A",
      "A ∧ B",
      "A → B",
      "∀x:o. P x",
      "∃x:o. P x",
      "λx. f x",
      "¬(A ∧ B)",
      "(A → B) → (¬B → ¬A)",
      "∀x:i. ∃y:i. x + y = 0",
      "P ↔ Q"
    ]
  end

  @doc """
  Get examples that demonstrate specific features.
  
  ## Examples
  
      iex> Examples.get_feature_examples(:quantifiers)
      ["∀x:o. P x", "∃x:o. P x", "∃!x. P(x)"]
  """
  def get_feature_examples(feature) do
    case feature do
      :quantifiers ->
        ["∀x:o. P x", "∃x:o. P x", "∃!x. P(x)", "∀α. φ(α)", "∃P. φ(P)"]
      :connectives ->
        ["¬P", "P ∧ Q", "P ∨ Q", "P → Q", "P ↔ Q", "P = Q"]
      :lambda_calculus ->
        ["λx. t(x)", "f x y", "(f ∘ g)(x)", "(λx. f x) a", "λx. f x"]
      :types ->
        ["x:o", "λx:i. x", "λα. λx:α. x"]
      :higher_order ->
        ["∀F. ∃x. F x = x", "∃P. φ(P)", "∀α. φ(α)"]
      _ ->
        get_test_examples()
    end
  end

  @doc """
  Get examples that are known to be tautologies.
  
  These examples should evaluate to true in all interpretations.
  """
  def get_tautology_examples do
    [
      "A ∨ ¬A",
      "A → A",
      "¬¬A ↔ A",
      "(A ∧ B) → A",
      "A → (A ∨ B)",
      "¬(A ∧ B) ↔ (¬A ∨ ¬B)",
      "¬(A ∨ B) ↔ (¬A ∧ ¬B)",
      "(A → B) ↔ (¬B → ¬A)",
      "∀x:o. P x → P x",
      "∀x:o. P x ↔ ¬¬P x"
    ]
  end

  @doc """
  Get examples that are known to be contradictions.
  
  These examples should evaluate to false in all interpretations.
  """
  def get_contradiction_examples do
    [
      "A ∧ ¬A",
      "¬(A ∨ ¬A)",
      "(A → B) ∧ (A ∧ ¬B)",
      "∀x:o. P x ∧ ¬P x",
      "∃x:o. P x ∧ ¬P x"
    ]
  end

  @doc """
  Get examples that demonstrate parsing edge cases.
  
  These examples test the parser's ability to handle complex or unusual
  syntactic constructs.
  """
  def get_edge_case_examples do
    [
      "λf. λx. f x",        # Eta reduction
      "λx. λy. x y",       # Multiple abstractions
      "∀x. ∃y. x = y",     # Nested quantifiers
      "¬¬¬A",              # Multiple negations
      "A → (B → C)",       # Right-associative implication
      "(A → B) → C",       # Left-associative implication
      "f (g x)",           # Function application
      "λx:i. x + x",       # Typed lambda with arithmetic
      "∀P:o. P ∨ ¬P",      # Propositional quantification
      "∃x. ∀y. x = y",     # Quantifier order dependency
      "λf. λg. λx. f (g x)" # Function composition
    ]
  end

  @doc """
  Get examples with their expected parsing results.
  
  This is useful for testing the parser against known good results.
  """
  def get_examples_with_expected_results do
    [
      %{
        expression: "A ∨ ¬A",
        expected_type: :binary_operation,
        expected_operator: :disjunction,
        description: "Simple disjunction with negation"
      },
      %{
        expression: "∀x:o. P x → P x",
        expected_type: :quantified,
        expected_quantifier: :forall,
        description: "Universal quantification with implication"
      },
      %{
        expression: "λx. f x",
        expected_type: :lambda,
        description: "Lambda abstraction"
      },
      %{
        expression: "¬(A ∧ B)",
        expected_type: :negation,
        description: "Negation of conjunction"
      }
    ]
  end

  @doc """
  Generate a test file with example expressions.
  
  ## Examples
  
      iex> Examples.generate_test_file("test_expressions.txt")
      :ok
  """
  def generate_test_file(filename) do
    content = Enum.map_join(get_all_examples(), "\n", fn example ->
      "# #{example.name}: #{example.description}\n#{example.expression}\n"
    end)
    
    File.write!(filename, content)
  end

  @doc """
  Load examples from a file.
  
  ## Examples
  
      iex> Examples.load_from_file("expressions.txt")
      ["A ∨ ¬A", "∀x:o. P x → P x", ...]
  """
  def load_from_file(filename) do
    case File.read(filename) do
      {:ok, content} ->
        content
        |> String.split("\n")
        |> Enum.map(&String.trim/1)
        |> Enum.reject(&(&1 == "" or String.starts_with?(&1, "#")))
      {:error, _} ->
        []
    end
  end
end