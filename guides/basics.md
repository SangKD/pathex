# Basics

This guide will show the basics of `Pathex`.

## Create paths

Path-closure should be created with `Pathex.path/2` or `Pathex.sigil_P/2`

For example:

```elixir
iex> p = path :x / 0
```

And the same path, but using the sigil

```elixir
iex> p = ~P":x/0"naive
```

Paths created with `Pathex.path/2` can have atoms, strings, integers, variables
and anything else what can be used in **pattern-matching**. This means that passing
function calls straight into `Pathex.path/2` is not allowed and will result in a
compilation error

> Note:
> You **don't** have to capture used variables
>
> ```elixir
> iex> x = 1
> iex> path :some_atom / x  # Right
> iex> path :some_atom / ^x # Wrong
> ```

* Strings, tuples, maps, functions, lists are treated only as `Map` keys.
* Atoms are treated as `Map` or `Keyword` keys.
* Positive integers are treated as `Map` keys or `List` and `Tuple` indexes
* Negative integers are treated as `Map` keys or first element in `List`'s view or
  prepending element in `List`'s `update` or `force_set` operations
* Variables are treated as other types. For example, variables containing negative
  integers are treated as negative integer values

## Use paths

```elixir
iex> p = path :indexes / 0
iex> Pathex.view %{indexes: [1, 2, 3]}, p
1
```

There are plently ways to use created paths. Every macro with human-readable name
(except `path` and `sigil_P`) is a macro for using pathex. In all such macros
first argument is an input structure and the second argument is a path-closure itself

> Note:
> Path-closure which are created inside path-using macro are optimised to have
> only one operation generated (instead of default three).
> You can read more about path-closures and operations [here](path.md)

As usual

* Macro without `!` always return `{:ok, result}` or `:error`
* Macro with `!` return `result` or raise `Pathex.Error`

### Common data access functions

| Map             | Pathex                |
|:----------------|----------------------:|
| `Map.fetch`     | `Pathex.view`         |
| `Map.get`       | `Pathex.get`          |
| `Map.update!/3` | `Pathex.over`         |
| `Map.update/4`  | `Pathex.force_update` |
| `Map.put`       | `Pathex.force_set`    |

## Compose paths

Path-closures can be composed together to create new path-closure,
every path comosition macro is a binary operator. Some compositions
are optimized to have generate one closure even if multiple closures
are used.

You can concat paths with `Pathex.~>/2` composition macro

```elixir
iex> p1 = path :x
iex> p2 = path :y
iex> composed_path = p1 ~> p2
iex> 1 = Pathex.view(%{x: [y: 1]}, composed_path)
```

> Think about paths composition just like paths concatenation in shell  
> For example  
>
> ```elixir
> iex> first_user = path :users / 0          # users/0
> iex> name = path :name                     # name
> iex> first_user_name = first_user ~> name  # users/0/name
> ```

## Prebuilt paths

`Pathex` provides some prebuilt path-closure to solve exotic problems. You
can find them in `Pathex.Lenses` module. You can read more about them in
[lenses guide](lenses.md)
