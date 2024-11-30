defmodule ExTalib.Nif do
  @moduledoc false

  @on_load :load_nif

  def load_nif do
    nif_file = :filename.join(:code.priv_dir(:ex_talib), "ex_talib")
    :erlang.load_nif(nif_file, 0)
  end

  def call(_func_key, _inputs, _outputs) do
    :erlang.nif_error(:not_loaded)
  end


end
