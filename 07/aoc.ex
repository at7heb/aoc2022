defmodule Aoc do
  # alias Enumerable.Date
  defstruct current_directory: [], commands: [], directories: %{}

  import D
  import F

  def run do
    data = read_data()
    data |> process_and_print
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
    %Aoc{}
    |> add_root_directory
    |> add_commands(d) |> IO.inspect(label: "state")
    |> execute_commands()
    |> visit()
    |> get_matching_directories()
    |> print_answer()
  end

  def add_commands(%Aoc{} = state, text) do
    command_list = (
      String.split(text, "\n", trim: true)
      |> Enum.map(fn x -> String.split(x, " ", trim: true) end)
    )
    %{state | commands: command_list}
  end

  def execute_commands(%Aoc{} = state) do
    state.commands
    |> Enum.reduce(state, fn x, state -> execute_one_command(state, x) end)
  end

  def execute_one_command(%Aoc{} = state, ["$", "cd", "/"] = _cmd), do: state

  def execute_one_command(%Aoc{} = state, ["$", "cd", dirname] = _cmd) do
    state
  end

  def execute_one_command(%Aoc{} = state, ["$", "ls"] = _cmd), do: state

  def execute_one_command(%Aoc{} = state, ["dir", dir_name] = _cmd) do
    state
  end


  def execute_one_command(%Aoc{} = state, [size, name] = _cmd) do
    state
  end
  # def execute_one_command(%Aoc{} = state, [] = _cmd) do
  #   state
  # end

  # def execute_one_command(%Aoc{} = state, [] = _cmd) do

  # end

  def visit(%Aoc{} = state) do
    state
  end

  def get_matching_directories(%Aoc{} = state) do
    state.directories
  end

  def print_answer(dirs) when is_list(dirs) do
    IO.puts(42)
  end

  def add_root_directory(%Aoc{} = state) do
    slash = %D{}
    #   defstruct name: "", size: 0, files: [], directories: []

    slash = %{slash | name: ["/"]}
    %{state | current_directory: slash.name, directories: %{["/"] => slash} }
  end

  def read_data do
    File.read!("data.txt")
    |> String.trim()
  end
end
