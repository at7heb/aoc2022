defmodule Aoc do
  def run do
    data = read_data()
    data |> process_and_print
    # data |> process_and_print_2
  end

  def tst do
    d = """
$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k
    """
    d |> process_and_print
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
