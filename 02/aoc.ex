defmodule Aoc do
  def run do
    read_data()
    |> process_and_print
  end

  def tst do
    a =  """
      A Y
      B X
      C Z
"""
    String.trim(a)
    |> process_and_print
  end

  def process_and_print(d) do
    d
    |> process_data
    |> print_answer
    d |> process_data_2 |> print_answer
  end

  def read_data do
    File.read!("data.txt")
  end

  def process_data(d) do
    d
    |> String.split("\n")
    |> Enum.map(fn a -> String.split(a) end)
  end

 def process_data_2(d) do
    process_data(d)
    # |> Enum.take(5) |> IO.inspect(label: "process_data_2 A")
    |> Enum.map(fn [e, r] -> [e, shape_for(e,r)] end)
    # |> IO.inspect(label: "process_data_2 B")
  end

  def print_answer(d) do
    d
    # |> Enum.take(5)
    # |> IO.inspect(label: "first 5 in answer")
    |> score()
    |> IO.inspect(label: "the answer")
    []
  end

  def score(d) do
    Enum.reduce(d, 0, fn [a, b], acc -> acc + score(a,b) end)
  end

  def score(e, m) do
    # A, B, C = ROCK, PAPER, SCISSORS
    # X, Y,  Z = ROCK, PAPER, SCISSORS
    # ROCK: 1, PAPER: 2, SCISSORS: 3
    # LOSE: 0, DRAW: 3, WIN: 6
    rv = case {e,m} do
      {"A", "X"} -> 1 + 3
      {"A", "Y"} -> 2 + 6
      {"A", "Z"} -> 3 + 0
      {"B", "X"} -> 1 + 0
      {"B", "Y"} -> 2 + 3
      {"B", "Z"} -> 3 + 6
      {"C", "X"} -> 1 + 6
      {"C", "Y"} -> 2 + 0
      {"C", "Z"} -> 3 + 3
    end

    # IO.inspect({e, m, rv}, label: "a Score")
    rv
  end

  def shape_for(e,r) do
    # A, B, C = ROCK, PAPER, SCISSORS
    # Incoming: X, Y,  Z = LOSE, DRAW, WIN
    # result: X, Y,  Z = ROCK, PAPER, SCISSORS
    # ROCK: 1, PAPER: 2, SCISSORS: 3
    # LOSE: 0, DRAW: 3, WIN: 6
    case {e, r} do
      {"A", "X"} -> "Z"
      {"A", "Y"} -> "X"
      {"A", "Z"} -> "Y"
      {"B", "X"} -> "X"
      {"B", "Y"} -> "Y"
      {"B", "Z"} -> "Z"
      {"C", "X"} -> "Y"
      {"C", "Y"} -> "Z"
      {"C", "Z"} -> "X"
    end
  end
end
