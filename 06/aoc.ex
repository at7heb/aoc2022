defmodule Aoc do
  def run do
    data = read_data()
    data |> process_and_print
    # data |> process_and_print_2
  end

  def tst do
    "mjqjpqmgbljsphdztnvjfqwrcgsmlb" |> process_and_print
    "bvwbjplbgvbhsrlpgdmjqwftvncz" |> process_and_print
    "nppdvjthqldpwncqszvftbrmjlhg" |> process_and_print
    "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg" |> process_and_print
    "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw" |> process_and_print
  end

  def process_and_print(d) do
    # <<a, b, c, d, z::binary>> = d
    # process(a, b, c, d, z, 4)
    process(d, 4) |> IO.inspect(label: "ans1")
    process_som(d, 14) |> IO.inspect(label: "ans2")
  end

  def process(d, n) do
    <<a, b, c, d, z::binary>> = d
    uniq_count = length(Enum.uniq([a, b, c, d]))
    cond do
      uniq_count == 4 -> n
      true -> process(<<b, c, d>> <> z, n+1)
    end
  end

  def process_som(d, offset) do
    <<a, b, c, d, e, f, g, h, i, j, k, l, m, n, z::binary>> = d
    uniq_count = length(Enum.uniq([a, b, c, d, e, f, g, h, i, j, k, l, m, n]))
    cond do
      uniq_count == 14 -> offset
      true -> process_som(<<b, c, d, e, f, g, h, i, j, k, l, m, n>> <> z, offset+1)
    end
  end

  def read_data do
    File.read!("data.txt")
    |> String.trim()
  end
end
