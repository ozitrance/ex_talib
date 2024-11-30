defmodule TestHelper do
  import ExTalib.{Constants, Definitions, Macros}

  @open_valid [64601.8, 65329.0, 61483.7, 60684.5, 58144.5, 54003.5, 55991.3, 55102.9,
  61659.8, 60808.6, 60889.8, 58693.1, 59323.7, 60550.4, 58648.1, 57511.1,
  58854.9, 59468.5, 58390.1, 59398.4, 58982.7, 61120.0, 60349.9, 64020.0,
  64116.6, 64190.1, 62807.7, 59384.4, 59010.0, 59323.3, 59096.4]

  @high_valid [65650.0, 65577.0, 62166.0, 61089.5, 58286.9, 56999.9, 57699.0, 62737.2,
  61726.0, 61450.0, 6.2e4, 60666.0, 61545.0, 61839.7, 59820.0, 59780.2,
  59690.2, 60250.0, 59585.4, 61386.0, 61793.9, 61392.0, 6.5e4, 64472.5,
  65175.4, 64455.8, 63196.0, 60197.8, 61144.9, 59914.9, 59436.0]

  @low_valid [62271.2, 61200.2, 5.98e4, 57040.0, 48888.0, 53925.3, 54519.8, 54672.4,
  5.95e4, 60208.5, 58255.4, 57615.0, 58360.0, 58367.2, 55969.0, 57062.1,
  58769.4, 58352.0, 57750.0, 58501.1, 58728.9, 59677.6, 60301.5, 63522.7,
  63731.3, 62750.2, 57928.2, 57820.0, 58655.0, 57525.0, 58700.0]

  @close_valid [65328.9, 61483.7, 60684.6, 58144.5, 54003.1, 55991.2, 55102.9, 61659.8,
  60808.6, 60889.9, 58693.1, 59323.6, 60550.5, 58648.1, 57511.0, 58854.9,
  59468.5, 58390.0, 59398.5, 58982.9, 61120.0, 60349.9, 64019.9, 64116.5,
  64190.2, 62807.6, 59384.5, 59010.0, 59323.2, 59096.3, 58941.9]

  @volume_valid [372654.59, 421628.42, 290469.956, 339512.415, 1281982.025, 435953.439,
  377442.54, 470117.508, 308674.339, 115593.354, 202539.076, 367126.29,
  255934.721, 295662.808, 360815.946, 268756.529, 77085.532, 149660.264,
  214043.139, 287049.13, 270583.679, 211098.959, 382490.709, 132741.902,
  115546.888, 195977.222, 339269.805, 313788.567, 233896.685, 268276.469,
  68866.674]

  @close_valid_ints [65328, 61483, 60684, 58144, 54003, 55991, 55102, 61659,
  60808, 60889, 58693, 59323, 60550, 58648, 57511, 58854,
  59468, 58390, 59398, 58982, 61120, 60349, 64019, 64116,
  64190, 62807, 59384, 59010, 59323, 59096, 58941]

  @close_valid_normalized [0.19577822527339886, 0.18425489590735605, 0.18186014596030395, 0.17424795181625805,
  0.16183696767069222, 0.16779492333298018, 0.16513285803706432, 0.18478263394474298, 0.18223175025693072,
  0.18247539081592878, 0.17589200114794717, 0.17778148912394062, 0.18145827389435515, 0.17575714474997778,
  0.1723494734137333, 0.17637688481886826, 0.1782157267254021, 0.1749836683874022, 0.17800595010633857,
  0.1767604763508701, 0.18316495653087897, 0.180857114040296, 0.1918554024969113, 0.19214489423121892,
  0.19236575904300435, 0.1882223711356157, 0.17796399478252586, 0.1768416898705361, 0.1777802904004031,
  0.177100314473753, 0.17663760718827576]

  # @close_strings ["65328.9", "61483.7", "60684.6", "58144.5", "54003.1", "55991.2", "55102.9", "61659.8",
  # "60808.6", "60889.9", "58693.1", "59323.6", "60550.5", "58648.1", "57511.0", "58854.9",
  # "59468.5", "58390.0", "59398.5", "58982.9", "61120.0", "60349.9", "64019.9", "64116.5",
  # "64190.2", "62807.6", "59384.5", "59010.0", "59323.2", "59096.3", "58941.9"]

  @close_with_nans [65328.9, 61483.7, 60684.6, :nan, 54003.1, 55991.2, 55102.9, 61659.8,
  60808.6, 60889.9, :nan, 59323.6, 60550.5, 58648.1, 57511.0, 58854.9,
  59468.5, 58390.0, 59398.5, 58982.9, :nan, 60349.9, 64019.9, 64116.5,
  64190.2, 62807.6, 59384.5, 59010.0, 59323.2, 59096.3, 58941.9]

  @close_empty []

  @bad_nx_shape [[65328.9, 61483.7, 60684.6, 58144.5, 54003.1, 55991.2, 55102.9, 61659.8],
                 [60808.6, 60889.9, 58693.1, 59323.6, 60550.5, 58648.1, 57511.0, 64019.9]]

  @bad_min_max -1

  @inputs %{
    :valid => %{
      :open => @open_valid,
      :high => @high_valid,
      :low => @low_valid,
      :close => @close_valid,
      :volume => @volume_valid,

      :values => @close_valid,

    },
    :valid_normalized => %{
      :values => @close_valid_normalized
    },
    :bad_input_type_int_array => %{
      :values => @close_ints
    },
    :bad_input_type_string_array => %{
      :values => @close_strings
    },
    :with_nans => %{
      :values => @close_with_nans
    },
    :empty_list => %{
      :values => @close_empty
    },
    :nx_shape => %{
      :values => @bad_nx_shape
    },
    :bad_min_max => %{
      :values => @close_valid,
      :time_period => @bad_min_max
    },

  }

  @options %{
    :default => []
  }

  def build_test_inputs(func_name, test_type, input_type, dataframe \\ false) do
    values = @inputs[test_type]
    def = params()[func_name |> functions()]
    [_name | rest] = def
    [input_defs | _rest] = rest
    input_defs
      |> Enum.reverse
      |> Enum.reduce([@options[:default]], fn input, acc ->
        input_name = input |> elem(0)
        case Map.has_key?(values, input_name) do
          true ->
            if is_list(values[input_name]), do: [build_input(values[input_name], input_type, test_type) | acc], else: [values[input_name] | acc]
          false -> [input |> elem(3) | acc]
        end
      end)
      |> then(fn inputs ->
          case dataframe do
            true -> series_inputs_to_df(input_defs, inputs)
            false -> inputs
          end
        end)
  end

  defp build_input(inp, type, test_type) do
    case type do
      # :list -> inp
      :series -> Explorer.Series.from_list(nans_to_nils(inp))
      :tensor -> if Enum.member?([:valid, :valid_normalized], test_type), do: Nx.tensor(inp, type: :f64), else: Nx.tensor(inp)
      # :tensor -> Nx.tensor(inp)
    end
  end

  defp series_inputs_to_df(input_defs, inputs) do
    Enum.zip_reduce(input_defs ++ [nil], inputs, {Explorer.DataFrame.new([]), []}, fn def, input, {df, out} ->
      case is_series(input) do
        true ->
          {Explorer.DataFrame.put(df, elem(def, 0), input), [nil | out]}
        false -> {df, [input | out]}
      end
    end)
      |> then(fn {df, outputs} -> {df, Enum.reverse(outputs)} end)
      |> then(fn {df, final} ->
        [_first | rest] = final
        [df | rest]
      end)
  end

  def nans_to_nils(list), do: Enum.map(list, fn i -> if i === :nan, do: nil, else: i end)

end
ExUnit.start()
