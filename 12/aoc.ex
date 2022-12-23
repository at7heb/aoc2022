defmodule Aoc do
# c(["m.ex", "aoc.ex"]); Aoc.tst

  defstruct grid: %{}, path: [], paths: []
# the grid has {row, col} => elevation
# the path is a list of %M{}s with
# %M{} having %{coordinate: {row, col}, choices: ["^","<","v", ">"] (or subset)}
# paths has a successful path


  import M

# the algorithm is to initialize path to [%M{coordinate: {0,0}, choices: ["v",">"]}]
# visit the grid point indicated by the head of choices (and remove that choice from the list)
# the new point is initialized with choices according to these rules:
# 1. don't go off the grid; 2: don't include a choice leading to a visited point
# 3. don't include a choice leading to a lower point

# if the current point has elevation "z" and there are no choices, add the path to paths
# if there are no choices, back up.
# if there are no choices and the curent point is {0,0} then find the shortest path in paths[]

  def run do
    data = read_data()
    process_and_print(data)
    []
  end

def parse_data(data) do
    data
    |> String.split("\n\n", trim: true)
    |> Enum.reduce(%{}, fn spec, monkeys -> Map.put(monkeys, get_monkey_number(spec), get_monkey_specification(spec)) end)
    # |> IO.inspect(label: "monkeys")
    # |> Enum.map(fn s -> String.split(s, " ") end)
    # |> Enum.map(fn inst -> parse_instruction(inst) end)
  end

  def get_monkey_number(spec) do
    String.split(spec, "\n", trim: true)
    |> Enum.take(1)
    |> Enum.at(0)
    |> String.split([" ", ":"], trim: true)
    |> Enum.at(1)
    |> String.to_integer()
  end

  def get_monkey_specification(spec) do
    String.split(spec, "\n", trim: true)
    |> Enum.slice(1..99)
    |> Enum.map(fn l -> String.split(l, [" ", ":"], trim: true) end)
    |> get_monkey_specification(%M{})
  end

  def get_monkey_specification(spec_list, %M{} = monkey) do
    Enum.reduce(spec_list, monkey, fn s, m -> parse_and_update(s, m) end)
  end

  def parse_and_update(["Starting"|["items"|item_list]] = _s, %M{} = m) do
    items = Enum.map(item_list, fn i -> String.replace(i, ",", "") |> String.to_integer() end)
    %{m | items: items}
  end

  def parse_and_update(["Operation", "new", "=", "old", "*", "old"], %M{} = m) do
    %{m | op_add: 0, op_exponent: 2}
  end

  def parse_and_update(["Operation", "new", "=", "old", operation, operand], %M{} = m) do
    op = String.to_integer(operand)
    case operation do
      "*" -> %{m | op_add: 0, op_mult: op}
      "+" -> %{m | op_add: op, op_mult: 1}
    end
  end

  def parse_and_update(["Test", "divisible", "by", divisor], %M{} = m) do
    div = String.to_integer(divisor)
    %{m | divisor: div}
  end

  def parse_and_update(["If", tf, "throw", "to", "monkey", dest], %M{} = m) do
    destination = String.to_integer(dest)
    case tf do
      "true"  -> %{m | if_true: destination}
      "false" -> %{m | if_false: destination}
    end
  end

  def parse_and_update(s, %M{} = m) do
    IO.inspect(s, label: :unknown_specification)
    m
  end

  def process_and_print(data) do
    parse_data(data)
    |> execute_rounds(1..10000)
    |> IO.inspect(label: "after the rounds")
    |> Map.to_list()
    |> Enum.map(fn {_k, v} -> (0 + v.inspections) end)
    |> IO.inspect(label: "list of inspection counts")
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> IO.inspect(label: "top 2")
    # |> Enum.map(fn x -> x end)
    # |> IO.inspect(label: "top 2 true")
    |> Enum.product()
    |> IO.inspect(label: "product")
  end

  def execute_rounds(%{} = monkeys, range) do
    Enum.reduce(range, monkeys, fn r, m -> execute_round(m, r) end)
  end

  def execute_round(%{} = monkeys, round) do
    # IO.puts("Round #{round} starting---------------------------------------------")
    range = Enum.min(Map.keys(monkeys)) .. Enum.max(Map.keys(monkeys))
    rv = Enum.reduce(range, monkeys, fn num, m -> round_for(m, num) end)
    if (round == 1) || (round == 20) do IO.inspect(rv, label: "round #{round}") end
    rv
  end

  def round_for(%{} = monkeys, key) do
    rv = (monkeys |> Map.fetch!(key) |> handle_items(monkeys, key))
    # IO.inspect({key, monkeys}, label: "did round for monkey#")
    rv
  end

  def handle_items(%M{} = monkey, monkeys, key) do
    modulus = get_modulus(monkeys)
    new_monkeys = Enum.reduce(monkey.items, monkeys, fn item, monkeys -> handle_an_item(item, monkey, monkeys, modulus) end)
    new_inspections = monkey.inspections + length(monkey.items)
    new_monkey = %{monkey | items: [], inspections: new_inspections}
    Map.put(new_monkeys, key, new_monkey)
  end

  def handle_an_item(item, %M{} = monkey, monkeys, modulus) do
    op_add = monkey.op_add; op_mult = monkey.op_mult; op_exponent = monkey.op_exponent
    divisor = monkey.divisor;
    true_monkey = monkey.if_true; false_monkey = monkey.if_false
    new_item = (op_mult*(item + op_add) |> pow(op_exponent) |> rem(modulus))
    # IO.inspect({new_item, item, op_add, op_mult, op_exponent, modulus}, label: "new_item")
    remainder = rem(new_item, divisor)
    destination_monkey = if remainder == 0 do true_monkey else false_monkey end
    add_item_to_monkey(new_item, destination_monkey, monkeys)
  end

  def add_item_to_monkey(item, number, monkeys) do
    monkey = Map.fetch!(monkeys, number)
    items = monkey.items ++ [item]
    new_monkey = %{monkey| items: items}
    Map.put(monkeys, number, new_monkey)
  end

  def get_modulus(monkeys) do
    Enum.reduce(Map.values(monkeys), 1, fn monkey, modulus -> modulus * Map.fetch!(monkey, :divisor) end)
  end

  def pow(n, 1), do: n
  def pow(n, 2), do: n*n

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
    accszzxk
    acctuvwj
    abdefghi
"""
    process_and_print(data)
    []
  end

end
