defmodule Pathex.LensesTest do
  use ExUnit.Case

  alias Pathex.Lenses
  require Lenses
  doctest Lenses

  require Pathex
  import Pathex

  test "Tricky alls" do
    px = path(:x)
    all = Lenses.all()

    inc = fn x -> x + 1 end

    # View
    assert {:ok, [1, 2]} = view(%{x: [1, 2]}, px ~> all)
    assert {:ok, [1, 2]} = at(%{x: [[x: 0], %{x: 1}]}, px ~> all ~> px, inc)

    assert :error = view(%{x: [%{x: 1}, %{y: 2}]}, px ~> all ~> px)

    # Update
    assert {:ok, [[x: 2], [x: 3]]} = over([[x: 1], [x: 2]], all ~> px, inc)
    assert {:ok, [[x: 2], %{x: 2}]} = set([[x: 1], %{x: 1}], all ~> px, 2)

    assert :error = set(%{x: [[x: 1], [y: 1]]}, px ~> all ~> px, 1)

    # Force
    assert {:ok, [x: 2, y: 2]} = force_set([x: 1, y: 1], all, 2)
    assert {:ok, [x: %{x: 2}, y: %{x: 2}]} = force_set([x: %{x: 1}, y: 1], all ~> px, 2)
  end

  describe "Catching" do
    test "in any" do
      px = path(:x)
      any = Lenses.any()

      assert :error = force_set(%{}, any ~> px, 1)
      assert :error = force_set(%{k: {}}, any ~> px, 1)

      assert :error = force_set({{}}, any ~> px, 1)
      assert {:ok, {%{x: 1}}} = force_set({%{}}, any ~> px, 1)

      assert :error = force_set([x: {}], any ~> px, 1)
      assert :error = force_set([{}], any ~> px, 1)

      assert :error = set(%{}, any ~> px, 1)
      assert :error = set(%{k: {}}, any ~> px, 1)

      assert :error = set({{}}, any ~> px, 1)

      assert :error = set([x: {}], any ~> px, 1)
      assert :error = set([{}], any ~> px, 1)
    end

    test "in all" do
      px = path(:x)
      all = Lenses.all()

      assert {:ok, [%{x: 1}]} = force_set([{}], all ~> px, 1)
      assert {:ok, %{x: %{x: 1}}} = force_set(%{x: {}}, all ~> px, 1)
      assert {:ok, [x: %{x: 1}]} = force_set([x: {}], all ~> px, 1)
      assert {:ok, {%{x: 1}}} = force_set({{}}, all ~> px, 1)

      assert :error = set([{}], all ~> px, 1)
      assert :error = set(%{x: {}}, all ~> px, 1)
      assert :error = set([x: {}], all ~> px, 1)
      assert :error = set({{}}, all ~> px, 1)
    end
  end

  describe "some" do
    test "concatenated" do
      px = path(:x)
      pb = path(:b)
      some = Lenses.some()

      # View
      assert {:ok, 2} = view([%{y: 1}, %{x: 2}], some ~> px)
      assert {:ok, 1} = view([%{x: 1}, %{x: 2}], some ~> px)
      assert :error = view([%{z: :z}, %{y: :y}], some ~> px)
      assert :error = view([%{z: :z}, %{y: :y}], px ~> some ~> px)
      assert :error = view(%{x: [%{z: :z}, %{y: :y}]}, px ~> some ~> px)
      assert {:ok, :x} = view(%{x: [%{z: :z}, %{x: :x}]}, px ~> some ~> px)

      # Update
      assert {:ok, [%{a: 1}, %{b: 2}, %{c: 3}]} = set([%{a: 1}, %{b: 0}, %{c: 3}], some ~> pb, 2)
      assert {:ok, {%{a: 1}, %{b: 2}, %{c: 3}}} = set({%{a: 1}, %{b: 0}, %{c: 3}}, some ~> pb, 2)
      assert {:ok, %{x: %{a: 1}, y: %{b: 2}}} = set(%{x: %{a: 1}, y: %{b: 0}}, some ~> pb, 2)
      assert [x: [a: 1], y: %{b: 2}] = set!([x: [a: 1], y: %{b: 0}], some ~> pb, 2) |> Enum.sort()

      # Force update
      assert {:ok, [%{a: 1, b: 2}, %{b: 0}, %{c: 3}]} =
               force_set([%{a: 1}, %{b: 0}, %{c: 3}], some ~> pb, 2)

      assert {:ok, {%{a: 1, b: 2}, %{b: 0}, %{c: 3}}} =
               force_set({%{a: 1}, %{b: 0}, %{c: 3}}, some ~> pb, 2)

      assert {:ok, %{x: %{a: 1, b: 2}, y: %{b: 0}}} =
               force_set(%{x: %{a: 1}, y: %{b: 0}}, some ~> pb, 2)

      assert {:ok, [x: [a: 1, b: 2], y: %{b: 0}]} =
               force_set([x: [a: 1], y: %{b: 0}], some ~> pb, 2)

      assert {:ok, [%{a: 1, b: 2}]} = force_set([%{a: 1}], some ~> pb, 2)
      assert {:ok, {%{a: 1, b: 2}}} = force_set({%{a: 1}}, some ~> pb, 2)

      assert {:ok, [x: %{a: 1, b: 2}, y: %{c: 3}]} =
               force_set([x: %{a: 1}, y: %{c: 3}], some ~> pb, 2)

      assert {:ok, %{x: [a: 1, b: 2], y: %{c: 3}}} =
               force_set(%{x: [a: 1], y: %{c: 3}}, some ~> pb, 2)
    end

    test "just" do
      some = Lenses.some()
      inc = fn x -> x + 1 end

      # View
      assert {:ok, 1} = view([1, 2], some)
      assert {:ok, 2} = view(%{x: 2, y: -2}, some)
      assert {:ok, 3} = view([y: 3, z: 123], some)
      assert {:ok, 4} = view({4, 5}, some)

      # Update
      assert {:ok, [1, 123]} = over([0, 123], some, inc)
      assert {:ok, %{x: 124, y: -1}} = over(%{x: 123, y: -1}, some, inc)
    end
  end

  describe "recur" do
    test "with some" do
      px = path(:x)
      some = Lenses.some()

      sx = some ~> px

      xl1 = px ||| some ~> px
      xl2 = px ||| sx

      s = %{a: 1, y: %{x: 2, y: 3}}

      assert {:ok, 2} == view(s, xl2)
      assert {:ok, 2} == view(s, xl1)
    end
  end

  describe "conditional lenses" do
    test "matching" do
      ml1 = Lenses.matching({:ok, _})

      assert {:ok, {:ok, 1}} == view({:ok, 1}, ml1)
      assert :error == view({:error, 1}, ml1)

      ml2 = Lenses.matching({:ok, 1})

      assert {:ok, {:ok, 1}} == view({:ok, 1}, ml2)
      assert :error == view({:ok, 2}, ml2)
      assert :error == view({:error, 1}, ml2)

      ml3 = Lenses.matching(_)

      anythings = [
        [],
        %{},
        {},
        1,
        2,
        3,
        :a,
        [x: 1, y: %{x: 2}],
        -1,
        nil,
        %MapSet{},
        true,
        false
      ]

      for anything <- anythings do
        assert {:ok, anything} === view(anything, ml3)
      end
    end

    test "filtering" do
      fl1 = Lenses.filtering(fn %{h: height, w: width} -> height * width < 1000 end)

      assert {:ok, %{h: 10, w: 10}} == view(%{h: 10, w: 10}, fl1)
      assert :error == view(%{h: 10, w: 100}, fl1)

      fl2 = Lenses.filtering(fn _ -> true end)

      anythings = [
        [],
        %{},
        {},
        1,
        2,
        3,
        :a,
        [x: 1, y: %{x: 2}],
        -1,
        nil,
        %MapSet{},
        true,
        false
      ]

      for anything <- anythings do
        assert {:ok, anything} === view(anything, fl2)
      end
    end
  end
end
