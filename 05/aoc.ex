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
    # |> IO.inspect(label: "initial")
    |> get_number_of_piles()
    # |> IO.inspect(label: "number")
    |> get_piles()
    # |> IO.inspect(label: "piles")
    |> get_moves()
    # |> IO.inspect(label: "moves")
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
    piles = Enum.reduce(1..pile_count, {}, fn _a, t -> Tuple.append(t, []) end)
    %{s | pile_count: pile_count, piles: piles}
  end

  def get_piles(%Aoc{data: d} = s) do
    # pile_data_pattern = ~r/]/
    String.split(d, "\n")
    |> Enum.filter(fn a -> Regex.match?(~r/]/, a) end)
    # |> IO.inspect(label: "pile contents")
    |> Enum.reverse()         # will push items on a pile in reverse order.
    |> Enum.reduce(s, fn a, s -> handle_one_pile_level(s, a, 0) end)
  end

  def handle_one_pile_level(%Aoc{piles: piles} = s,
    <<"[", z, "]", " ", rest::binary>>, index) do
    # this case for initial / medial [.] (but not final)
    pile = elem(piles, index)
    pile = [<<z>> | pile]
    piles = put_elem(piles, index, pile)
    handle_one_pile_level(%{s | piles: piles}, rest, index + 1)
  end

  def handle_one_pile_level(%Aoc{} = s,
    <<" ", " ", " ", " ", rest::binary>>, index) do
    # this case for initial / medial blank (but not final)
    handle_one_pile_level(s, rest, index + 1)
  end

  def handle_one_pile_level(%Aoc{piles: piles} = s,
    <<"[", z, "]">>, index) do
    # this case for initial / medial [.] (but not final)
    pile = elem(piles, index)
    pile = [<<z>> | pile]
    piles = put_elem(piles, index, pile)
    %{s | piles: piles}
  end

  def get_moves(%Aoc{data: d} = s) do
    moves = (
      String.split(d, "\n")
      |> Enum.filter(fn a -> Regex.match?(~r/^move /, a) end)
      |> Enum.reverse()   # will put each move on head of move list
      # |> IO.inspect(label: "raw moves reversed")
      |> Enum.reduce([], fn e, a -> parse_and_push_move(e, a) end)
    )
    %{s | moves: moves}
  end

  def parse_and_push_move(move_text, moves) do
    [[count, from, to]] =
      Regex.scan(~r/^move (\d+) from (\d+) to (\d+)$/, move_text,
                  capture: :all_but_first)
    [{String.to_integer(count), String.to_integer(from), String.to_integer(to)} | moves]
  end

  def apply_moves(%Aoc{moves: moves} = s) do
    IO.inspect(s, label: "apply_moves")
    Enum.reduce(moves, s, fn elem, acc -> apply_one_move(acc, elem) end)
  end

  def apply_one_move(%Aoc{piles: piles} = s, {count, from, to} = move) do
    IO.inspect(move, label: "move")
    # from and to are 1-based, so decrement
    [top | rest_of_from] = elem(piles, from-1)
    new_to = [top | elem(piles, to-1)]
    new_piles = put_elem(piles, from-1, rest_of_from) |> put_elem(to-1, new_to)
    new_s = %{s | piles: new_piles}
    IO.inspect({piles, new_piles}, label: "b/a move")
    case count do
      1 -> new_s
      _ -> apply_one_move(new_s, {count-1, from, to})
    end
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

  def print_answer_2(_d) do
    # d
    # |> Enum.map(fn [a, b, c, d] -> score_2(a, b, c, d) end)
    # |> Enum.sum()
    # |> IO.inspect(label: "answer 2")
    []
  end

  def print_answer(%Aoc{} = s) do
    s
    # |> Enum.take(6)
    # |> IO.inspect(label: "in answer")
    |> score()
    |> IO.inspect(label: "the answer")
  end

  def score(%Aoc{} = _s) do
    42
  end
end
