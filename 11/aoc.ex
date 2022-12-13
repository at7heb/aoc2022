defmodule Aoc do
# c(["M.ex", "aoc.ex"]); Aoc.tst

  import M

  #data structure: map {row::integer,column::integer} -> {visited::boolean}
  # row and column are zero-based
  # the map also has keys
  #   :row_count::integer -> integer
  #   :column_count::integer -> integer


  def run do
    data = read_data()
    process_and_print(data)
    []
  end

def parse_data(data) do
    data
    |> String.split("\n\n", trim: true)
    |> Enum.reduce(%{}, fn spec, monkeys -> Map.put(monkeys, get_monkey_number(spec), get_monkey_specification(spec)) end)
    |> IO.inspect(label: "monkeys")
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
    |> execute_rounds(1..20)
  end

  def execute_rounds(%{} = monkeys, range) do
    Enum.reduce(range, monkeys, fn _r, m -> execute_round(m) end)
  end

  def execute_round(%{} = monkeys) do
    range = 1 .. Enum.max(Map.keys(monkeys))
    Enum.reduce(range, monkeys, fn num, m -> round_for(m, num) end)
  end

  def round_for(%{} = m, key) do
    monkey = Map.fetch!(m, key)
    i = monkey.inspections + length(monkey.items)
    new_monkey = %{monkey | inspections: i}

    IO.inspect({key, monkey, new_monkey})
    Map.put(m, key, new_monkey)
  end

  def print_answer(_state) do
  end

  def read_data do
    File.read!("data.txt")
    |> String.trim()
  end

  def tst do
    data = """
    Monkey 0:
    Starting items: 79, 98
    Operation: new = old * 19
    Test: divisible by 23
      If true: throw to monkey 2
      If false: throw to monkey 3

  Monkey 1:
    Starting items: 54, 65, 75, 74
    Operation: new = old + 6
    Test: divisible by 19
      If true: throw to monkey 2
      If false: throw to monkey 0

  Monkey 2:
    Starting items: 79, 60, 97
    Operation: new = old * old
    Test: divisible by 13
      If true: throw to monkey 1
      If false: throw to monkey 3

  Monkey 3:
    Starting items: 74
    Operation: new = old + 3
    Test: divisible by 17
      If true: throw to monkey 0
      If false: throw to monkey 1
  """
    process_and_print(data)
    []
  end

end
