defmodule HOL.Data do
  @moduledoc """
  This module defines the datastructures used in the application
  """
  require Record

  @doc group: :Type
  @doc """
  Creates a new type. This function should not need be called under normal usage of this Package

  This Dataformat uses a `Record`.
  """
  Record.defrecord(:type, goal: nil, args: [])

  @typedoc """
  This type encodes the type information for a HOL term or declaration.

  It has its goal type stored as an atom, with all input types in a list.

  ** Key ** | **Data stored** | **Accessor Function**
  :goal | Goal Type | `get_goal_type/1`
  :args | List of argument types | `get_arg_types/1`

  ## Examples

      # base type i is encoded as
        iex> mk_type(:i)
        {:type, :i, []}

        # function type i->o is encoded as
        iex> mk_type(:o, [mk_type(:i)])
        {:type, :o, [{:type, :i, []}]}

  """
  @type type() :: record(:type, goal: atom(), args: [type()])

  @doc group: :Type
  @doc """
  Accessor function for goal type
  """
  @spec get_goal_type(type()) :: atom()
  def get_goal_type(t), do: type(t, :goal)

  @doc group: :Type
  @doc """
  Accessor function for argument types
  """
  @spec get_arg_types(type()) :: [type()]
  def get_arg_types(t), do: type(t, :args)

  @doc group: :Type
  @doc """
  Creates a base type without arguments.

  ## Examples

      # Creates base type i
      iex> mk_type(:i)
      {:type, :i, []}

      # Creates base type o
      iex> mk_type(:o)
      {:type, :o, []}
  """
  @spec mk_type(atom()) :: type()
  def mk_type(goal_type) when is_atom(goal_type), do: mk_type(goal_type, [])

  @doc group: :Type
  @doc """
  Creates a type with the given arguments.

  The goal type is always stored as an atom, but it doesn't have to be given as such

  ## Parameters

    - goal_type: Atom or `type()` that represents the goal type
    - arg_types: List of `type()` that represents the argument types

  ## Examples

      # Creates type i->i
      iex> mk_type(:i, [mk_type(:i)])
      {:type, :i, [{:type, :i, []}]}

      # Creates type i->i->i
      iex> mk_type(mk_type(:o, [mk_type(:i)]), [mk_type(:i)])
      {:type, :o, [{:type, :i, []}, {:type, :i, []}]}

      # Creates type i->i->i (identical to previous)
      iex> mk_type(:o, [mk_type(:i), mk_type(:i)])
      {:type, :o, [{:type, :i, []}, {:type, :i, []}]}

      # Creates type (i->i)->i->i
      iex> mk_type(:i, [mk_type(:i, [mk_type(:i)]), mk_type(:i)])
      {:type, :i, [{:type, :i, [{:type, :i, []}]}, {:type, :i, []}]}
  """
  @spec mk_type(atom(), [type()]) :: type()
  def mk_type(goal_type, arg_types) when is_atom(goal_type),
    do: type(goal: goal_type, args: arg_types)

  @spec mk_type(type(), [type()]) :: type()
  def mk_type(type(goal: goal_type, args: arg_types_1), arg_types_2) do
    mk_type(goal_type, arg_types_2 ++ arg_types_1)
  end

  # Declaration
  @doc group: :Declaration
  @doc """
  Creates a new declaration. This function should not need be called under normal usage of this Package

  This Dataformat uses a `Record`.
  """
  Record.defrecord(:declaration, :decl, kind: nil, name: nil, type: nil)

  @typedoc """
  Combination type representing free variables, bound variables and constants.

  ** Key ** | **Data stored** | **Accessor Function**
  :kind | Whether it is a free or bound variable or constant | `get_kind/1`
  :name | Name | `get_name/1`
  :type | Type | `get_type/1`
  """
  @type declaration() :: free_var_decl() | const_decl() | bound_var_decl()

  @typedoc """
  Represents a free variable.

  The name can be either a string or a reference.
  """
  @type free_var_decl() :: {:decl, :fv, String.t() | reference(), type()}

  @typedoc """
  Represents a constant.

  The name must be a string.
  """
  @type const_decl() :: {:decl, :co, String.t(), type()}

  @typedoc """
  Represents a bound variable.

  The name must be a positive integer.
  """
  @type bound_var_decl() :: {:decl, :bv, pos_integer(), type()}

  @doc group: :Declaration
  @doc """
  Accessor function for type of declaration.

  Returns
    - `:fv` when given a free variable
    - `:bv` when given a bound variable
    - `:co` when given a constant
  """
  @spec get_kind(declaration()) :: :fv | :bv | :co
  def get_kind(declaration(kind: kind)), do: kind

  @doc group: :Declaration
  @doc """
  Accessor function for the identifier
  """
  @spec get_name(declaration()) :: String.t() | pos_integer() | reference()
  def get_name(declaration(name: name)), do: name

  @doc group: :Declaration
  @doc """
  Accessor function for the type
  """
  @spec get_type(declaration()) :: type()
  def get_type(declaration(type: type)), do: type

  @doc group: :Declaration
  # Constructor functions
  @doc """
  Creates a free variable with the given name and type.

  Also see function `mk_uniqe_var/1` for creating a uniqe variable

  ## Example

      iex> mk_free_var("x", mk_type(:i))
      {:decl, :fv, "x", {:type, :i, []}}
  """
  @spec mk_free_var(String.t(), type()) :: free_var_decl()
  def mk_free_var(name, type) when is_binary(name) or is_reference(name),
    do: declaration(kind: :fv, name: name, type: type)

  @doc group: :Declaration
  @doc """
  Creates a bound variable with the given id and type.

  This function should not need be called under normal usage of this Package

  ## Example

      iex> mk_bound_var(1, mk_type(:i))
      {:decl, :bv, 1, {:type, :i, []}}
  """
  @spec mk_bound_var(non_neg_integer(), type()) :: bound_var_decl()
  def mk_bound_var(nat, type) when is_integer(nat) and nat >= 0,
    do: declaration(kind: :bv, name: nat, type: type)

  @doc group: :Declaration
  @doc """
  Creates a constant with the given name and type.

  ## Example

      iex> mk_const("x", mk_type(:i))
      {:decl, :co, "x", {:type, :i, []}}
  """
  @spec mk_const(String.t(), type()) :: const_decl()
  def mk_const(id, type) when is_binary(id),
    do: declaration(kind: :co, name: id, type: type)

  @doc group: :Declaration
  @doc """
  Creates a free variable with a unique name and type.

  The name is created via the function `Kernel.make_ref/0`. See the corresponding documentation for the limitations of this function.

  Also see function `mk_free_var/2` for creating a named free variable
  """
  @spec mk_uniqe_var(type()) :: free_var_decl()
  def mk_uniqe_var(type),
    do: declaration(kind: :fv, name: make_ref(), type: type)

  # Terms
  @doc group: :Term
  @doc """
  Creates a new term.

  For creating new terms see `HOL.Terms.mk_term/1`

  This function should not need be called under normal usage of this Package.

  This Dataformat uses a `Record`.
  """
  Record.defrecord(:hol_term, :term,
    bvars: [],
    head: {:decl, nil, nil, nil},
    args: [],
    type: {:type, nil, []},
    fvars: [],
    max_num: 0
  )

  @typedoc """
  Represents a term in the simply typed lambda calculus.

  Terms are always automatically beta-reduced and eta-expanded.

  ** Key ** | **Data stored** | **Accessor Function**
  :bvars | A list of bound variables that are bound here | `get_bvars/1`
  :head | The head of the term | `get_head/1`
  :args | A list of terms that are applied to the head | `get_args/1`
  :type | The type of the term | `get_term_type/1`
  :fvars | A list of all free variables in the term | `get_fvars/1`
  :max_num | The highest bound variable that is bound here or in one of the args | `get_max_num/1`
  """
  @type hol_term() ::
          record(
            :hol_term,
            bvars: [bound_var_decl()],
            head: declaration(),
            args: [hol_term()],
            type: type(),
            fvars: [free_var_decl()],
            max_num: non_neg_integer()
          )

  # Term Accessor functions
  @doc group: :Term
  @doc """
  Accessor function for the bound variables of the term
  """
  @spec get_bvars(hol_term()) :: [bound_var_decl()]
  def get_bvars(hol_term(bvars: bvars)), do: bvars

  @doc group: :Term
  @doc """
  Accessor function for head of the term
  """
  @spec get_head(hol_term()) :: declaration()
  def get_head(hol_term(head: head)), do: head

  @doc group: :Term
  @doc """
  Accessor function for the arguments of the term
  """
  @spec get_args(hol_term()) :: [hol_term()]
  def get_args(hol_term(args: args)), do: args

  @doc group: :Term
  @doc """
  Accessor function for the type of the term
  """
  @spec get_term_type(hol_term()) :: type()
  def get_term_type(hol_term(type: type)), do: type

  @doc group: :Term
  @doc """
  Accessor function for the free variables in the term
  """
  @spec get_fvars(hol_term()) :: [free_var_decl()]
  def get_fvars(hol_term(fvars: fvars)), do: fvars

  @doc group: :Term
  @doc """
  Accessor function for the max_num of the term
  """
  @spec get_max_num(hol_term()) :: non_neg_integer()
  def get_max_num(hol_term(max_num: max_num)), do: max_num

  # Substitution
  @doc group: :Substitution
  @doc """
  Creates a new substitution.

  This Dataformat uses a `Record`.
  """
  Record.defrecord(
    :substitution,
    :subst,
    fvar: nil,
    term: nil
  )

  @typedoc """
  Represents a substitution of a free variable with a term

  **Key** | **Data stored** | **Accessor Function**
  :fvar | Free Variable to Replace | `get_fvar/1`
  :term | Replacement Term | `get_term/1`
  """
  @type substitution() ::
          record(
            :substitution,
            fvar: free_var_decl(),
            term: hol_term()
          )

  @doc group: :Substitution
  @doc """
  Creates a new substitution
  """
  @spec mk_substitution(free_var_decl(), hol_term()) :: substitution()
  def mk_substitution(fvar, term), do: substitution(fvar: fvar, term: term)

  @doc group: :Substitution
  @doc """
  Accessor function for the free variable of the substitution
  """
  @spec get_fvar(substitution()) :: free_var_decl()
  def get_fvar(substitution(fvar: fvar)), do: fvar

  @doc group: :Substitution
  @doc """
  Accessor function for the term of the substitution
  """
  @spec get_term(substitution()) :: hol_term()
  def get_term(substitution(term: term)), do: term
end
