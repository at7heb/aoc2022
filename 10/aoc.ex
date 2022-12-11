defmodule Aoc do
# c(["aoc.ex"]); Aoc.tst
  defstruct program: [], c_pc: 1, c_x: 1, c_ck: 1,
    bkpts: %{20=>nil, 60=>nil, 100=>nil, 140=>nil, 180=>nil, 220=>nil}

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

def parse_data(data) do
    data
    |> String.split("\n", trim: true)
    |> Enum.map(fn s -> String.split(s, " ") end)
    |> Enum.map(fn inst -> parse_instruction(inst) end)
  end

  def parse_instruction([opcode, string_value]=op) when is_list(op), do: [opcode, String.to_integer(string_value)]

  def parse_instruction([opcode]) when is_binary(opcode), do: [opcode]

  def process_and_print(%Aoc{} = state, data) do
    parse_data(data)
    |> add_program(state)
    |> execute_program()
    |> print_answer

    # IO.puts("long tail / part 2 follows=================================================")
    # new_state = %{state | lt: Tuple.duplicate({0,0}, 10)}
    # parse_data(data)
    # |> long_tail_follows_head(new_state)
    # |> print_answer
  end

  def execute_program(%Aoc{program: program, c_pc: pc} = state)
    when pc > length(program), do: state

  def execute_program(%Aoc{program: program, c_pc: pc} = state) do
    execute_instruction(state, Enum.at(program, pc-1))
    |> execute_program()
  end

  def execute_instruction(%Aoc{} = state, ["noop"]) do
    # IO.inspect(state, label: "noop starting")
    trigger_breakpoints(state)
    |> advance_clock()
    |> advance_pc()
  end

  def execute_instruction(%Aoc{} = state, ["addx", value]) do
    trigger_breakpoints(state)
    |> advance_clock()
    |> trigger_breakpoints
    |> addx(value)
    |> advance_clock()
    |> advance_pc()
  end

  # def advance_clock(%Aoc{c_ck: clock} = state), do: %{state | c_ck: clock + 1}
  def advance_clock(%Aoc{c_ck: clock} = state) do
    IO.inspect({state.c_pc, clock, Enum.at(state.program, state.c_pc-1), state.c_x}, label: "uCode")
    %{state | c_ck: clock + 1}
  end

  def advance_pc(%Aoc{c_pc: pc} = state), do: %{state | c_pc: pc + 1}

  def addx(%Aoc{c_x: x} = state, value), do: %{state | c_x: x + value}

  def trigger_breakpoints(%Aoc{c_ck: clock, bkpts: breaks, c_x: x} = state) do
    case Map.fetch(breaks, clock) do
      :error -> state
      {:ok, nil} -> %{state | bkpts: Map.put(breaks, clock, clock * x)}
    end
  end

  def add_program(data, %Aoc{} = state) when is_list(data) do
    %{state | program: data}
  end

  def print_answer(%Aoc{} = state) do
    answer = state.c_x
    IO.puts("answer = #{answer}")
    IO.inspect(state.bkpts, label: "breakpoint values")
    IO.puts("other answer #{state.bkpts |> Map.values() |> Enum.sum()}")
    ""
  end

  def read_data do
    File.read!("data.txt")
    |> String.trim()
  end

  def tst do
    data = """
noop
addx 3
noop
addx -5
noop
noop
"""
    %Aoc{}
    |> process_and_print(data)
    []
  end

  def tst2 do
    data = """
addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop
"""
    %Aoc{}
    |> process_and_print(data)
    []
  end
end
