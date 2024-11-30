defmodule ExTalib.Prepare do

  import ExTalib.Constants
  import ExTalib.Macros
  alias ExTalib.Utils

  # PREPARE INPUTS
  def prepare_input({arg, def, errors}) do
    case Enum.empty?(errors) do
      true -> prepare_input!(arg, elem(def, 2), elem(def, 1))
      false -> {nil, errors}
    end

  end

  defp prepare_input!(arg, is_opt, type) do
    type_ = if Enum.member?(price_types(), type), do: types(:double_array), else: type
    case type_ do
      types(:integer) -> r({arg, types(:integer), is_opt})
      types(:double) -> r({arg, types(:double), is_opt})
      types(:ma_type) -> r({ma_types(arg), types(:integer), is_opt})
      types(:double_array) when is_series(arg) -> r({Explorer.Series.cast(arg, {:f, 64}) |> Explorer.Series.to_binary, type, is_opt})
      types(:double_array) when is_tensor(arg) -> r({Nx.as_type(arg, {:f, 64}) |> Nx.to_binary, type, is_opt})
      # 4 when is_tensor(arg) -> r({Nx.as_type(arg, {:f, 64}) |> Nx.to_binary, type, is_opt})
    end

  end

  defp r(input), do: {input, nil}


  def handle_price_inputs({_inputs, errors}) when errors !== [], do: {nil, errors}

  def handle_price_inputs({inputs, errors}) do
    zero_bin_tuple = Tuple.duplicate(<<0>>, 6)
    {price_inputs, other_inputs} = inputs
      |> Enum.reduce({zero_bin_tuple, []}, fn input, acc ->
        {prices, others} = acc
        type = elem(input, 1)
        case Enum.member?(price_types(), type) do
          true -> {prices |> Tuple.delete_at(price_type_index()[type]) |> Tuple.insert_at(price_type_index()[type], elem(input, 0)), others}
          false -> {prices, [input | others]}
        end
      end)
    # errors = Enum.reverse(errors) |> Enum.filter(fn e -> !is_nil(e) end)
    if price_inputs === zero_bin_tuple, do: {Enum.reverse(inputs), errors}, else: {Enum.reverse([{price_inputs, types(:prices), 0} | Enum.reverse(other_inputs)]), errors}
  end



  # PREPARE OUTPUTS
  def prepare_output(arg, first_index, def, output_as) do
    out_type_from_def = elem(def, 1)
    prepare_output!(out_type_from_def, arg, output_as, first_index)
  end

  defp prepare_output!(arr_type, arg, output_as, first_index) do
    output_type = elem(output_as, 0)
    IO.inspect(arr_type, label: "arr_type")
    case output_type do
      :series ->
        type = if arr_type === types(:double_array), do: {:f, 64}, else: {:s, 32}
        Explorer.Series.from_binary(arg, type) |> Utils.pad_with_nans(first_index)
        # Explorer.Series.from_binary(arg, {:f, 64}) |> Explorer.Series.cast(elem(output_as, 1))
      :tensor ->
        type = if arr_type === types(:double_array), do: :f64, else: :s32
        if arg === "", do: Utils.handle_empty_tensor_output(first_index), else: Nx.from_binary(arg, type) |> Utils.pad_with_nans(first_index)

    end
  end

end
