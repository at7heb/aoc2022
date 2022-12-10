defmodule Aoc do
# c(["aoc.ex"]); Aoc.tst
  defstruct row_count: 0, column_count: 0, forest_map: %{}, visible_list: []

  #data structure: map {row::integer,column::integer} -> {height::integer, visible::boolean}
  # row and column are zero-based
  # the map also has keys
  #   :row_count::integer -> integer
  #   :column_count::integer -> integer


  def run do
    data = read_data()
    data |> process_and_print
    []
  end

  def tst do
    d = """
30373
25512
65332
33549
35390
"""
    d |> process_and_print
    []
  end

  def process_and_print(d) do
    %Aoc{}
    |> add_data(d)
    |> mark_exterior()
    |> visit_interior()
    |> print_answer()
  end
  def visit_interior(%Aoc{forest_map: fmap} = state) do
    row_range = 1..state.row_count-2
    col_range = 1..state.column_count-2
    visible_tree_coordinates = (
      Enum.map(row_range, fn r ->
              Enum.map(col_range, fn c -> check_visibility(fmap, r, c, state.row_count, state.column_count) end)
      end)
      |> List.flatten()
      |> Enum.filter(fn a -> !is_nil(a) end)
      )
    %{state | visible_list: visible_tree_coordinates}
  end

  def check_visibility(%{} = fmap, r, c, rc, cc) do
    visible = (look_north(fmap, r, c, rc, cc) ||
              look_east(fmap, r, c, rc, cc) ||
              look_south(fmap, r, c, rc, cc) ||
              look_west(fmap, r, c, rc, cc))
    if visible, do: {r, c}, else: nil
  end

  def get_height(fmap, r, c) do
    {height, _} = Map.get(fmap, {r, c})
    height
  end

  def look_north(%{} = fmap, r, c, _rc, _cc) do
    r_range = 0..r-1
    height = get_height(fmap, r, c)
    Enum.reduce_while(
      r_range,
      true,
      fn r_prime, _acc -> if height > get_height(fmap, r_prime, c), do: {:cont, true}, else: {:halt, false} end
    )
  end

  def look_south(%{} = fmap, r, c, rc, _cc) do
    r_range = r+1..rc-1
    height = get_height(fmap, r, c)
    Enum.reduce_while(
      r_range,
      true,
      fn r_prime, _acc -> if height > get_height(fmap, r_prime, c), do: {:cont, true}, else: {:halt, false} end
    )
  end

  def look_west(%{} = fmap, r, c, _rc, _cc) do
    c_range = 0..c-1
    height = get_height(fmap, r, c)
    Enum.reduce_while(
      c_range,
      true,
      fn c_prime, _acc -> if height > get_height(fmap, r, c_prime), do: {:cont, true}, else: {:halt, false} end
    )
  end

  def look_east(%{} = fmap, r, c, _rc, cc) do
    c_range = c+1..cc-1
    height = get_height(fmap, r, c)
    Enum.reduce_while(
      c_range,
      true,
      fn c_prime, _acc -> if height > get_height(fmap, r, c_prime), do: {:cont, true}, else: {:halt, false} end
    )
  end

  def mark_exterior(%Aoc{forest_map: fmap} = state) do
    _borders = (fmap
                |> Map.keys()
                |> Enum.filter(fn {r,c} -> r==0 || c==0 || r == state.row_count-1 || c == state.column_count-1 end)
               )
    |> set_visible(state)
  end

  def set_visible(coordinates, %Aoc{forest_map: fmap} = state) do
    new_fmap = Enum.reduce(coordinates, fmap, fn coord, map -> Map.put(map, coord, set_visible(Map.get(map, coord))) end)
    %{state | forest_map: new_fmap}
  end

  def set_visible({h, _}), do: {h, true}

  def add_data(%Aoc{} = forest_map, d) do
    data_rows = String.split(d, "\n", trim: true) # |> IO.inspect(label: "rows")
    row_count = length(data_rows)
    column_count = String.length(hd(data_rows))
    # IO.inspect({row_count, column_count}, label: "add data 0")
    map = (
      Enum.reduce(0..row_count-1, %{}, fn row, map ->
        Enum.reduce(0..column_count-1, map, fn col, map ->
          Map.put(map, {row, col}, {Enum.at(data_rows, row,"z") |> String.at(col) |> String.to_integer(), false} )
        end
        )
      end
      )
    )
    %{forest_map | row_count: row_count, column_count: column_count, forest_map: map}
  end

  def print_answer(%Aoc{visible_list: visibles, row_count: rc, column_count: cc} = _state) do
    visible_count = 2*rc + 2*(cc-2) + length(visibles)
    IO.puts("in forest_map #{visible_count} trees visible")
    IO.inspect(visibles, label: "visible interior trees")
    ""
  end

  def read_data do
    File.read!("data.txt")
    |> String.trim()
  end
end
