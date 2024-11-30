defmodule ExTalib.Macros do
  @moduledoc false
  # MODULES AVAILABLE?
  @explorer_available Code.ensure_loaded?(Explorer.DataFrame) and Code.ensure_loaded?(Explorer.Series)
  @nx_available Code.ensure_loaded?(Nx)
  @decimal_available Code.ensure_loaded?(Decimal)
  @vegalite_available Code.ensure_loaded?(VegaLite)

  defmacro is_explorer_loaded?, do: @explorer_available
  defmacro is_nx_loaded?, do: @nx_available
  defmacro is_decimal_loaded?, do: @decimal_available
  defmacro is_vegalite_loaded?, do: @vegalite_available


  # CHECK FOR SPECIAL TYPES/STRUCTS
  # CHECK FOR SPECIAL TYPES/STRUCTS
  # CHECK FOR SPECIAL TYPES/STRUCTS
  # CHECK FOR SPECIAL TYPES/STRUCTS
  # CHECK FOR SPECIAL TYPES/STRUCTS
  # CHECK FOR SPECIAL TYPES/STRUCTS
  # CHECK FOR SPECIAL TYPES/STRUCTS
  # CHECK FOR SPECIAL TYPES/STRUCTS

  # IS_INT
  # IS_FLOAR
  # IS_LIST
  defmacro is_series(var) do
    quote do is_explorer_loaded?() and is_struct(unquote(var)) and unquote(var).__struct__ === :"Elixir.Explorer.Series" end
  end

  defmacro is_dataframe(var) do
    quote do is_explorer_loaded?() and is_struct(unquote(var)) and unquote(var).__struct__ === :"Elixir.Explorer.DataFrame" end
  end

  defmacro is_tensor(var) do
    quote do is_nx_loaded?() and is_struct(unquote(var)) and unquote(var).__struct__ === :"Elixir.Nx.Tensor" end
  end

  defmacro is_series_decimal_type(var) do
    quote do is_tuple(unquote(var)) and tuple_size(unquote(var)) === 3 and elem(unquote(var), 0) === :decimal and is_integer(elem(unquote(var), 1)) and is_integer(elem(unquote(var), 2)) end
  end



  # defmacro is_decimal_type(var) do
  #   quote do is_decimal_loaded?() and is_struct(unquote(var)) and unquote(var).__struct__ === :"Elixir.Decimal" end
  # end


  # OTHERS
  defmacro is_in_boundaries?(var, min, max) do
    quote do unquote(var) >= unquote(min) and unquote(var) <= unquote(max) end
  end

end
