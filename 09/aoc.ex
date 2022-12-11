defmodule Aoc do
# c(["aoc.ex"]); Aoc.tst
  defstruct h: {0, 0}, t: {0, 0}, lt: {}, tail_path: MapSet.new([{0,0}])

  #data structure: map {row::integer,column::integer} -> {visited::boolean}
  # row and column are zero-based
  # the map also has keys
  #   :row_count::integer -> integer
  #   :column_count::integer -> integer


  def run do
    data = read_data()
    %Aoc{}
    |> process_and_print(data)
    []
  end

  def tst do
    data = """
R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2
"""
    %Aoc{}
    |> process_and_print(data)
    []
  end

  def tst2 do
    data = """
R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20
"""
  %Aoc{}
  |> process_and_print(data)
  []
end

def parse_data(data) do
    data
    |> String.split("\n", trim: true)
    |> Enum.map(fn s -> String.split(s, " ") end)
    |> Enum.map(fn [d, c] -> [d, String.to_integer(c)] end)
  end

  def process_and_print(%Aoc{} = state, data) do
    parse_data(data)
    |> tail_follows_head(state)
    |> print_answer

    IO.puts("long tail / part 2 follows=================================================")
    new_state = %{state | lt: Tuple.duplicate({0,0}, 10)}
    parse_data(data)
    |> long_tail_follows_head(new_state)
    |> print_answer
  end

  def long_tail_follows_head(moves, %Aoc{} = state) do
    direction_map = %{"U"=>{1,0}, "L"=>{0,-1}, "D"=>{-1,0}, "R"=>{0,1}}
    moves
    |> Enum.reduce(state, fn [d, c] = _move, state -> long_tail_follows_head(state, direction_map[d], c) end)
  end

  def long_tail_follows_head(%Aoc{} = state, _rc_increments, 0) do
    state
  end

  def long_tail_follows_head(%Aoc{} = state, rc_increments, c) do
    state
    |> long_move_head_by_one(rc_increments)
    |> long_tail_follows_by_one(8)
    |> long_tail_follows_head(rc_increments, c-1)
  end

  def long_tail_follows_by_one(%Aoc{lt: rope} = state, index) do
    {h_r, h_c} = elem(rope, index + 1)
    {t_r, t_c} = elem(rope, index)
    dist = max(abs(h_r-t_r), abs(h_c-t_c))
    cond do
      (dist <= 1) -> state
      true -> adjust_rope(state, {t_r + funny_signum(h_r - t_r), t_c + funny_signum(h_c - t_c)}, index)
    end
  end

  def adjust_rope(%Aoc{lt: rope, tail_path: path} = state, {_r,_c} = coord, 0) do
    new_rope = put_elem(rope, 0, coord)
    new_path = MapSet.put(path, coord)
    IO.inspect(coord, label: "point added to path")
    %{state | lt: new_rope, tail_path: new_path}
  end

  def adjust_rope(%Aoc{lt: rope} = state, {_r,_c} = coord, index) do
    new_rope = put_elem(rope, index, coord)
    %{state | lt: new_rope}
    |> long_tail_follows_by_one(index - 1)
  end

  def long_move_head_by_one(%Aoc{lt: rope} = state, {delta_r, delta_c} = _incr) do
    {h_r, h_c} = elem(rope,9)
    new_h = {h_r + delta_r, h_c + delta_c}
    new_rope = put_elem(rope, 9, new_h)
    %{state | lt: new_rope}
  end

###############################################################################
######################### S H O R T ###########################################
###############################################################################
  def tail_follows_head(moves, %Aoc{} = state) do
    direction_map = %{"U"=>{1,0}, "L"=>{0,-1}, "D"=>{-1,0}, "R"=>{0,1}}
    moves
    |> Enum.reduce(state, fn [d, c] = _move, state -> tail_follows_head(state, direction_map[d], c) end)
  end

  def tail_follows_head(%Aoc{} = state, _rc_increments, 0) do
    state
  end

  def tail_follows_head(%Aoc{} = state, rc_increments, c) do
    state
    |> move_head_by_one(rc_increments)
    |> tail_follows_by_one()
    |> tail_follows_head(rc_increments, c-1)
  end

  def move_head_by_one(%Aoc{h: {h_r, h_c}} = state, {delta_r, delta_c} = _incr) do
    new_h = {h_r + delta_r, h_c + delta_c}
    %{state | h: new_h}
  end

  def tail_follows_by_one(%Aoc{h: {h_r, h_c}, t: {t_r, t_c} = t, tail_path: path} = state) do
    dist = max(abs(h_r-t_r), abs(h_c-t_c))
    new_t = cond do
      (dist <= 1) -> t
      true -> {t_r + funny_signum(h_r - t_r), t_c + funny_signum(h_c - t_c)}
    end
    new_path = MapSet.put(path, new_t)
    # IO.inspect({new_t, new_path}, label: "tail follows")
    %{state | t: new_t, tail_path: new_path} # |> IO.inspect(label: "state")
  end

  def funny_signum(a) do
    cond do
      a < 0   -> -1
      a == 0  ->  0
      true    ->  1
    end
  end

  def print_answer(%Aoc{tail_path: path} = _state) do
    answer = MapSet.size(path) |> IO.inspect(label: "position count")
    IO.puts("rope tail visited #{answer} positions at least once")
    ""
  end

  def read_data do
    File.read!("data.txt")
    |> String.trim()
  end
end
