defmodule LogicVisualizer.Education do
  @moduledoc """
  Educational content for the Logic Visualizer.
  
  This module provides explanations for various logical concepts, including operators, quantifiers, and lambda calculus.
  """

  def explain(:negation), do: "Negation (¬) inverts the truth value of a proposition. If P is true, ¬P is false."
  def explain(:conjunction), do: "Conjunction (∧) is true if and only if both of its operands are true."
  def explain(:disjunction), do: "Disjunction (∨) is true if at least one of its operands is true."
  def explain(:implication), do: "Implication (→) is false only when the first operand is true and the second is false."
  def explain(:biconditional), do: "Biconditional (↔) is true if both operands have the same truth value."
  def explain(:equality), do: "Equality (=) indicates that two terms or expressions have the same value."
  def explain(:addition), do: "Addition (+) is the arithmetic operation that combines two numbers or expressions."
  def explain(:multiplication), do: "Multiplication (×) is the arithmetic operation that represents repeated addition."
  def explain(:composition), do: "Function composition (∘) combines two functions where (f ∘ g)(x) = f(g(x))."
  def explain(:forall), do: "The universal quantifier (∀) means 'for all'. It asserts that a property is true for all individuals in a domain."
  def explain(:exists), do: "The existential quantifier (∃) means 'there exists'. It asserts that a property is true for at least one individual in a domain."
  def explain(:exists_unique), do: "The unique existential quantifier (∃!) means 'there exists exactly one'."
  def explain(:lambda), do: "Lambda (λ) is used to form abstractions. For example, λx. P(x) is the function that takes an argument x and returns the value of P(x)."
  def explain(_), do: "No explanation available for this concept."
end
