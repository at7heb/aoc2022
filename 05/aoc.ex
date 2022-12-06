defmodule Aoc do
  defstruct pile_count: 0, piles: {}, moves: [], data: ""
  def run do
    read_data()
    |> process_and_print
  end

  def tst do
"""
    [D]
[N] [C]
[Z] [M] [P]
 1   2   3

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2
"""
    |> process_and_print
  end

  def process_and_print(d) do
    %Aoc{}
    |> add_puzzle_data(d)
    |> IO.inspect(label: "initial")
    |> get_number_of_piles()
    |> IO.inspect(label: "number")
    |> get_piles()
    |> IO.inspect(label: "piles")
    |> get_moves()
    |> IO.inspect(label: "moves")
    |> apply_moves()
    |> IO.inspect(label: "final")
    |> print_answer

    # d1
    # |> process_data
    # |> print_answer_2
  end

  def add_puzzle_data(%Aoc{} = s, d) do
    %{s | data: d}
  end

  def get_number_of_piles(%Aoc{data: d} = s) do
    pile_count = (~r/\n[ 0-9]+\n/
    |> Regex.scan(d)
    |> Enum.at(0)
    |> Enum.at(0)
    |> String.split([" ", "\n"], trim: true)
    |> Enum.reverse()
    |> Enum.at(0)
    |> String.to_integer())
    %{s | pile_count: pile_count}
  end

  def get_piles(%Aoc{pile_count: count, data: d} = s) do
    # pile_data_pattern = ~r/]/
    pile_data = String.split(d, "\n")
    |> Enum.filter(fn a -> Regex.match?(~r/]/, a) end)
    |> Enum.reverse()         # will push items on a pile in reverse order.
    |> Enum.reduce(s, fn a, s -> handle_one_pile_level(a, s) end)
    piles = {pile_data}
    %{s | piles: piles}
  end

  def get_moves(%Aoc{} = s) do
    s
  end

  def apply_moves(%Aoc{} = s) do
    s
  end

  def read_data do
    File.read!("data.txt")
    |> String.trim()
  end

  def process_data(d) do
    d
    |> Enum.map(fn a -> String.split(a, ["-", ","])
            |> (Enum.map(fn a -> String.to_integer(a) end)) end)
  end

  def print_answer_2(d) do
    d
    |> Enum.map(fn [a, b, c, d] -> score_2(a, b, c, d) end)
    |> Enum.sum()
    |> IO.inspect(label: "answer 2")
  end

  def print_answer(d) do
    d
    # |> Enum.take(6)
    # |> IO.inspect(label: "in answer")
    |> score()
    |> IO.inspect(label: "the answer")
  end

  def score(d) do
    d
    |> Enum.map(fn [a, b, c, d] -> score(a, b, c, d) end)
    |> Enum.sum()
  end

  def score(a, b, c, d) when a == c do
    1
    end

  def score(a, b, c, d) when a <= b and a <= c and c <= d do
    rv =
    cond do
      b >= d -> 1
      true -> 0
    end
    if rv == 0 do
      IO.inspect({rv, "for", a, b, c, d}, label: "score")
    end
    rv
  end

  def score(a, b, c, d) when a <= b and a > c and c <= d do
    # score(c, d, a, b)
    rv =
    cond do
      d >= b -> 1
      true -> 0
    end
    if rv == 0 do
      IO.inspect({rv, "for", a, b, c, d}, label: "score")
    end
    rv
  end

  def score_2(a, b, c, d) when a <= b and c <= d do
    rv =
    cond do
      b < c -> 0    # no overlap
      d < a -> 0    # no overlap
      true -> 1
    end
    # IO.inspect({rv, "for", a, b, c, d}, label: "score_2")
    rv
   end
end
