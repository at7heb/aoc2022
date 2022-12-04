defmodule Aoc do
  def run do
    read_data()
    |> process_and_print
  end

  def tst do
    a =  """
    vJrwpWtwJgWrhcsFMMfFFhFp
    jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
    PmmdzqPrVvPwwTWBwg
    wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
    ttgJtRGJQctTZtZT
    CrZsJsPPZsGzwwsLwLmpwMDw
    """
    a
    |> process_and_print
  end

  def process_and_print(d) do
    d
    |> String.trim()
    |> String.split("\n")
    |> process_data
    |> print_answer

    d
    |> String.trim()
    |> String.split("\n")
    |> process_data_2
    |> print_answer
  end

  def read_data do
    File.read!("data.txt")
  end

  def process_data(d) do
    d
    |> Enum.map(fn a -> make_2_parts(a) end)
    |> Enum.map(fn {p1, p2} -> MapSet.intersection(p1, p2) end)
    |> Enum.map(fn a -> MapSet.to_list(a) end)
    |> Enum.map(fn a -> Enum.at(a,0) end)
    # |> IO.inspect(label: "intersections")
  end

 def process_data_2(d) do
    d
    |> Enum.map(fn a -> String.split(a, "", trim: true) |> MapSet.new() end)
    |> Enum.chunk_every(3)
    |> IO.inspect(label: "chunked")
    |> Enum.map(fn [a1, a2, a3] -> MapSet.intersection(a1, MapSet.intersection(a2, a3)) end)
    |> Enum.map(fn a -> MapSet.to_list(a) |> Enum.at(0) end)
    |> IO.inspect(label: "process data 2 result")
  end

  def print_answer(d) do
    d
    # |> Enum.take(6)
    |> IO.inspect(label: "in answer")
    |> score()
    |> IO.inspect(label: "the answer")
    []
  end

  def score(d) do
    reference_string = String.split(" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", "", trim: true)
    _s1 = Enum.map(d, fn a -> Enum.find_index(reference_string, fn b -> a==b end) end)
    # |> IO.inspect(label: "individual priorities")
    |> Enum.sum()
    |> IO.inspect(label: "summed priorities")
  end

  def make_2_parts(s) do
    l = String.length(s)
    l2 = div(l,2)
    part1 = String.slice(s, 0, l2)
    part2 = String.slice(s, l2, l2)
    {MapSet.new(String.split(part1, "", trim: true)), MapSet.new(String.split(part2,  "", trim: true))}
  end
end
