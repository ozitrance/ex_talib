defmodule ExTalib.Utils do

  import ExTalib.Macros
  import ExTalib.Constants
  alias ExTalib.Errors
  def extract_columns(input_args, input_defs, options, validate_inputs) do
    {df, input_args} = List.pop_at(input_args, 0)
    {inputs, _col_names, errors, _input_args} =
      Enum.reduce(input_defs, {[], options.in_columns, [], input_args}, fn definition, {inputs, in_col_names, errors, input_args} ->
        {{input, in_col_names, errors}, input_args} =
          case Enum.member?([types(:double_array) | price_types()], elem(definition, 1)) do
            true -> if validate_inputs, do: {get_column(df, definition, in_col_names, errors), input_args}, else: {get_column!(df, definition, in_col_names, errors), input_args}
            false ->
              {argument, input_args} = List.pop_at(input_args, 0)
              {{argument, in_col_names, errors}, input_args}
          end
        {[input | inputs], in_col_names, errors, input_args}
      end)
    {Enum.reverse(inputs), Enum.reverse(errors), df}
  end

  defp get_column(df, definition, in_col_names, errors) do
    df_columns = Explorer.DataFrame.names(df)
    {name, rest} = List.pop_at(in_col_names, 0)
    name = if is_nil(name), do: Atom.to_string(elem(definition, 0)), else: name
    case Enum.member?(df_columns, name) do
      true -> {df[name], rest, errors}
      false -> {nil, rest, [Errors.build_input_error(nil, {name}, :col_not_exist) | errors]}
    end
  end

  defp get_column!(df, definition, in_col_names, errors) do
    {name, rest} = List.pop_at(in_col_names, 0)
    case name do
      nil -> {df[elem(definition, 0)], rest, errors}
      _ -> {df[name], rest, errors}
    end
  end

  def get_prefix(input_args) do
    input_args
     |> Enum.reduce("", fn input, acc ->
      case is_number(input) do
        true -> acc <> "_#{input}"
        false -> acc
      end
     end)
  end

  # def output_col_name(in)

  def merge_options(opts), do: Enum.into(opts, options())

  def get_arg_type(arg) do
    case arg do
      arg when is_series(arg) -> {:series, Explorer.Series.dtype(arg)}
      arg when is_tensor(arg) -> {:tensor, Nx.type(arg)}
      arg when is_integer(arg) -> {:integer}
      arg when is_float(arg) -> {:double}
      arg when is_nil(arg) -> {"nil"}
      arg when is_atom(arg) -> {:ma_type}
      # arg when is_list(arg) -> {:list, List.first(arg) |> is_decimal_type}
    end
  end

  def handle_empty_tensor_output(first_index) do
    case first_index === 0 do
      true -> [] # EMPTY RESULT????
      false -> Nx.tensor(list_of(:nan, first_index), type: :f64)
    end
  end

  def list_of(what, count) do
    1..count |> Enum.map(fn _x -> what end)
  end

  def input_length(arg) when is_dataframe(arg), do: Explorer.DataFrame.n_rows(arg)
  def input_length(arg) when is_series(arg), do: Explorer.Series.size(arg)
  # def input_length(arg) when is_list(arg), do: length(arg)
  def input_length(arg) when is_tensor(arg), do: Nx.shape(arg) |> elem(0)
  def input_length(arg) when is_binary(arg), do: :erlang.size(arg)
  def input_length(_arg), do: 0

  def type_as_string(type) when is_binary(type), do: "{#{type}}"
  def type_as_string(type) when is_atom(type), do: "{#{Atom.to_string(type)}}"
  def type_as_string(type) when is_tuple(type), do: "{#{elem(type, 0)}, #{elem(type, 1)}}"

  def pad_with_nans(arg, first_index) when first_index == 0, do: arg
  def pad_with_nans(arg, first_index) when is_series(arg), do: list_of(:nan, first_index) |> Explorer.Series.from_list |> Explorer.Series.concat(arg)
  def pad_with_nans(arg, first_index) when is_tensor(arg), do: list_of(:nan, first_index) |> Nx.tensor |> then(& Nx.concatenate([&1, arg]))
  # defp pad_with_nans(arg, first_index) when is_list(arg), do: Utils.list_of(:nan, first_index) |> Enum.concat(arg)

end
