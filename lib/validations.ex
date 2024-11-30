defmodule ExTalib.Validations do
  alias ExTalib.Utils
  import ExTalib.Errors
  import ExTalib.Macros
  import ExTalib.Constants

  def v_match_type(arg, def, type) do

    def_type = elem(def, 1)

    case type do
      types(:ma_type) -> v!(:match_type, def_type === types(:ma_type) and Enum.member?(talib_ma_types(), arg), arg, def)
      types(:integer) -> v!(:match_type, def_type === types(:integer), arg, def)
      types(:double) -> v!(:match_type, def_type === types(:double), arg, def)
      types(:tensor) ->
        values_type = Nx.type(arg)
        case Enum.member?([types(:double_array) | price_types()], def_type) do
          true -> v!(:match_type, Enum.member?(explorer_double_types(), values_type), arg, def)
          false -> if def_type === types(:integer_array), do: v!(:match_type, Enum.member?(explorer_integer_types(), values_type), arg, def), else: false
        end
      types(:series) ->
        values_type = if is_series_decimal_type(Explorer.Series.dtype(arg)), do: {:decimal}, else: Explorer.Series.dtype(arg)
        case Enum.member?([types(:double_array) | price_types()], def_type) do
          true -> v!(:match_type, Enum.member?(explorer_double_types(), values_type), arg, def)
          false -> if def_type === types(:integer_array), do: v!(:match_type, Enum.member?(explorer_integer_types(), values_type), arg, def), else: false
        end
      # types(:list) ->
      #   case Enum.member?([types(:double_array) | price_types()], def_type) do
      #     true -> v!(:match_type, Enum.all?(arg, &is_float/1) or verify_list_all_decimals(arg), arg, def)
      #     false -> v!(:match_type, Enum.all?(arg, &is_integer/1), arg, def)
      #   end
    end
  end

  def v_no_nulls(arg, def, type) do
    case type do
      types(:series) -> v!(:no_nulls, Explorer.Series.nil_count(arg) === 0, arg, def)
      # types(:tensor) -> v!(:no_nulls, (Nx.is_nan(arg) |> Nx.sum |> Nx.to_number) === 0, arg, def)
    end
  end


  def v_not_empty(arg, def, type) do
    case type do
      types(:series) -> v!(:not_empty, Explorer.Series.size(arg) > 0, arg, def)
      types(:tensor) -> v!(:not_empty, (Nx.shape(arg) |> elem(0)) > 0, arg, def)
      # types(:list) -> v!(:not_empty, Enum.empty?(arg) === false, arg, def)
    end
  end


  def v_shape(arg, def, _type), do: v!(:shape, tuple_size(Nx.shape(arg)) === 1, arg, def)

  def v_min_max(_arg, def, _type) when tuple_size(def) < 5, do: nil
  def v_min_max(arg, def, _type) do
    {min, max} = elem(def, 4)
    v!(:min_max, is_in_boundaries?(arg, min, max), arg, def)
  end


  def v_same_length({_inputs, errors}, _validate_inputs) when errors !== [], do: {nil, errors}
  def v_same_length(result, validate_inputs) when not validate_inputs, do: result
  def v_same_length({inputs, errors}, _validate_inputs) do
    lists_lengths = Enum.reduce(inputs, [], fn input, acc ->
      len = Utils.input_length(input |> elem(0))
      case len > 0 do
        true -> [len | acc]
        false -> acc
      end
    end)
    same_length = case length(lists_lengths) > 1 do
      true -> Enum.all?(lists_lengths, & &1 === List.first(lists_lengths))
      false -> true
    end

    case same_length do
      true -> {inputs, errors}
      false -> {nil, [[build_input_error(nil, {nil}, :same_length)] | errors]}
    end

  end




  # defp verify_list_all_decimals(list) do
  #   case is_decimal_loaded?() do
  #     true -> Enum.all?(list, &Decimal.is_decimal/1)
  #     false -> false
  #   end
  # end

  defp v!(v_type, condition, arg, def) do
    case (condition) do
      true -> nil
      false -> build_input_error(arg, def, v_type)
    end
  end

end
