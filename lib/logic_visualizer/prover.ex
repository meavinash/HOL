defmodule LogicVisualizer.Prover do
  @moduledoc """
  A semantic tableaux prover for determining the validity of logical expressions.
  
  This module implements the semantic tableaux method to check if a formula is:
  - A tautology (always true)
  - A contradiction (always false) 
  - Contingent (can be true or false)
  """

  alias LogicVisualizer.Parser.ExpressionParser

  # A tableau is a tree structure where each node contains a set of formulas
  defstruct branches: [], closed: false, formulas: []

  def prove(ast) do
    IO.puts("--- Proof: Checking for Tautology ---")
    IO.puts("Attempting to refute: ¬(#{ExpressionParser.stringify(ast)})")
    
    negated_formula = negate(ast)
    initial_tableau_refute = %__MODULE__{branches: [[negated_formula]], formulas: [negated_formula]}
    initial_tree_refute = ["¬(#{ExpressionParser.stringify(ast)})"]
    
    {result_refute, steps_refute, proof_tree_refute} = expand_tableau(initial_tableau_refute, 0, initial_tree_refute)

    case result_refute do
      :closed ->
        # If refutation leads to a closed tableau, it's a tautology
        {:ok, :tautology, steps_refute, proof_tree_refute}
      :open ->
        # If refutation tableau is open, it could be a contradiction or contingent
        IO.puts("\n--- Proof: Checking for Contradiction ---")
        IO.puts("Attempting to prove: #{ExpressionParser.stringify(ast)}")

        initial_tableau_prove = %__MODULE__{branches: [[ast]], formulas: [ast]}
        initial_tree_prove = [ExpressionParser.stringify(ast)]
        {result_prove, steps_prove, proof_tree_prove} = expand_tableau(initial_tableau_prove, 0, initial_tree_prove)

        case result_prove do
          :closed ->
            # If the original formula's tableau closes, it's a contradiction
            {:ok, :contradiction, steps_prove, proof_tree_prove}
          :open ->
            # If both tableaux are open, it's contingent
            # We return the results from the original refutation attempt for consistency
            {:ok, :contingent, steps_refute, proof_tree_refute}
        end
    end
  end

  # Negate a formula
  defp negate(ast) do
    case ast do
      %{type: :negation, expr: expr} -> expr  # ¬¬P becomes P
      _ -> %{type: :negation, expr: ast}      # P becomes ¬P
    end
  end

  # Main tableau expansion algorithm
  defp expand_tableau(tableau, step, proof_tree) when step < 20 do
    IO.puts("\nStep #{step + 1}:")

    if all_branches_closed?(tableau.branches) do
      IO.puts("All branches are closed!")
      {:closed, step + 1, proof_tree}
    else
      case find_expandable_branch(tableau.branches) do
        nil ->
          IO.puts("No more expandable formulas. Some branches remain open.")
          {:open, step + 1, proof_tree}
        {branch_index, formula} ->
          {new_branches, rule_description} = expand_formula(tableau.branches, branch_index, formula)
          new_tableau = %{tableau | branches: new_branches}
          updated_proof_tree = build_proof_tree(proof_tree, rule_description)
          
          expand_tableau(new_tableau, step + 1, updated_proof_tree)
      end
    end
  end

  defp expand_tableau(_tableau, step, proof_tree) do
    IO.puts("\nReached maximum depth (#{step} steps). Terminating proof search.")
    {:open, step, proof_tree}
  end

  # Check if all branches are closed
  defp all_branches_closed?(branches) do
    Enum.all?(branches, &branch_closed?/1)
  end

  # Check if a single branch is closed (contains both P and ¬P or paradoxical formulas)
  defp branch_closed?(branch) do
    # A branch is closed if it contains a formula and its negation, or a paradoxical formula.
    # We create a set of formulas for efficient lookup.
    formula_set = Enum.into(branch, MapSet.new())
    
    # Case 1: Direct contradiction (P and ¬P)
    basic_contradiction = Enum.any?(formula_set, fn formula ->
      negation = negate(formula)
      MapSet.member?(formula_set, negation)
    end)
    
    # Case 2: Paradoxical formulas like P ↔ ¬P
    paradox = Enum.any?(branch, fn formula ->
      case formula do
        # Check for biconditional of the form P ↔ ¬P (Russell's Paradox pattern)
        %{type: :binary_operation, operator: :biconditional, left: left, right: %{type: :negation, expr: expr}} ->
          # If left == expr, we have P ↔ ¬P which is a contradiction
          are_equivalent?(left, expr)
        
        %{type: :binary_operation, operator: :biconditional, left: %{type: :negation, expr: expr}, right: right} ->
          # If right == expr, we have ¬P ↔ P which is a contradiction
          are_equivalent?(right, expr)
        
        # Special case: Russell's Paradox self-referential application
        # Pattern: R_sk(R_sk) ↔ ¬(R_sk(R_sk))
        %{type: :binary_operation, operator: :biconditional,
          left: %{type: :application, fun: %{type: :identifier, name: fun_name}, 
                  arg: %{type: :identifier, name: arg_name}},
          right: %{type: :negation, expr: %{type: :application, 
                                            fun: %{type: :identifier, name: neg_fun_name}, 
                                            arg: %{type: :identifier, name: neg_arg_name}}}}
        when fun_name == arg_name and fun_name == neg_fun_name and fun_name == neg_arg_name ->
          if String.contains?(fun_name, "_sk_") do
            true  # This is Russell's Paradox: R_sk(R_sk) ↔ ¬(R_sk(R_sk))
          else
            false
          end
        
        # Not a paradoxical formula
        _ -> false
      end
    end)
    
    basic_contradiction || paradox
  end
  
  # Check if two formulas are structurally equivalent (ignoring markers)
  defp are_equivalent?(formula1, formula2) do
    # Strip marker metadata for comparison
    clean1 = strip_markers(formula1)
    clean2 = strip_markers(formula2)
    
    # Compare the cleaned formulas
    ExpressionParser.stringify(clean1) == ExpressionParser.stringify(clean2)
  end
  
  # Remove marker metadata from formulas for clean comparison
  defp strip_markers(formula) do
    case formula do
      %{type: :instantiated_forall} -> formula.original
      %{type: :instantiated_neg_forall} -> formula.original
      %{type: :instantiated_neg_exists} -> formula.original
      _ -> formula
    end
  end

  # Find a branch and formula that can be expanded
  def find_expandable_branch(branches) do
    IO.puts("Current branches:")
    branches
    |> Enum.with_index()
    |> Enum.each(fn {branch, index} ->
      status = if branch_closed?(branch), do: "CLOSED", else: "OPEN"
      branch_str = branch |> Enum.map(&ExpressionParser.stringify/1) |> Enum.join(", ")
      IO.puts("  Branch #{index + 1} (#{status}): [#{branch_str}]")
    end)
    
    branches
    |> Enum.with_index()
    |> Enum.find_value(fn {branch, index} ->
      unless branch_closed?(branch) do
        expandable_formula = Enum.find(branch, &expandable?(&1, branch))
        if expandable_formula do
          IO.puts("Found expandable formula: #{ExpressionParser.stringify(expandable_formula)} in branch #{index + 1}")
          {index, expandable_formula}
        end
      end
    end)
  end

  # Check if a formula can be expanded
  defp expandable?(formula, branch) do
    case formula do
      %{type: :binary_operation, operator: op} when op in [:conjunction, :disjunction, :implication, :biconditional] -> true
      %{type: :negation, expr: %{type: :binary_operation, operator: op}} when op in [:conjunction, :disjunction, :implication, :biconditional] -> true
      %{type: :negation, expr: %{type: :negation}} -> true
      %{type: :quantified, quantifier: :exists} -> true
      %{type: :quantified, quantifier: :exists_unique} -> true
      %{type: :quantified, quantifier: :forall} ->
        # Only expand forall once with a fresh constant to avoid infinite loops
        instantiated_formulas = Enum.filter(branch, fn f -> 
          match?(%{type: :instantiated_forall, original: ^formula}, f)
        end)
        Enum.empty?(instantiated_formulas)
      %{type: :negation, expr: %{type: :quantified, quantifier: :forall}} ->
        # ¬∀x. P(x) - only expand once
        instantiated_formulas = Enum.filter(branch, fn f -> 
          match?(%{type: :instantiated_neg_forall, original: ^formula}, f)
        end)
        Enum.empty?(instantiated_formulas)
      %{type: :negation, expr: %{type: :quantified, quantifier: :exists}} ->
        # ¬∃x. P(x) - only expand once  
        instantiated_formulas = Enum.filter(branch, fn f -> 
          match?(%{type: :instantiated_neg_exists, original: ^formula}, f)
        end)
        Enum.empty?(instantiated_formulas)

      _ -> false
    end
  end

  # Expand a formula in a specific branch
  defp expand_formula(branches, branch_index, formula) do
    branch = Enum.at(branches, branch_index)
    
    case formula do
      # α-formulas (non-branching)
      %{type: :binary_operation, operator: :conjunction, left: left, right: right} ->
        new_branch = (branch -- [formula]) ++ [left, right]
        rule = {:alpha, :conjunction, ExpressionParser.stringify(left), ExpressionParser.stringify(right)}
        {List.replace_at(branches, branch_index, new_branch), rule}
      
      %{type: :negation, expr: %{type: :binary_operation, operator: :disjunction, left: left, right: right}} ->
        neg_left = negate(left)
        neg_right = negate(right)
        new_branch = (branch -- [formula]) ++ [neg_left, neg_right]
        rule = {:alpha, :neg_disjunction, ExpressionParser.stringify(neg_left), ExpressionParser.stringify(neg_right)}
        {List.replace_at(branches, branch_index, new_branch), rule}
      
      %{type: :negation, expr: %{type: :binary_operation, operator: :implication, left: left, right: right}} ->
        neg_right = negate(right)
        new_branch = (branch -- [formula]) ++ [left, neg_right]
        rule = {:alpha, :neg_implication, ExpressionParser.stringify(left), ExpressionParser.stringify(neg_right)}
        {List.replace_at(branches, branch_index, new_branch), rule}
      
      %{type: :negation, expr: %{type: :negation, expr: inner}} ->
        new_branch = branch -- [formula] ++ [inner]
        rule = {:alpha, :double_negation, ExpressionParser.stringify(inner), nil}
        {List.replace_at(branches, branch_index, new_branch), rule}
      
      # β-formulas (branching)
      %{type: :binary_operation, operator: :disjunction, left: left, right: right} ->
        branch_without_formula = branch -- [formula]
        left_branch = branch_without_formula ++ [left]
        right_branch = branch_without_formula ++ [right]
        branches_updated = List.replace_at(branches, branch_index, left_branch)
        rule = {:beta, :disjunction, ExpressionParser.stringify(left), ExpressionParser.stringify(right)}
        {branches_updated ++ [right_branch], rule}
      
      %{type: :binary_operation, operator: :implication, left: left, right: right} ->
        branch_without_formula = branch -- [formula]
        neg_left = negate(left)
        left_branch = branch_without_formula ++ [neg_left]
        right_branch = branch_without_formula ++ [right]
        branches_updated = List.replace_at(branches, branch_index, left_branch)
        rule = {:beta, :implication, ExpressionParser.stringify(neg_left), ExpressionParser.stringify(right)}
        {branches_updated ++ [right_branch], rule}
      
      %{type: :negation, expr: %{type: :binary_operation, operator: :conjunction, left: left, right: right}} ->
        branch_without_formula = branch -- [formula]
        neg_left = negate(left)
        neg_right = negate(right)
        left_branch = branch_without_formula ++ [neg_left]
        right_branch = branch_without_formula ++ [neg_right]
        branches_updated = List.replace_at(branches, branch_index, left_branch)
        rule = {:beta, :neg_conjunction, ExpressionParser.stringify(neg_left), ExpressionParser.stringify(neg_right)}
        {branches_updated ++ [right_branch], rule}
      
      # Biconditional expansion
      %{type: :binary_operation, operator: :biconditional, left: left, right: right} ->
        branch_without_formula = branch -- [formula]
        left_conj = %{type: :binary_operation, operator: :conjunction, left: left, right: right}
        neg_left = negate(left)
        neg_right = negate(right)
        right_conj = %{type: :binary_operation, operator: :conjunction, left: neg_left, right: neg_right}
        left_branch = branch_without_formula ++ [left_conj]
        right_branch = branch_without_formula ++ [right_conj]
        branches_updated = List.replace_at(branches, branch_index, left_branch)
        rule = {:beta, :biconditional, ExpressionParser.stringify(left_conj), ExpressionParser.stringify(right_conj)}
        {branches_updated ++ [right_branch], rule}
      
      %{type: :negation, expr: %{type: :binary_operation, operator: :biconditional, left: left, right: right}} ->
        branch_without_formula = branch -- [formula]
        neg_right = negate(right)
        neg_left = negate(left)
        left_conj = %{type: :binary_operation, operator: :conjunction, left: left, right: neg_right}
        right_conj = %{type: :binary_operation, operator: :conjunction, left: neg_left, right: right}
        left_branch = branch_without_formula ++ [left_conj]
        right_branch = branch_without_formula ++ [right_conj]
        branches_updated = List.replace_at(branches, branch_index, left_branch)
        rule = {:beta, :neg_biconditional, ExpressionParser.stringify(left_conj), ExpressionParser.stringify(right_conj)}
        {branches_updated ++ [right_branch], rule}
      
      # Quantifier expansion
      %{type: :quantified, quantifier: :forall, var: var, expr: expr} ->
        # Create a fresh constant and instantiate
        fresh_constant = generate_fresh_constant(branch)
        instantiated_formula = substitute_variable(expr, var, fresh_constant)
        
        marker = %{type: :instantiated_forall, original: formula}
        new_branch = branch ++ [instantiated_formula, marker]
        rule = {:gamma, ExpressionParser.stringify(var), ExpressionParser.stringify(formula), ExpressionParser.stringify(instantiated_formula)}
        {List.replace_at(branches, branch_index, new_branch), rule}
      
      %{type: :quantified, quantifier: :exists, var: var, expr: expr} ->
        # Create a Skolem constant and instantiate
        skolem_constant = generate_skolem_constant(var, branch)
        instantiated_formula = substitute_variable(expr, var, skolem_constant)
        new_branch = (branch -- [formula]) ++ [instantiated_formula]
        rule = {:delta, ExpressionParser.stringify(var), ExpressionParser.stringify(formula), ExpressionParser.stringify(instantiated_formula)}
        {List.replace_at(branches, branch_index, new_branch), rule}
      
      %{type: :quantified, quantifier: :exists_unique, var: var, expr: expr} ->
        # ∃!x.P(x) ≡ ∃x.(P(x) ∧ ∀y.(P(y) → y = x))
        skolem_constant = generate_skolem_constant(var, branch)
        instantiated_formula = substitute_variable(expr, var, skolem_constant)
        new_branch = (branch -- [formula]) ++ [instantiated_formula]
        rule = {:delta, ExpressionParser.stringify(var), ExpressionParser.stringify(formula), ExpressionParser.stringify(instantiated_formula)}
        {List.replace_at(branches, branch_index, new_branch), rule}
      
      %{type: :negation, expr: %{type: :quantified, quantifier: :forall, var: var, expr: expr}} ->
        # ¬∀x. P(x) ≡ ∃x. ¬P(x)
        neg_expr = negate(expr)
        skolem_constant = generate_skolem_constant(var, branch)
        instantiated_formula = substitute_variable(neg_expr, var, skolem_constant)
        marker = %{type: :instantiated_neg_forall, original: formula}
        new_branch = (branch -- [formula]) ++ [instantiated_formula, marker]
        rule = {:delta, ExpressionParser.stringify(var), ExpressionParser.stringify(formula), ExpressionParser.stringify(instantiated_formula)}
        {List.replace_at(branches, branch_index, new_branch), rule}
      
      %{type: :negation, expr: %{type: :quantified, quantifier: :exists, var: var, expr: expr}} ->
        # ¬∃x. P(x) ≡ ∀x. ¬P(x)
        neg_expr = negate(expr)
        fresh_constant = generate_fresh_constant(branch)
        instantiated_formula = substitute_variable(neg_expr, var, fresh_constant)
        marker = %{type: :instantiated_neg_exists, original: formula}
        new_branch = branch ++ [instantiated_formula, marker]
        rule = {:gamma, ExpressionParser.stringify(var), ExpressionParser.stringify(formula), ExpressionParser.stringify(instantiated_formula)}
        {List.replace_at(branches, branch_index, new_branch), rule}
      
      # Equality - treat as atomic for now (contingent)
      %{type: :binary_operation, operator: :equality, left: _left, right: _right} ->
        {branches, {:other, ExpressionParser.stringify(formula)}}
      
      %{type: :negation, expr: %{type: :binary_operation, operator: :equality, left: _left, right: _right}} ->
        {branches, {:other, ExpressionParser.stringify(formula)}}

      _ ->
        {branches, {:other, ExpressionParser.stringify(formula)}}
    end
  end

  # These functions were previously used for formula equivalence checking
  # but are no longer needed with the current tableau implementation
  # Keeping them commented for potential future use
  
  # defp formulas_equivalent?(f1, f2) do
  #   normalize_formula(f1) == normalize_formula(f2)
  # end

  # defp normalize_formula(formula) do
  #   case formula do
  #     %{type: :negation, expr: %{type: :negation, expr: inner}} -> normalize_formula(inner)
  #     %{type: :negation, expr: expr} -> %{type: :negation, expr: normalize_formula(expr)}
  #     %{type: :binary_operation, operator: op, left: left, right: right} ->
  #       %{type: :binary_operation, operator: op, left: normalize_formula(left), right: normalize_formula(right)}
  #     _ -> formula
  #   end
  # end


  defp generate_fresh_constant(branch) do
    existing_constants = branch
    |> Enum.flat_map(&extract_constants/1)
    |> Enum.to_list()
    
    # Find the highest numbered constant and add 1
    highest_num = existing_constants
    |> Enum.map(fn name -> 
      if String.starts_with?(name, "c_") do
        {num, _} = name |> String.trim_leading("c_") |> Integer.parse()
        num
      else
        0
      end
    end)
    |> Enum.max(fn -> 0 end)
    
    "c_#{highest_num + 1}"
  end

  defp generate_skolem_constant(var, branch) do
    existing_constants = branch
    |> Enum.flat_map(&extract_constants/1)
    |> Enum.to_list()

    base_name = ExpressionParser.stringify(var)
    "#{base_name}_sk_#{Enum.count(existing_constants) + 1}"
  end

  defp extract_constants(formula) do
    case formula do
      %{type: :variable, name: name} -> [name]
      %{type: :identifier, name: name} -> [name]
      %{type: :typed_variable, var: var} -> extract_constants(var)
      %{type: :negation, expr: expr} -> extract_constants(expr)
      %{type: :binary_operation, left: left, right: right} ->
        extract_constants(left) ++ extract_constants(right)
      %{type: :quantified, expr: expr} -> extract_constants(expr)
      %{type: :application, fun: fun, arg: arg} -> extract_constants(fun) ++ extract_constants(arg)
      _ -> []
    end
  end

  defp substitute_variable(expr, var_to_replace, new_term) do
    var_name_to_replace =
      case var_to_replace do
        %{type: :typed_variable, var: %{name: name}} -> name
        %{type: :variable, name: name} -> name
        _ -> nil # Should not happen
      end

    if var_name_to_replace == nil do
      expr
    else
      do_substitute(expr, var_name_to_replace, %{type: :identifier, name: new_term})
    end
  end

  defp do_substitute(expr, var_name, new_term_ast) do
    case expr do
      %{type: :variable, name: name} when name == var_name ->
        new_term_ast
      %{type: :application, fun: %{type: :identifier, name: fun_name}, arg: arg} when fun_name == var_name ->
        # Special case for self-application, e.g., x(x)
        %{expr | fun: new_term_ast, arg: do_substitute(arg, var_name, new_term_ast)}
      %{type: :application, fun: fun, arg: arg} ->
        %{expr | 
          fun: do_substitute(fun, var_name, new_term_ast),
          arg: do_substitute(arg, var_name, new_term_ast)
        }
      %{type: :negation, expr: inner_expr} ->
        %{expr | expr: do_substitute(inner_expr, var_name, new_term_ast)}
      %{type: :binary_operation, left: left, right: right} ->
        %{expr | 
          left: do_substitute(left, var_name, new_term_ast),
          right: do_substitute(right, var_name, new_term_ast)
        }
      %{type: :quantified, var: q_var, expr: inner_expr} ->
        q_var_name = 
          case q_var do
            %{type: :typed_variable, var: %{name: name}} -> name
            %{type: :variable, name: name} -> name
            _ -> nil
          end
        
        if q_var_name == var_name do
          expr # Shadowed
        else
          %{expr | expr: do_substitute(inner_expr, var_name, new_term_ast)}
        end
      _ -> expr
    end
  end

  # Build the ASCII proof tree visualization
  defp build_proof_tree(current_tree, rule_description) do
    # For each step, we add a new level to the tree showing the decomposition
    current_tree ++ [build_tree_node(rule_description)]
  end

  defp build_tree_node({:alpha, type, f1, f2}) do
    case type do
      :conjunction ->
        "                       (#{f1} ∧ #{f2})\n" <>
        "                               │\n" <>
        "                    Decompose A ∧ B\n" <>
        "                               │\n" <>
        "                       ┌───────┴───────┐\n" <>
        "                       │               │\n" <>
        "                    #{f1}           #{f2}\n"
      
      :neg_disjunction ->
        "                       ¬(A ∨ B)\n" <>
        "                               │\n" <>
        "                   Decompose ¬(∨)\n" <>
        "                               │\n" <>
        "                       ┌───────┴───────┐\n" <>
        "                       │               │\n" <>
        "                    #{f1}           #{f2}\n"
      
      :neg_implication ->
        "                          ¬(Implication)\n" <>
        "                               │\n" <>
        "               ┌──────────────┴──────────────┐\n" <>
        "               │                             │\n" <>
        "        Decompose outer ¬→              (Assume premises)\n" <>
        "          yields: #{f1}, #{f2}\n" <>
        "               │\n" <>
        "       ┌───────┴────────┐\n" <>
        "       │                │\n" <>
        "   [#{f1} is true]     [#{f2} is false]\n" <>
        "                                 │\n" <>
        "            ┌───────────┴───────────┐\n" <>
        "            │                       │\n" <>
        "        #{f1} and ¬#{f1} ⇒         #{f2} and ¬#{f2} ⇒\n" <>
        "         contradiction           contradiction\n"
      
      :double_negation ->
        "                       ¬¬#{f1}\n" <>
        "                               │\n" <>
        "                Double Negation Elimination\n" <>
        "                               │\n" <>
        "                            #{f1}\n"
    end
  end

  defp build_tree_node({:beta, type, f1, f2}) do
    case type do
      :disjunction ->
        "                       (#{f1} ∨ #{f2})\n" <>
        "                               │\n" <>
        "               ┌──────────────┴──────────────┐\n" <>
        "               │                             │\n" <>
        "           Branch 1                      Branch 2\n" <>
        "            #{f1}                          #{f2}\n"
      
      :implication ->
        "                       (#{f1} → #{f2})\n" <>
        "                               │\n" <>
        "               ┌──────────────┴──────────────┐\n" <>
        "               │                             │\n" <>
        "           Branch 1                      Branch 2\n" <>
        "            #{f1}                          #{f2}\n"
      
      :biconditional ->
        "                       (#{f1} ↔ #{f2})\n" <>
        "                               │\n" <>
        "               ┌──────────────┴──────────────┐\n" <>
        "               │                             │\n" <>
        "           Branch 1                      Branch 2\n" <>
        "        (#{f1} ∧ #{f2})                 (¬#{f1} ∧ ¬#{f2})\n"
      
      :neg_conjunction ->
        "                       ¬(#{f1} ∧ #{f2})\n" <>
        "                               │\n" <>
        "               ┌──────────────┴──────────────┐\n" <>
        "               │                             │\n" <>
        "           Branch 1                      Branch 2\n" <>
        "            #{f1}                          #{f2}\n"
      
      :neg_biconditional ->
        "                       ¬(#{f1} ↔ #{f2})\n" <>
        "                               │\n" <>
        "               ┌──────────────┴──────────────┐\n" <>
        "               │                             │\n" <>
        "           Branch 1                      Branch 2\n" <>
        "        (#{f1} ∧ ¬#{f2})                (¬#{f1} ∧ #{f2})\n"
    end
  end

  defp build_tree_node({:gamma, var, _original_expr, new_expr}) do
    "γ-Rule (∀#{var})\n" <>
    "   │\n" <>
    "   └─ Instantiated: #{new_expr}\n"
  end

  defp build_tree_node({:delta, var, _original_expr, new_expr}) do
    "δ-Rule (∃#{var})\n" <>
    "   │\n" <>
    "   └─ Instantiated: #{new_expr}\n"
  end

  defp build_tree_node({:other, formula_str}) do
    "(#{formula_str})\n"
  end

end

