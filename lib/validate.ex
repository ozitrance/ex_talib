defmodule ExTalib.Validate do
  @moduledoc false
  import ExTalib.Constants
  import ExTalib.Macros
  alias ExTalib.Validations, as: V

  # VALIDATE
  @validations %{
    types(:series) => [&V.v_match_type/3, &V.v_not_empty/3, &V.v_no_nulls/3],
    types(:integer) => [&V.v_match_type/3, &V.v_min_max/3],
    types(:double) => [&V.v_match_type/3, &V.v_min_max/3],
    types(:ma_type) => [&V.v_match_type/3],
    # types(:list) => [&V.v_match_type/3, &V.v_not_empty/3],
    # types(:tensor) => [&V.v_match_type/3, &V.v_shape/3, &V.v_not_empty/3, &V.v_no_nulls/3]
    types(:tensor) => [&V.v_match_type/3, &V.v_shape/3, &V.v_not_empty/3]
    # types(:ma_type) => [&v_match_type/3, &v_min_max/3],

  }


  def validate(arg, def) when is_integer(arg),  do: apply_validations(arg, def, types(:integer))
  def validate(arg, def) when is_float(arg),  do: apply_validations(arg, def, types(:double))
  # def validate_and_prepare(arg, def) when is_series(arg) and elem(def, 1) === types(:double_array), do: prepare_(arg, :series, elem(def, 2), nil)

  def validate(arg, def) when is_series(arg),  do: apply_validations(arg, def, types(:series))
  def validate(arg, def) when is_atom(arg),  do: apply_validations(arg, def, types(:ma_type))
  # def validate(arg, def) when is_list(arg),  do: apply_validations(arg, def, types(:list))
  def validate(arg, def) when is_tensor(arg),  do: apply_validations(arg, def, types(:tensor))
    #type match to def (list/int/double)
    #type numerical
    #no-nuls
    #min-max?
    #length?


  defp apply_validations(arg, def, type) do
    errors = @validations[type]
      |> Enum.map(& &1.(arg, def, type))
      |> Enum.filter(& is_nil(&1) != true)
      |> Enum.reverse

    {arg, def, errors}
    # case Enum.empty?(errors) do
    #   true -> prepare_input(arg, elem(def, 2), elem(def, 1))
    #   false -> {nil, errors}
    # end

  end



end
