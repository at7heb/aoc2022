defmodule Aoc do
  def run do
    read_data()
    |> process_and_print
  end

  def tst do
    """
    2-4,6-8
    2-3,4-5
    5-7,7-9
    2-8,3-7
    6-6,4-6
    2-6,4-8
    3-7,2-8
    3-7,3-7
    """
    |> process_and_print
  end

  def process_and_print(d) do
    d1 = d |> String.trim() |> String.split("\n")
    IO.inspect(Enum.count(d1), label: "length of d1")

    d1
    |> process_data
    |> print_answer

    d1
    |> process_data
    |> print_answer_2
  end

  def read_data do
    File.read!("data.txt")
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
