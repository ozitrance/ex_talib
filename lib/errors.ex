defmodule ExTalib.Errors do
  @moduledoc false
  import ExTalib.Constants
  import ExTalib.Utils
  def build_input_error(arg, def, error) do
    name = elem(def, 0)

    case error do
      :col_not_exist -> "Column `#{name}` doesn't exist in dataframe."
      :same_length -> "Inputs for all lists must be equal."
      :ma_type -> "Inputs for `#{name}` can only be on of: [:sma, :ema, :wma, :dema, :tema, :trima, :kama, :mama, :t3]."
      :no_nulls -> "Inputs for `#{name}` cannot contain any nil or nan values."
      :not_empty -> "Inputs for `#{name}` cannot contain epmty lists."
      :shape -> "Tensor shape can only have one level. (Expected: [n])"
      :match_type ->
        arg_type = get_arg_type(arg)
        if arg_type === {:ma_type} do
          "Input for `#{name}` type does not match type from defintion. (Received: #{arg}, Expected one of: [:sma, :ema, :wma, :dema, :tema, :trima, :kama, :mama, :t3])"
        else
          def_type = elem(def, 1)
          case elem(arg_type, 0) do
            :tensor -> "Input for `#{name}` type does not match type from defintion. (Received tensor of: #{type_as_string(elem(arg_type, 1))}, Expected: #{types_atoms()[def_type]})"
            :series -> "Input for `#{name}` type does not match type from defintion. (Received: #{type_as_string(elem(arg_type, 1))}, Expected: #{types_atoms()[def_type]})"
            _ -> "Input for `#{name}` type does not match type from defintion. (Received: #{elem(arg_type, 0)}, Expected: #{types_atoms()[def_type]})"
          end
        end

      :min_max ->
        {min, max} = elem(def, 4)
        "Inputs for `#{name}` exceeds minimum-maximum constraints. (Received: #{arg}, Min: #{min}, Max: #{max})"
      _ -> "Unknown Error"
    end
  end

end
