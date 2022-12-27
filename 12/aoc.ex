defmodule Aoc do
  defstruct grid: %{}, path: [], paths: []

  import M

  # c(["m.ex", "aoc.ex"]); Aoc.tst

# the grid has {row, col} => elevation
# the path is a list of %M{}s with
# %M{} having %{coordinate: {row, col}, choices: ["^","<","v", ">"] (or subset)}
# path has most recent first; %M{coordinate: {0,0}, _choices} will always be at the end
# paths has a successful path

# the algorithm is to initialize path to [%M{coordinate: {0,0}, choices: ["^","<","v", ">"]}]
# visit the grid point indicated by the head of choices (and remove that choice from the list)
# if the indicated point doesn't exist (Map.fetch/2 returns nil) and another choice is visited.
# the new point is initialized with all choices.any()
#
# then extend_path/1 (argument is %Aoc{} = state) to a choice according to these rules:
# 1. don't go off the grid;
# 2: don't include a choice leading to a visited point
# 3. don't include a choice leading to a lower point
# this returns {:next, new_state}

# if the current point has elevation 99 ("E") the path is complete; add the path to paths
# this returns {:backup, same_state}
# if there are no choices, back up. This too returns {:backup, same_state}
# if there are no choices and the curent point is {0,0} then find the shortest path in paths[]
# this returns {:done, same_state}

  def run do
    data = read_data()
    process_and_print(data)
    []
  end

  def parse_data(data) do
    rows = String.split(data, "\n", trim: true)
    row_count = length(rows)
    Enum.reduce(0..row_count-1, %{}, fn ndx, g -> parse_row(Enum.at(rows, ndx), ndx, g) end)
    # |> IO.inspect(label: "grid")
  end

  def parse_row(row, row_ndx, grid) do
    new_row = String.trim(row)
    Enum.reduce(0..String.length(row)-1,
          grid,
          fn col_ndx, g -> parse_point(new_row, row_ndx, col_ndx, g) end
    )
  end

  def parse_point(row, row_ndx, col_ndx, grid) do
    elevation = (String.at(row, col_ndx) |> calculate_elevation())
    Map.put(grid, {row_ndx, col_ndx}, elevation)
  end

  def calculate_elevation("E"), do: 99
  def calculate_elevation(s), do: (IO.inspect(s, label: "elevation arg"); String.to_integer(s, 36)-9) # 1 --> 26

  def make_state(grid) do
    %Aoc{grid: grid, path: [m_for(0,0)], paths: []}
  end

  def m_for(row, col), do: m_for({row, col})
  def m_for({_r,_c} = coordinates), do %M{coordinates: coordinates, choices: ["^", "<", "v", ">"]}

  def process_and_print(data) do
    parse_data(data)
    |> make_state()
    |> search_for_paths()
    |> IO.inspect(label: "state")
  end

  def search_for_paths(%Aoc{path: path} = state) do
    case advance(state) do
      {:next, new_state} -> search_for_paths(new_state)
      {:backup, same_state} -> nil
      {:done, same_state} -> same_state
    end
  end

  def advance(%Aoc{path: path, grid: grid} = state) do
    [head_of_path | rest_of_path] = path
    cond do
      can_do_first_try(state) -> move_to_first_try(state)
      have_second_try(head_of_path) -> remove_first_try(state)
      true -> {:backup, state}
    end
  end

  def can_do_first_try(%Aoc{path: [current | rest], grid: grid} = state) do
    %M{coordinates: this_point, choices: choices} = current
    visited_points = Enum.map(rest, fn pt -> pt.coordinates end)
    cond do
      choices == [] -> false
      # if it is outside the grid
      :error = Map.fetch(grid, first_choice_coordinate(this_point, hd(choices))) -> false
      # if already on the path
      this_point in visited_points -> false
      # if same level, okay
      Map.fetch!(grid, first_choice_coordinate(this_point, hd(choices))) ==
        Map.fetch!(grid, coordinate) -> true
      # if one higher, okay
      Map.fetch!(grid, first_choice_coordinate(this_point, hd(choices))) ==
        Map.fetch!(grid, coordinate) + 1 -> true
      # anything else we cannot visit
      true -> false
      end
  end

  def first_choice_coordinate({row, col}, s) do
    case s do
      "^" -> {row - 1, col}
      "<" -> {row, col - 1}
      "v" -> {row + 1, col}
      ">" -> {row, col + 1}
    end
  end

  def move_to_first_try(%Aoc{path: path, grid: grid} = state) do
    [current_point | previous_points] = path
    [present_choice | remaining_choices] = choices
    %M{coordinates: my_coordinates, choices: choices} = current_point
    next_coordinates = first_choice_coordinate(my_coordinates, present_choice)
    next_point = %M{coordinates: next_coordinates, }
    new_current_point = %{current_point | choices: remaining_choices}
    {:next, %{state | path: [next_point | [new_current_point | previous_points]]}}
  end

  # have another try if the choices list is length 2 or more
  # (current choice is still there, so it is length at least one)
  def have_second_try(%M{choices: [_h | []]}), do: false # only one choice
  def have_second_try(%M{choices: [_h|_t]}), do: true # at least two choices since tail is non-empty

  def print_answer(_state) do
  end

  def read_data do
    File.read!("data.txt")
    |> String.trim()
  end

  def tst do
    data = """
aabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
"""
    String.trim(data)
    |> process_and_print()
    []
  end

end
