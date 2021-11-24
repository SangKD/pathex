defmodule Pathex.Parser do
  @moduledoc """
  Module for parsing path created with sigils
  """

  # TODO proper naive parsing
  @spec parse(binary(), Pathex.mod()) :: Pathex.Combination.t()
  def parse(string, :naive) do
    string
    |> String.split("/")
    |> Enum.map(&detect_naive(String.trim(&1)))
  end

  def parse(string, :json) do
    string
    |> String.split("/")
    |> Enum.map(&detect_json(String.trim(&1)))
  end

  def parse(string, :map) do
    string
    |> String.split("/")
    |> Enum.map(&detect_map(String.trim(&1)))
  end

  defp detect_map(str) do
    astr = String.to_atom(str)

    case Integer.parse(str) do
      {istr, ""} ->
        [map: str, map: istr, map: astr]

      _ ->
        [map: astr, map: str]
    end
  end

  defp detect_json(str) do
    case Integer.parse(str) do
      {istr, ""} ->
        [map: str, list: istr]

      _ ->
        [map: str]
    end
  end

  defp detect_naive("\"" <> str) do
    case String.trim_trailing(str, "\"") do
      ^str ->
        raise "Bad string in naive mod: #{str}"

      other ->
        [map: other]
    end
  end

  defp detect_naive(":" <> str) do
    astr = String.to_atom(str)
    [map: astr, keyword: astr]
  end

  defp detect_naive(str) do
    case Integer.parse(str) do
      {istr, ""} ->
        [list: istr, map: istr, tuple: istr]

      _ ->
        raise "Bad string in naive mod: #{str}"
    end
  end
end
