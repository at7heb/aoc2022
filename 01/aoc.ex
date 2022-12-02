defmodule Aoc do
  def run do
    read_data()
    |> process_data
    |> print_answer
  end

  def read_data do
    File.read!("data.txt")
   end

  def process_data(d) do
    d
    |> String.split("\n\n")
    |> Enum.map(fn a -> String.split(a) |> Enum.map(fn s -> String.to_integer(s) end) end)
 end

  def print_answer(d) do
    d
    # |> Enum.take(5)
    |> Enum.map(fn a -> Enum.sum(a) end)
    # |> IO.inspect(label: "first 5")
    |> Enum.max() |> IO.inspect(label: "part 1 answer")

    d
    |> Enum.map(fn a -> Enum.sum(a) end)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> IO.inspect(label: "part 2 components")
    |> Enum.sum()
    |> IO.inspect(label: "part 2 answer")
    []
  end
end
