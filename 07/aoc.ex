defmodule Aoc do
# c(["d.ex","f.ex","aoc.ex"]); Aoc.tst
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
    |> add_commands(d) #|> IO.inspect(label: "state")
    |> execute_commands()
    |> visit()
    |> update_root_size()
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
    state = (
      state.commands
      |> Enum.reduce(state, fn x, state -> execute_one_command(state, x) end)
    )
    Enum.reduce_while(1..1000, state, fn _x, state_acc ->
      if state_acc.current_directory == ["/"],
        do: {:halt, state_acc},
        else: {:cont, execute_one_command(state_acc, ["$", "cd", ".."])}
      end
    )
  end

  def execute_one_command(%Aoc{} = state, ["$", "cd", "/"] = _cmd), do: state

  def execute_one_command(%Aoc{} = state, ["$", "cd", ".."] = _cmd) do
    this_directory_size = get_directory_size(state)
    new_current_directory = Enum.slice(state.current_directory, 0, length(state.current_directory)-1)
    #|> IO.inspect(label: "new directory A")
    the_directory = Map.get(state.directories, new_current_directory)
    new_directory_size = this_directory_size + the_directory.size
    the_new_directory = %{the_directory | size: new_directory_size}
    new_directories = Map.put(state.directories, new_current_directory, the_new_directory)
    %{state | current_directory: new_current_directory, directories: new_directories}
    #|> IO.inspect(label: "state after cd '..'")
  end

  def execute_one_command(%Aoc{} = state, ["$", "cd", dirname] = _cmd) do
    new_current_directory = state.current_directory ++ [dirname]
    directory = %D{name: new_current_directory}
    if Map.get(state.directories, new_current_directory) do
      IO.inspect({state.directories, new_current_directory}, label: "multiple CDs")
      [1] = [2,3] # generate an error!
    end
    new_directories = Map.put_new(state.directories, new_current_directory, directory)
    %{state | current_directory: new_current_directory,
              directories: new_directories}
  end

  def execute_one_command(%Aoc{} = state, ["$", "ls"] = _cmd), do: state

  def execute_one_command(%Aoc{} = state, ["dir", dir_name] = _cmd) do
    IO.inspect({dir_name, state}, label: "before processing dir output")
    current_directory = state.current_directory
    this_directory = Map.get(state.directories, state.current_directory, [])
    new_children = [dir_name | this_directory.children]
    new_directory = %{this_directory | children: new_children}
    new_directories = Map.put(state.directories, current_directory, new_directory)
    %{state | directories: new_directories}
    |> IO.inspect(label: "after processing dir output")
  end


  def execute_one_command(%Aoc{} = state, [text_size, name] = _cmd) do
    size = String.to_integer(text_size)
    #IO.inspect({state.current_directory, name, size}, label: "file")
    file = %F{name: name, size: size}
    directory = Map.get(state.directories, state.current_directory, [])
    new_file_list = [file | directory.files]
    new_directory_size = directory.size + size
    new_directory = %{directory | size: new_directory_size,
                                  files: new_file_list}
    new_directories = Map.put(state.directories, state.current_directory, new_directory)
    %{state | directories: new_directories}
  end

  def update_root_size(%Aoc{} = state) do
    root_name = ["/"]
    root_size = (
      %{state | current_directory: root_name}
      |> get_directory_size()
    )
    root_directory = Map.get(state.directories, root_name, [])
    new_root_directory = %{root_directory | size: root_size}
    new_directories = Map.put(state.directories, root_name, new_root_directory)
    %{state | directories: new_directories}
  end

  def get_directory_size(%Aoc{} = state) do
    directory_path = state.current_directory
    directory = Map.get(state.directories, directory_path, [])
    size_of_files = Enum.reduce(
        directory.files, 0, fn elt, acc -> elt.size + acc end
    )
    size_of_directories = Enum.reduce(
        directory.children, 0, fn elt, acc -> get_directory_size(state, elt) + acc end
    )
    IO.inspect({directory_path, size_of_files + size_of_directories}, label: "directory size")
    size_of_files + size_of_directories
  end

  def get_directory_size(%Aoc{} = state, directory_name) do
    IO.inspect(state, label: "get_directory_size")
    fully_qualified_path = state.current_directory ++ [directory_name]
    directory = Map.get(state.directories, fully_qualified_path, [])
    directory.size
  end

  def visit(%Aoc{} = state) do
    state
  end

  def get_matching_directories(%Aoc{directories: dirs} = state) do
    dir_paths = Map.keys(dirs)
    matching_dirs = (
      Enum.filter(dir_paths, fn path -> (Map.get(dirs, path) |> Map.get(:size)) <= 100_000 end)
      |> IO.inspect(label: "matching directories")
    )
    {state, matching_dirs}
  end

  def print_answer({%Aoc{directories: dirs} = state, dir_paths}) do
    Enum.reduce(dir_paths, 0, fn path, acc -> acc + (Map.get(dirs, path) |> Map.get(:size)) end)
    |> IO.inspect(label: "the answer:")
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
