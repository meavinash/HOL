# HOL

This elixir package gives an implementation of higher order logic via the [simply typed lambda calculus](https://en.wikipedia.org/wiki/Simply_typed_lambda_calculus) and higher order pre-[unification](https://en.wikipedia.org/wiki/Unification_%28computer_science%29#Higher-order_unification). All lambda terms are always automatically beta-reduced and eta-expanded. Bound Variables are automatically named via [de bruijn indices](https://en.wikipedia.org/wiki/De_Bruijn_index).

This package was developed at [University of Bamberg](https://www.uni-bamberg.de/en/) with the [AISE Chair](https://www.uni-bamberg.de/en/aise/).

## Installation

This package can be installed by adding `hol` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hol, "1.0.1"}
  ]
end
```

## Documentation

Documentation is available on [hexdocs](readme.html)

## Most important functions

- `HOL.Data.mk_type/2`: To create a type for the simply typed lambda calculus
- `HOL.Data.mk_free_var/2`: To create a free variable
- `HOL.Data.mk_const/2`: To create a constant
- `HOL.Terms.mk_term/1`: To create a term from a variable or constant
- `HOL.Terms.mk_appl_term/2`: To apply to terms to each other
- `HOL.Terms.mk_abstr_term/2`: To create a lambda abstraction
- `HOL.Data.mk_substitution/2`: To create a substitution
- `HOL.Substitution.subst/2`: To apply a list of substitutions to a term
- `HOL.Unification.unify/3`: To find substitutions to unify two terms
- Use the functions in the `PrettyPrint` Module to show data in a humanly readable format

```elixir
type_i = mk_type(:i)
type_ii = mk_type(type_i, [type_i])
type_ii_ii = mk_type(type_ii, [type_ii])
type_iii = mk_type(type_i, [type_i, type_i])
```

## Unification Examples

The following and more examples can be found interactively in the [livebook](unification_examples.livemd).

### Example: x \* 10 = 1000

```elixir
t_x = mk_free_var_term("x", type_ii_ii)

x_times_10 = mult_term() |> mk_appl_term(t_x) |> mk_appl_term(mk_num(10))

input = [
  {x_times_10, mk_num(1000)}
]

result = unify(input, true, 1000)
pp_res(result, true)
```

This finds one substitution that replaces `x` with the church numeral `100`

x = 100: `x <- (2 1. 2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 (2 1) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) )`

### Example: xaa = faa

```elixir
t_x = mk_free_var_term("x", type_iii)
t_a = mk_const_term("a", type_i)
t_f = mk_const_term("f", type_iii)

xaa = mk_appl_term(mk_appl_term(t_x, t_a), t_a)
faa = mk_appl_term(mk_appl_term(t_f, t_a), t_a)

input = {xaa, faa}

result = unify(input)
pp_res(result)
```

Finds nine possible substitutions for unification:

`x <- λ 2 1. f 1 1`

`x <- λ 2 1. f 1 2`

`x <- λ 2 1. f 1 a`

`x <- λ 2 1. f 2 1`

`x <- λ 2 1. f 2 2`

`x <- λ 2 1. f 2 a`

`x <- λ 2 1. f a 1`

`x <- λ 2 1. f a 2`

`x <- λ 2 1. f a a`

### Example: x(fa) = f(xa)

```elixir
t_x = mk_free_var_term("x", type_ii)
t_f = mk_const_term("f", type_ii)
t_a = mk_const_term("a", type_i)

xfa = mk_appl_term(t_x, mk_appl_term(t_f, t_a))
fxa = mk_appl_term(t_f, mk_appl_term(t_x, t_a))

depth = 5
input = {xfa, fxa}

result = unify(input, true, depth)
pp_res(result)
```

This finds four solutions:

`x <- λ 1. 1 `

`x <- λ 1. f 1`

`x <- λ 1. f (f 1)`

`x <- λ 1. f (f (f 1))`

However the maximum search depth was also reached twice. This means that it might not have found all solutions. Try changing the `depth` value and see what other solutions can be found!

### Example: Multiple Equations

- xy+z=21
- x+y+z=10
- xz+y=9

```elixir
t_x = mk_free_var_term("x", type_ii_ii)
t_y = mk_free_var_term("y", type_ii_ii)
t_z = mk_free_var_term("z", type_ii_ii)

input = [
  {plus(mult(t_x, t_y), t_z), mk_num(21)},
  {plus(plus(t_x, t_y), t_z), mk_num(10)},
  {plus(mult(t_x, t_z), t_y), mk_num(9)}
]

depth = 50
result = unify(input, true, depth)
pp_res(result, true)
```

Two Solutions are found here:

z = 1, y = 4, x = 5: `z <- λ 2 1. 2 1` | `y <- λ 2 1. 2 (2 (2 (2 1)))` | `x <- λ 2 1. 2 (2 (2 (2 (2 1))))`

z = 1, y = 5, x = 4: `z <- λ 2 1. 2 1` | `y <- λ 2 1. 2 (2 (2 (2 (2 1))))` | `x <- λ 2 1. 2 (2 (2 (2 1)))`

Once again the maximum search depth was reached multiple times. However increasing the search depth will not yield more solutions here. Unification doesn't always terminate even when no more solutions can be found!
