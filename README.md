# Pathex

Speed or composability? Chose both!

### What is Pathex?

Pathex is a library for performing fast actions with nested data structures in Elixir.
With pathex you can trivially set, get and update values in structures in a functional manner.
It provides all necessary logic to manipulate data structures in different ways using flexible __functional lens__ pattern.

### Why another library?

Existing methods of accesssing data in nested structures are either slow (like `Focus`) or do not provide enough functionality (like `Access`). For example setting the value in structure with Pathex is `70-160x` faster than `Focus` or `2-3x` faster than `put_in` and `get_in`

> You can checkout benchmarks at https://github.com/hissssst/pathex_bench

## Usage

Pathex is really simple and straightforward to use (almost like `Enum`). You don't need to learn any specific language, just create paths with `path` and use verbs with them.

### Add it to your module

```elixir
# This will import path macro and operators and require Pathex
use Pathex
```

Or you can just `import` what's necessary!

```elixir
require Pathex
import Pathex, only: [path: 2, path: 1]
```

You can call it module-wise, or just import this in function

### Create path

```elixir
path_to_strees = path :user / :private / :addresses / 0 / :street
path_in_json = path "users" / 1 / "street", :json
```

This creates closure which can get, set, update and delete values in this path

### Use the path!

```elixir
{:ok, "6th avenue" = street} =
    %{
      user: %{
        id: 1,
        name: "hissssst",
        private: %{
          phone: "123-456-789",
          addresses: [
             [city: "City", street: "6th avenue", mail_index: 123456]
          ]
        }
      }
    }
    |> Pathex.view(path_to_streets)
%{
  "users" => %{
    1 => %{"street" => "6th avenue"}
  }
} = Pathex.force_set!(%{}, path_in_json, street)
```

## Features

Pathex has a lot of different features and can even compete with code written by hand in efficency.
It significantly reduces the time to write a code which manipulates nested structure, while
providing efficency and composability. No more functions like `get_users`, `set_users`, `update_users`! No more XPaths, JSONPaths, CSS Selectors!

### Easy to use

It's not harder to use than `Map` or `Enum`! Check out the [cheatsheet](https://hexdocs.pm/pathex/cheatsheet.html) for common tasks.

Pathex is very descriptive about anything you write

```elixir
iex(1)> Pathex.view! %{}, path(:users) ~> all() ~> path(:personal / :email)
** (Pathex.Error)
  Couldn't find element

    Path:      path(:users) ~> all() ~> path(:personal / :email)

    Structure: %{}
```

### Fast

Paths are really a set of pattern-matching cases.
This is done to extract maximum efficency from BEAM's pattern-matching compiler. Pathex is proven to be the fastest solution to access data in Elixir, you can check out the benchmarks here: https://github.com/hissssst/pathex_bench

```elixir
# Code for viewing variables for path
path(1 / "y", :map)

# Almost equals to
case input do
  %{1 => %{"y" => res}} ->
    {:ok, res}

  _ ->
    :error
end
```

### Reusable

Paths can be created and used or composed later with rich set of composition functions.  
And one path can be used to update, get, set, delete a value in the structure!

```elixir
# User structure
user = %User{
  personal: %{fname: "Kabs", sname: "Rocks"},
  phone: "123-456-789"
}

# Path to username in user structure
username = path(:personal / :fname)

# Get a username
{:ok, "Kabs"} = Pathex.view(user, username)

# Set a username
another_user =
  %User{
    personal: %{fname: "Blabs", sname: "Rocks"},
    phone: "123-456-789"
  } = Pathex.set!(user, username, "Blabs")

# Get all usernames!
import Pathex.Lenses
["Kabs", "Blabs"] =
  [
    user,
    another_user
  ]
  |> Pathex.view!(all() ~> username)
```

And many more other examples. `Pathex` can be used to manipulate different nested data structure. From `GenServer` state to HTML or Elixir's AST!

### Extensible

Pathex is built around simple primitive called `path-closure`, which a simple closure with clearly defined specification.  Anything complying with `Pathex.t()` spec can be used within `Pathex`.


## Installation

```elixir
def deps do
  [
    {:pathex, "~> 2.0"}
  ]
end
```
## Contributions

Welcome! If you want to get your hands dirty, you can check existing `TODO`'s.

> **By the way**
>
> If you have any suggestions or want to change something in this library don't hesitate to open an issue. If you have any whitepapers about functional lenses, you can add them in a PR to the bottom of this readme
