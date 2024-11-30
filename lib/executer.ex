defmodule ExTalib.Executer do

  alias ExTalib.{Nif, Validations}

  # require ExTalib.Definitions
  import ExTalib.Definitions
  import ExTalib.Prepare
  import ExTalib.Validate
  import ExTalib.Constants
  import ExTalib.Utils

  def run(args), do: run_(args, true)
  def run!(args), do: run_(args, false)
  def run_df(args), do: run_(args, true, true)
  def run_df!(args), do: run_(args, false, true)


  defp run_(args, validate_inputs, df_input \\ false) do
    [func_key | args] = args
    defintion =  Map.get(params(), functions(func_key))
    [func_name | defintion] = defintion
    [input_defs | defintion] = defintion
    [outputs_defs | _flags] = defintion
    [options | input_args] = args
    options = merge_options(options)
    {input_args, errors, df} = if df_input, do: extract_columns(input_args, input_defs, options, validate_inputs), else: {input_args, [], nil}
    {inputs, errors} = case Enum.empty?(errors) do
      true -> prepare_inputs(input_args, input_defs, validate_inputs)
      false -> {nil, errors}
    end

    case Enum.empty?(errors) do
      false -> {:error, errors |> List.flatten}
      true ->
        result = calculate(func_name, inputs, outputs_defs)
        outputs = prepare_outputs(result, outputs_defs, input_args, options, df)
        if validate_inputs, do: {:ok, outputs}, else: outputs
    end

  end

  defp prepare_inputs(input_args, input_defs, validate_inputs) do

    Enum.zip_reduce(input_args, input_defs, {[], []}, fn argument, definition, acc ->
      {val, err} =
        case validate_inputs do
          true -> validate(argument, definition) |> prepare_input
          false -> prepare_input({argument, definition, []})
        end

      {arguments, errors} = acc
      { [val | arguments], [err | errors] }
    end)
      |> then(fn {inputs, errors} -> {inputs, Enum.reverse(errors) |> Enum.filter(fn e -> !is_nil(e) end)} end)
      |> then(&Validations.v_same_length(&1, validate_inputs))
      |> then(&handle_price_inputs/1)

  end



  defp calculate(func_name, inputs, outputs_defs) do
    outputs_types = Enum.map(outputs_defs, &elem(&1, 1))
    Nif.call(func_name |> String.to_charlist, inputs, outputs_types)
  end


  defp prepare_outputs({outputs, first_index}, outputs_defs, input_args, options, df) do
    case is_nil(df) do
      true ->
        Enum.zip_reduce(outputs, outputs_defs, [], fn output, definition, acc ->
          result = prepare_output(output, first_index, definition, get_arg_type(List.first(input_args)))
         [result | acc]
        end)
      false ->
        postfix = get_prefix(input_args)
        Enum.zip_reduce(Enum.reverse(outputs), outputs_defs, {df, options.out_columns}, fn output, definition, {df, out_col_names} ->
          {name, out_col_names} = List.pop_at(out_col_names, 0)
          {Explorer.DataFrame.mutate_with(df, ["#{name || Atom.to_string(elem(definition, 0)) <> postfix}": prepare_output(output, first_index, definition, get_arg_type(List.first(input_args)))]), out_col_names}
        end)
          |> then(fn {df, _out_col_names} -> df end)
    end
  end


  # defp return_errors(errors) do
  #   errors
  # end


  # class MA_Type(object):
  #   SMA, EMA, WMA, DEMA, TEMA, TRIMA, KAMA, MAMA, T3 = range(9)

    # def __init__(self):
    #     self._lookup = {
    #         MA_Type.SMA: 'Simple Moving Average',
    #         MA_Type.EMA: 'Exponential Moving Average',
    #         MA_Type.WMA: 'Weighted Moving Average',
    #         MA_Type.DEMA: 'Double Exponential Moving Average',
    #         MA_Type.TEMA: 'Triple Exponential Moving Average',
    #         MA_Type.TRIMA: 'Triangular Moving Average',
    #         MA_Type.KAMA: 'Kaufman Adaptive Moving Average',
    #         MA_Type.MAMA: 'MESA Adaptive Moving Average',
    #         MA_Type.T3: 'Triple Generalized Double Exponential Moving Average',
    #         }




end
