defmodule HOL.Data.Unification do
  @moduledoc """
  This module defines the datastructures used in the unification
  """

  require Record

  @typedoc """
  Contains two terms in a tuple.
  """
  @type term_pair :: {HOL.Data.hol_term(), HOL.Data.hol_term()}

  @doc """
  Creates a new Unification Solution.

  This function should not need be called under normal usage of this Package.

  This Dataformat uses a `Record`.
  """
  Record.defrecord(
    :unification_solution,
    :unif_sol,
    substitutions: [],
    flexlist: []
  )

  @typedoc """
  Represents a single solution of a unification problem.

  The flexlist represents cases where the head of two terms are both free variables.
  As this situation has many (often infinite) solutions, no concrete substitutions are created.

  **Key** | **Data stored** | **Accessor Function**
  :substitutions | The substitutions needed to unify the terms | `get_substitutions/1`
  :flexlist | List of flexflex pairs | `get_flexlist/1`
  """
  @type unification_solution() ::
          record(
            :unification_solution,
            substitutions: [HOL.Data.substitution()],
            flexlist: [HOL.Data.Unification.term_pair()]
          )

  @doc """
  Accessor function for the flexlist
  """
  @spec get_flexlist(unification_solution()) :: [HOL.Data.Unification.term_pair()]
  def get_flexlist(unification_solution(flexlist: f)), do: f

  @doc """
  Accessor function for the substitutions
  """
  @spec get_substitutions(unification_solution()) :: [HOL.Data.substitution()]
  def get_substitutions(unification_solution(substitutions: s)), do: s

  @doc """
  Creates a new Unification Result.

  This function should not need be called under normal usage of this Package.

  This Dataformat uses a `Record`.
  """
  Record.defrecord(
    :unification_results,
    :unif_res_sum,
    solutions: [],
    max_depth_reached_count: 0
  )

  @typedoc """
  Represents the summarized results from the unification.

  **Key** | **Data stored** | **Accessor Function**
  :solutions | List of unification_solutions | `get_solutions/1`
  :max_depth_reached_count | The amount of branches that couldn't terminate due to the max_depth limit | `get_max_depth_count/1`
  """
  @type unification_results() ::
          record(
            :unification_results,
            solutions: [unification_solution()],
            max_depth_reached_count: non_neg_integer()
          )

  @doc """
  Accessor function for the solutions
  """
  @spec get_solutions(unification_results()) :: [unification_solution()]
  def get_solutions(unification_results(solutions: sol)), do: sol

  @doc """
  Accessor function for the max_depth count
  """
  @spec get_max_depth_count(unification_results()) :: non_neg_integer()
  def get_max_depth_count(unification_results(max_depth_reached_count: m)), do: m
end
