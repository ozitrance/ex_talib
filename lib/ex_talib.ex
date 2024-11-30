import ExTalib.{Executer, Macros}
defmodule ExTalib do
@moduledoc """
  # ExTalib
  Nif Wrapper Implementation for TA-LIB.

  It will use system installed TA-LIB so you must install that first:

  ## Install TA-LIB (Ubuntu)

  ```sh
  apt-get update
  apt-get install gcc build-essential wget
  wget https://github.com/TA-Lib/ta-lib/raw/refs/heads/main/dist/ta-lib-0.6.0-src.tar.gz
  tar -zxvf ta-lib-0.6.0-src.tar.gz
  rm ta-lib-0.6.0-src.tar.gz
  cd ta-lib-git
  ./configure --prefix=/usr
  make
  sudo make install
  cd ../
  rm -rf ta-lib-git
  ```

  ## Install TA-LIB (Mac OS)

  ```sh
  brew install ta-lib
  ```

  ## Adding The Package To Your Project

  You must have either [Nx](https://hexdocs.pm/nx) or [Explorer](https://hexdocs.pm/explorer) to use this library. It must be installed before or together with this library.
  If you installed this library first and later Nx or Explorer you might get errors. In this case clean up your dependencies library and just get them all again:
  ```sh
  mix deps.clean --all
  mix deps.get
  ```

  ```elixir
  def deps do
    [
      <!-- {:ex_talib, "~> 0.1.0"} -->
      {:ex_talib,, git: "https://github.com/ozitrance/ex_talib"}
    ]
  end
  ```


  ## Functions List
  This package includes all the available functions (161) from the official TALib library. For the full list check out [their website](https://ta-lib.org/functions/).

  ## Usage
  Each function can be used with either an `Explorer.DataFrame`, `Explorer.Series` or `Nx.Tensor`. If using a dataframe, the function expects come columns to exist (check the function documntation to find which ones or use `options` to use others).

  The output will be the same as the input (input of a dataframe will return a dataframe, series will return a series...)

  The function will validate the inputs and will return either `{:ok, result}` on success or `{:error, errors}` in case of failure.

  `errors` is a list of `String` errors.
  `result` is either an `Explorer.DataFrame` (in case the input was a dataframe) or a `list` of [`Explorer.Series`] or [`Nx.Tensor`]s

  For example:
  ```elixir
  iex(1)> df = Explorer.DataFrame.new(%{values: [1.0,2.0,3.0,4.0,5.0]})
  iex(2)> ExTalib.ema(df, 2)
  {:ok,
  #Explorer.DataFrame<
    Polars[5 x 2]
    values f64 [1.0, 2.0, 3.0, 4.0, 5.0]
    ema_2 f64 [NaN, 1.5, 2.5, 3.5, 4.5]
  >}
  iex(3)> series = Explorer.Series.from_list([1.0,2.0,3.0,4.0,5.0])
  iex(4)> ExTalib.ema(series, 2)
  {:ok,
  {#Explorer.Series<
      Polars[5]
      f64 [NaN, 1.5, 2.5, 3.5, 4.5]
    >}}

  iex(5)> tensor = Nx.tensor([1.0,2.0,3.0,4.0,5.0])
  iex(6)> ExTalib.ema(tensor, 2)
  {:ok,
  {#Nx.Tensor<
      f64[5]
      [NaN, 1.5, 2.5, 3.5, 4.5]
    >}}

  # AND ERRORS:
  iex(7)> ExTalib.ema(tensor, -2)
  {:error,
  ["Inputs for `time_period` exceeds minimum-maximum constraints. (Received: -2, Min: 2, Max: 100000)"]
  }
  iex(8)> ExTalib.cdldoji(df)
  {:error,
  ["Column `open` doesn't exist in dataframe.",
    "Column `high` doesn't exist in dataframe.",
    "Column `low` doesn't exist in dataframe.",
    "Column `close` doesn't exist in dataframe."]
    }
  ```

  ## Options
  All functions has an `options` list as their last argument.
  Currently the only valid options are: `in_columns` and `out_columns` and they are only relevant when the input is a DataFrame. With those options you can control which columns will be used as the inputs and which names will be used for the outputs. This is useful when the function expect columns you don't have, or you want more control on the output names.

  For example, many functions accept your dataframe to have the `values`. If you want to use the `close` value instead, and don't want to duplicate or rename your columns, you can do things like this:
  ```elixir
  ExTalib.rsi(df, 14,
    [in_columns: ["close"]]
  )
  ExTalib.correl(df, nil, 30,
    [in_columns: ["btc_close", "eth_close"], out_columns: ["btc_eth_correl"]]
  )
  ExTalib.bbands(df, nil, 30,
    [in_columns: ["close"], out_columns: ["bbands_up", "bbands_mid", "bbands_low"]]
  )
  ```

  The `in_columns` and `out_columns` will be used if they exist, using the input/output order. You can include some/all or none. In that case the defaults will be used.

  ## Bang! Functions
  Each function has a bang(!) version as well that **DOES NOT INCLUDE VALIDATIONS** and returns the result without the :ok/:error tuple.
  It is usefull when you know your inputs are valid, so you can use it like this:

  ```elixir
  df
    |> ExTalib.rsi!(14, [in_columns: ["close"]])
    |> ExTalib.rsi!(30, [in_columns: ["close"]])
    |> ExTalib.sma!(9, [in_columns: ["close"]])
    |> ExTalib.ema!(21, [in_columns: ["close"]])
    |> ExTalib.ema!(50, [in_columns: ["close"]])
    |> ExTalib.ema!(75, [in_columns: ["close"]])
    |> Explorer.DataFrame.tail

  # OR
  bbands = ExTalib.bbands!(df["close"])
  df
    |> Explorer.DataFrame.put(:bbands_upper, bbands |> elem(0))
    |> Explorer.DataFrame.put(:bbands_mid, bbands |> elem(1))
    |> Explorer.DataFrame.put(:bbands_lower, bbands |> elem(2))
    |> Explorer.DataFrame.put(:rsi_14, ExTalib.rsi!(df["close"], 14) |> elem(0))
    |> Explorer.DataFrame.put(:rsi_30, ExTalib.rsi!(df["close"], 30) |> elem(0))
    |> Explorer.DataFrame.put(:sma_9, ExTalib.sma!(df["close"], 9) |> elem(0))
    |> Explorer.DataFrame.put(:ema_21, ExTalib.ema!(df["close"], 21) |> elem(0))
    |> Explorer.DataFrame.put(:ema_50, ExTalib.ema!(df["close"], 50) |> elem(0))
    |> Explorer.DataFrame.put(:ema_75, ExTalib.ema!(df["close"], 75) |> elem(0))
    |> Explorer.DataFrame.tail
  ```

  And you'll receive something like this:

  ```elixir
  #Explorer.DataFrame<
    Polars[5 x 18]
    ........
    bbands_upper f64 [65344.977205262854, 65251.12375330862, 65091.12861934584,
    65384.41021308116, 65653.70482382084]
    bbands_mid f64 [64403.499999999956, 64705.03999999996, 64837.01999999996,
    64950.93999999996, 65112.21999999996]
    bbands_lower f64 [63462.02279473706, 64158.9562466913, 64582.91138065408,
    64517.46978691876, 64570.73517617908]
    rsi_14 f64 [70.14928031257307, 72.97336944060123, 68.34457254966325,
    72.72843213105321, 74.49954840550322]
    rsi_30 f64 [58.800906378852915, 60.93719453655147, 58.83913632185299,
    62.02220629731864, 63.38627106616552]
    sma_9 f64 [63955.122222222206, 64146.79999999998, 64319.61111111109,
    64531.95555555553, 64754.66666666664]
    ema_21 f64 [63739.39654092583, 63859.842309932574, 63952.55664539325,
    64076.33331399386, 64207.24846726715]
    ema_50 f64 [63775.75163360131, 63826.28294208753, 63867.59341494684,
    63924.31916338029, 63986.75370599283]
    ema_75 f64 [64014.017803250885, 64041.656808428495, 64063.710576627745,
    64096.615561453335, 64133.978309836144]
  >
  ```
"""

  import ExTalib.{Executer, Macros}
  @doc """
  Calculates the **Accumulation Bands (AccBands)** indicator.

  `TA-LIB` source name: `ACCBANDS`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `accbands_upperband`, type: `[:f64]`
    - `accbands_middleband`, type: `[:f64]`
    - `accbands_lowerband`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.accbands(df, nil ,nil, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 6]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          accbands_upperband_2 f64 [NaN, 13.785714285714285, 14.318181818181817]
          accbands_middleband_2 f64 [NaN, 3.5, 4.5]
          accbands_lowerband_2 f64 [NaN, -1.214285714285714, -0.6818181818181814]
        >}
  ## Example Using Series:
      iex> [high, low, close] = [Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.accbands(high, low, close, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 13.785714285714285, 14.318181818181817]
          >,
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 3.5, 4.5]
          >,
          #Explorer.Series<
            Polars[3]
            f64 [NaN, -1.214285714285714, -0.6818181818181814]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low, close] = [Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0], type: :f64)]
      iex> ExTalib.accbands(high, low, close, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 13.785714285714285, 14.318181818181817]
          >,
          #Nx.Tensor<
            f64[3]
            [NaN, 3.5, 4.5]
          >,
          #Nx.Tensor<
            f64[3]
            [NaN, -1.214285714285714, -0.6818181818181814]
          >
        }}

  """
  @doc type: :overlap_studies
  @spec accbands(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec accbands(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def accbands(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 20, options \\ [])
  def accbands(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df([:accbands, options, dataframe, time_period])
  def accbands(high, low, close, time_period, options), do: run([:accbands, options, high, low, close, time_period])
  @doc """
  A bang! version of `accbands/5`. It does **not** perform any validations.

  Please refer to `accbands/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `accbands/5`.
  """
  @doc type: :overlap_studies
  @spec accbands!(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec accbands!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def accbands!(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 20, options \\ [])
  def accbands!(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df!([:accbands, options, dataframe, time_period])
  def accbands!(high, low, close, time_period, options), do: run!([:accbands, options, high, low, close, time_period])


  @doc """
  Calculates the **Vector Trigonometric ACos** indicator.
  This function expects values between `-1.0` and `1.0`.

  `TA-LIB` source name: `ACOS`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `acos`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [0.3, 0.4, 0.5]})
      iex> ExTalib.acos(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 6]
          values f64 [0.3, 0.4, 0.5]
          acos f64 [1.2661036727794992, 1.1592794807274085, 1.0471975511965979]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([0.3, 0.4, 0.5], dtype: {:f, 64})
      iex> ExTalib.acos(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [1.2661036727794992, 1.1592794807274085, 1.0471975511965979]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([0.3, 0.4, 0.5], type: :f64)
      iex> ExTalib.acos(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [1.2661036727794992, 1.1592794807274085, 1.0471975511965979]
          >
        }}

  """
  @doc type: :math_transform
  @spec acos(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec acos(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def acos(values_or_dataframe, options \\ [])
  def acos(dataframe, options) when is_dataframe(dataframe), do: run_df([:acos, options, dataframe])
  def acos(values, options), do: run([:acos, options, values])
  @doc """
  A bang! version of `acos/2`. It does **not** perform any validations.

  Please refer to `acos/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `acos/2`.
  """
  @doc type: :math_transform
  @spec acos!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec acos!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def acos!(values_or_dataframe, options \\ [])
  def acos!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:acos, options, dataframe])
  def acos!(values, options), do: run!([:acos, options, values])


  @doc """
  Calculates the **Chaikin A/D Line** indicator.

  `TA-LIB` source name: `AD`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `ad`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0], volume: [10.0, 11.0, 12.0]})
      iex> ExTalib.ad(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          volume f64 [10.0, 11.0, 12.0]
          ad f64 [-3.333333333333333, -7.0, -11.0]
        >}
  ## Example Using Series:
      iex> [high, low, close, volume] = [Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64}), Explorer.Series.from_list([10.0, 11.0, 12.0], dtype: {:f, 64})]
      iex> ExTalib.ad(high, low, close, volume)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [-3.333333333333333, -7.0, -11.0]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low, close, volume] = [Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0], type: :f64), Nx.tensor([10.0, 11.0, 12.0], type: :f64)]
      iex> ExTalib.ad(high, low, close, volume)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [-3.333333333333333, -7.0, -11.0]
          >
        }}

  """
  @doc type: :volume_indicators
  @spec ad(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec ad(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), volume :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def ad(high_or_dataframe, low \\ nil, close \\ nil, volume \\ nil, options \\ [])
  def ad(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:ad, options, dataframe])
  def ad(high, low, close, volume, options), do: run([:ad, options, high, low, close, volume])
  @doc """
  A bang! version of `ad/5`. It does **not** perform any validations.

  Please refer to `ad/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `ad/5`.
  """
  @doc type: :volume_indicators
  @spec ad!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec ad!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), volume :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def ad!(high_or_dataframe, low \\ nil, close \\ nil, volume \\ nil, options \\ [])
  def ad!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:ad, options, dataframe])
  def ad!(high, low, close, volume, options), do: run!([:ad, options, high, low, close, volume])


  @doc """
  Calculates the **Vector Arithmetic Add** indicator.

  `TA-LIB` source name: `ADD`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values_a`, `values_b`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `add`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values_a: [5.0, 6.0, 7.0], values_b: [2.0, 3.0, 4.0]})
      iex> ExTalib.add(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 3]
          values_a f64 [5.0, 6.0, 7.0]
          values_b f64 [2.0, 3.0, 4.0]
          add f64 [7.0, 9.0, 11.0]
        >}
  ## Example Using Series:
      iex> [values_a, values_b] = [Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0])]
      iex> ExTalib.add(values_a, values_b)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [7.0, 9.0, 11.0]
          >
        }}

  ## Example Using Tensors:
      iex> [values_a, values_b] = [Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64)]
      iex> ExTalib.add(values_a, values_b)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [7.0, 9.0, 11.0]
          >
        }}

  """
  @doc type: :math_operators
  @spec add(dataframe :: Explorer.DataFrame.t(), nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec add(values_a :: Explorer.Series.t() | Nx.Tensor.t(), values_b :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def add(values_a_or_dataframe, values_b \\ nil, options \\ [])
  def add(dataframe, nil, options) when is_dataframe(dataframe), do: run_df([:add, options, dataframe])
  def add(values_a, values_b, options), do: run([:add, options, values_a, values_b])
  @doc """
  A bang! version of `add/3`. It does **not** perform any validations.

  Please refer to `add/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `add/3`.
  """
  @doc type: :math_operators
  @spec add!(dataframe :: Explorer.DataFrame.t(), nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec add!(values_a :: Explorer.Series.t() | Nx.Tensor.t(), values_b :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def add!(values_a_or_dataframe, values_b \\ nil, options \\ [])
  def add!(dataframe, nil, options) when is_dataframe(dataframe), do: run_df!([:add, options, dataframe])
  def add!(values_a, values_b, options), do: run!([:add, options, values_a, values_b])


  @doc """
  Calculates the **Chaikin A/D Oscillator** indicator.

  `TA-LIB` source name: `ADOSC`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`, `close`, `volume`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `adosc`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0], volume: [10.0, 11.0, 12.0]})
      iex> ExTalib.adosc(df, nil, nil, nil, 2, 3)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          volume f64 [10.0, 11.0, 12.0]
          adosc_2_3 f64 [NaN, NaN, -1.1759259259259274]
        >}
  ## Example Using Series:
      iex> [high, low, close, volume] = [Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64}), Explorer.Series.from_list([10.0, 11.0, 12.0], dtype: {:f, 64})]
      iex> ExTalib.adosc(high, low, close, volume, 2, 3)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, -1.1759259259259274]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low, close, volume] = [Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0], type: :f64), Nx.tensor([10.0, 11.0, 12.0], type: :f64)]
      iex> ExTalib.adosc(high, low, close, volume, 2, 3)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, -1.1759259259259274]
          >
        }}

  """
  @doc type: :volume_indicators
  @spec adosc(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, fast_period :: integer(), slow_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec adosc(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), volume :: Explorer.Series.t() | Nx.Tensor.t(), fast_period :: integer(), slow_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def adosc(high_or_dataframe, low \\ nil, close \\ nil, volume \\ nil, fast_period \\ 3, slow_period \\ 10, options \\ [])
  def adosc(dataframe, nil, nil, nil, fast_period, slow_period, options) when is_dataframe(dataframe), do: run_df([:adosc, options, dataframe, fast_period, slow_period])
  def adosc(high, low, close, volume, fast_period, slow_period, options), do: run([:adosc, options, high, low, close, volume, fast_period, slow_period])
  @doc """
  A bang! version of `adosc/7`. It does **not** perform any validations.

  Please refer to `adosc/7` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `adosc/7`.
  """
  @doc type: :volume_indicators
  @spec adosc!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, fast_period :: integer(), slow_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec adosc!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), volume :: Explorer.Series.t() | Nx.Tensor.t(), fast_period :: integer(), slow_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def adosc!(high_or_dataframe, low \\ nil, close \\ nil, volume \\ nil, fast_period \\ 3, slow_period \\ 10, options \\ [])
  def adosc!(dataframe, nil, nil, nil, fast_period, slow_period, options) when is_dataframe(dataframe), do: run_df!([:adosc, options, dataframe, fast_period, slow_period])
  def adosc!(high, low, close, volume, fast_period, slow_period, options), do: run!([:adosc, options, high, low, close, volume, fast_period, slow_period])


  @doc """
  Calculates the **Average Directional Movement Index** indicator.

  `TA-LIB` source name: `ADX`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `adx`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0, 8.0], low: [2.0, 3.0, 4.0, 5.0], close: [3.0, 4.0, 5.0, 6.0]})
      iex> ExTalib.adx(df, nil ,nil, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[4 x 4]
          close f64 [3.0, 4.0, 5.0, 6.0]
          high f64 [5.0, 6.0, 7.0, 8.0]
          low f64 [2.0, 3.0, 4.0, 5.0]
          adx_2 f64 [NaN, NaN, NaN, 100.0]
        >}
  ## Example Using Series:
      iex> [high, low, close] = [Explorer.Series.from_list([5.0, 6.0, 7.0, 8.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0, 5.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0, 6.0], dtype: {:f, 64})]
      iex> ExTalib.adx(high, low, close, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[4]
            f64 [NaN, NaN, NaN, 100.0]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low, close] = [Nx.tensor([5.0, 6.0, 7.0, 8.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0, 5.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0, 6.0], type: :f64)]
      iex> ExTalib.adx(high, low, close, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[4]
            [NaN, NaN, NaN, 100.0]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec adx(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec adx(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def adx(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 14, options \\ [])
  def adx(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df([:adx, options, dataframe, time_period])
  def adx(high, low, close, time_period, options), do: run([:adx, options, high, low, close, time_period])
  @doc """
  A bang! version of `adx/5`. It does **not** perform any validations.

  Please refer to `adx/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `adx/5`.
  """
  @doc type: :momentum_indicators
  @spec adx!(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec adx!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def adx!(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 14, options \\ [])
  def adx!(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df!([:adx, options, dataframe, time_period])
  def adx!(high, low, close, time_period, options), do: run!([:adx, options, high, low, close, time_period])


  @doc """
  Calculates the **Average Directional Movement Index Rating** indicator.

  `TA-LIB` source name: `ADXR`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `adxr`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0, 8.0, 9.0], low: [2.0, 3.0, 4.0, 5.0, 6.0], close: [3.0, 4.0, 5.0, 6.0, 7.0]})
      iex> ExTalib.adxr(df, nil ,nil, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[5 x 4]
          close f64 [3.0, 4.0, 5.0, 6.0, 7.0]
          high f64 [5.0, 6.0, 7.0, 8.0, 9.0]
          low f64 [2.0, 3.0, 4.0, 5.0, 6.0]
          adxr_2 f64 [NaN, NaN, NaN, NaN, 100.0]
        >}
  ## Example Using Series:
      iex> [high, low, close] = [Explorer.Series.from_list([5.0, 6.0, 7.0, 8.0, 9.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0, 6.0, 7.0], dtype: {:f, 64})]
      iex> ExTalib.adxr(high, low, close, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[5]
            f64 [NaN, NaN, NaN, NaN, 100.0]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low, close] = [Nx.tensor([5.0, 6.0, 7.0, 8.0, 9.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0, 5.0, 6.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0, 6.0, 7.0], type: :f64)]
      iex> ExTalib.adxr(high, low, close, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[5]
            [NaN, NaN, NaN, NaN, 100.0]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec adxr(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec adxr(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def adxr(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 14, options \\ [])
  def adxr(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df([:adxr, options, dataframe, time_period])
  def adxr(high, low, close, time_period, options), do: run([:adxr, options, high, low, close, time_period])
  @doc """
  A bang! version of `adxr/5`. It does **not** perform any validations.

  Please refer to `adxr/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `adxr/5`.
  """
  @doc type: :momentum_indicators
  @spec adxr!(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec adxr!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def adxr!(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 14, options \\ [])
  def adxr!(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df!([:adxr, options, dataframe, time_period])
  def adxr!(high, low, close, time_period, options), do: run!([:adxr, options, high, low, close, time_period])


  @doc """
  Calculates the **Absolute Price Oscillator** indicator.

  `TA-LIB` source name: `APO`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `apo`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.apo(df, 2, 3)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          apo_2_3 f64 [NaN, NaN, 0.5]
        >}
  ## Example Using Series:
      iex> values = Explorer.Series.from_list([3.0, 4.0, 5.0])
      iex> ExTalib.apo(values, 2, 3)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, 0.5]
          >
        }}

  ## Example Using Tensors:
      iex> values = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.apo(values, 2, 3)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, 0.5]
          >
        }}

  """
  @doc type: :volume_indicators
  @spec apo(dataframe :: Explorer.DataFrame.t(), fast_period :: integer(), slow_period :: integer(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec apo(values :: Explorer.Series.t() | Nx.Tensor.t(), fast_period :: integer(), slow_period :: integer(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def apo(values_or_dataframe, fast_period \\ 12, slow_period \\ 26, ma_type \\ :sma, options \\ [])
  def apo(dataframe, fast_period, slow_period, ma_type, options) when is_dataframe(dataframe), do: run_df([:apo, options, dataframe, fast_period, slow_period, ma_type])
  def apo(values, fast_period, slow_period, ma_type, options), do: run([:apo, options, values, fast_period, slow_period, ma_type])
  @doc """
  A bang! version of `apo/5`. It does **not** perform any validations.

  Please refer to `apo/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `apo/5`.
  """
  @doc type: :volume_indicators
  @spec apo!(dataframe :: Explorer.DataFrame.t(), fast_period :: integer(), slow_period :: integer(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec apo!(values :: Explorer.Series.t() | Nx.Tensor.t(), fast_period :: integer(), slow_period :: integer(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def apo!(values_or_dataframe, fast_period \\ 12, slow_period \\ 26, ma_type \\ :sma, options \\ [])
  def apo!(dataframe, fast_period, slow_period, ma_type, options) when is_dataframe(dataframe), do: run_df!([:apo, options, dataframe, fast_period, slow_period, ma_type])
  def apo!(values, fast_period, slow_period, ma_type, options), do: run!([:apo, options, values, fast_period, slow_period, ma_type])


  @doc """
  Calculates the **Aroon** indicator.

  `TA-LIB` source name: `AROON`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `aroon_down`, type: `[:f64]`
    - `aroon_up`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0, 8.0, 9.0], low: [2.0, 3.0, 4.0, 5.0, 6.0]})
      iex> ExTalib.aroon(df, nil, 2)
      #Explorer.DataFrame<
        Polars[5 x 4]
        high f64 [5.0, 6.0, 7.0, 8.0, 9.0]
        low f64 [2.0, 3.0, 4.0, 5.0, 6.0]
        aroon_down_2 f64 [NaN, NaN, 0.0, 0.0, 0.0]
        aroon_up_2 f64 [NaN, NaN, 100.0, 100.0, 100.0]
      >}
  ## Example Using Series:
      iex> [high, low] = [Explorer.Series.from_list([5.0, 6.0, 7.0, 8.0, 9.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0, 5.0, 6.0])]
      iex> ExTalib.aroon(high, low, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[5]
            f64 [NaN, NaN, 0.0, 0.0, 0.0]
          >,
          #Explorer.Series<
            Polars[5]
            f64 [NaN, NaN, 100.0, 100.0, 100.0]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low] = [Nx.tensor([5.0, 6.0, 7.0, 8.0, 9.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0, 5.0, 6.0], type: :f64)]
      iex> ExTalib.aroon(high, low, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[5]
            [NaN, NaN, 0.0, 0.0, 0.0]
          >,
          #Nx.Tensor<
            f64[5]
            [NaN, NaN, 100.0, 100.0, 100.0]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec aroon(dataframe :: Explorer.DataFrame.t(), nil, time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec aroon(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def aroon(high_or_dataframe, low \\ nil, time_period \\ 14, options \\ [])
  def aroon(dataframe, nil, time_period, options) when is_dataframe(dataframe), do: run_df([:aroon, options, dataframe, time_period])
  def aroon(high, low, time_period, options), do: run([:aroon, options, high, low, time_period])
  @doc """
  A bang! version of `aroon/4`. It does **not** perform any validations.

  Please refer to `aroon/4` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `aroon/4`.
  """
  @doc type: :momentum_indicators
  @spec aroon!(dataframe :: Explorer.DataFrame.t(), nil, time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec aroon!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def aroon!(high_or_dataframe, low \\ nil, time_period \\ 14, options \\ [])
  def aroon!(dataframe, nil, time_period, options) when is_dataframe(dataframe), do: run_df!([:aroon, options, dataframe, time_period])
  def aroon!(high, low, time_period, options), do: run!([:aroon, options, high, low, time_period])


  @doc """
  Calculates the **Aroon Oscillator** indicator.

  `TA-LIB` source name: `AROONOSC`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `aroonosc`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0, 8.0, 9.0], low: [2.0, 3.0, 4.0, 5.0, 6.0]})
      iex> ExTalib.aroonosc(df, nil, 2)
      #Explorer.DataFrame<
        Polars[5 x 3]
        high f64 [5.0, 6.0, 7.0, 8.0, 9.0]
        low f64 [2.0, 3.0, 4.0, 5.0, 6.0]
        aroonosc_2 f64 [NaN, NaN, 100.0, 100.0, 100.0]
      >}
  ## Example Using Series:
      iex> [high, low] = [Explorer.Series.from_list([5.0, 6.0, 7.0, 8.0, 9.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0, 5.0, 6.0])]
      iex> ExTalib.aroonosc(high, low, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[5]
            f64 [NaN, NaN, 100.0, 100.0, 100.0]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low] = [Nx.tensor([5.0, 6.0, 7.0, 8.0, 9.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0, 5.0, 6.0], type: :f64)]
      iex> ExTalib.aroonosc(high, low, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[5]
            [NaN, NaN, 100.0, 100.0, 100.0]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec aroonosc(dataframe :: Explorer.DataFrame.t(), nil, time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec aroonosc(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def aroonosc(high_or_dataframe, low \\ nil, time_period \\ 14, options \\ [])
  def aroonosc(dataframe, nil, time_period, options) when is_dataframe(dataframe), do: run_df([:aroonosc, options, dataframe, time_period])
  def aroonosc(high, low, time_period, options), do: run([:aroonosc, options, high, low, time_period])
  @doc """
  A bang! version of `aroonosc/4`. It does **not** perform any validations.

  Please refer to `aroonosc/4` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `aroonosc/4`.
  """
  @doc type: :momentum_indicators
  @spec aroonosc!(dataframe :: Explorer.DataFrame.t(), nil, time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec aroonosc!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def aroonosc!(high_or_dataframe, low \\ nil, time_period \\ 14, options \\ [])
  def aroonosc!(dataframe, nil, time_period, options) when is_dataframe(dataframe), do: run_df!([:aroonosc, options, dataframe, time_period])
  def aroonosc!(high, low, time_period, options), do: run!([:aroonosc, options, high, low, time_period])


  @doc """
  Calculates the **Vector Trigonometric ASin**.
  This function expects values between `-1.0` and `1.0`.

  `TA-LIB` source name: `ASIN`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `asin`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [0.3, 0.4, 0.5]})
      iex> ExTalib.asin(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [0.3, 0.4, 0.5]
          asin f64 [0.3046926540153975, 0.41151684606748806, 0.5235987755982989]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([0.3, 0.4, 0.5], dtype: {:f, 64})
      iex> ExTalib.asin(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [0.3046926540153975, 0.41151684606748806, 0.5235987755982989]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([0.3, 0.4, 0.5], type: :f64)
      iex> ExTalib.asin(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [0.3046926540153975, 0.41151684606748806, 0.5235987755982989]
          >
        }}

  """
  @doc type: :math_transform
  @spec asin(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec asin(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def asin(values_or_dataframe, options \\ [])
  def asin(dataframe, options) when is_dataframe(dataframe), do: run_df([:asin, options, dataframe])
  def asin(values, options), do: run([:asin, options, values])
  @doc """
  A bang! version of `asin/2`. It does **not** perform any validations.

  Please refer to `asin/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `asin/2`.
  """
  @doc type: :math_transform
  @spec asin!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec asin!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def asin!(values_or_dataframe, options \\ [])
  def asin!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:asin, options, dataframe])
  def asin!(values, options), do: run!([:asin, options, values])


  @doc """
  Calculates the **Vector Trigonometric ATan**.
  This function expects values between `-1.0` and `1.0`.

  `TA-LIB` source name: `ATAN`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `atan`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [0.3, 0.4, 0.5]})
      iex> ExTalib.atan(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [0.3, 0.4, 0.5]
          atan f64 [0.2914567944778671, 0.3805063771123649, 0.4636476090008061]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([0.3, 0.4, 0.5], dtype: {:f, 64})
      iex> ExTalib.atan(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [0.2914567944778671, 0.3805063771123649, 0.4636476090008061]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([0.3, 0.4, 0.5], type: :f64)
      iex> ExTalib.atan(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [0.2914567944778671, 0.3805063771123649, 0.4636476090008061]
          >
        }}

  """
  @doc type: :math_transform
  @spec atan(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec atan(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def atan(values_or_dataframe, options \\ [])
  def atan(dataframe, options) when is_dataframe(dataframe), do: run_df([:atan, options, dataframe])
  def atan(values, options), do: run([:atan, options, values])
  @doc """
  A bang! version of `atan/2`. It does **not** perform any validations.

  Please refer to `atan/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `atan/2`.
  """
  @doc type: :math_transform
  @spec atan!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec atan!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def atan!(values_or_dataframe, options \\ [])
  def atan!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:atan, options, dataframe])
  def atan!(values, options), do: run!([:atan, options, values])


  @doc """
  Calculates the **Average True Range** indicator.

  `TA-LIB` source name: `ATR`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `atr`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.atr(df, nil ,nil, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 6]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          atr_2 f64 [NaN, NaN, 3.0]
        >}
  ## Example Using Series:
      iex> [high, low, close] = [Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.atr(high, low, close, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, 3.0]
          >,
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 3.5, 4.5]
          >,
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, 3.0]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low, close] = [Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0], type: :f64)]
      iex> ExTalib.atr(high, low, close, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 13.785714285714285, 14.318181818181817]
          >,
          #Nx.Tensor<
            f64[3]
            [NaN, 3.5, 4.5]
          >,
          #Nx.Tensor<
            f64[3]
            [NaN, -1.214285714285714, -0.6818181818181814]
          >
        }}

  """
  @doc type: :volatility_indicators
  @spec atr(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec atr(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def atr(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 14, options \\ [])
  def atr(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df([:atr, options, dataframe, time_period])
  def atr(high, low, close, time_period, options), do: run([:atr, options, high, low, close, time_period])
  @doc """
  A bang! version of `atr/5`. It does **not** perform any validations.

  Please refer to `atr/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `atr/5`.
  """
  @doc type: :volatility_indicators
  @spec atr!(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec atr!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def atr!(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 14, options \\ [])
  def atr!(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df!([:atr, options, dataframe, time_period])
  def atr!(high, low, close, time_period, options), do: run!([:atr, options, high, low, close, time_period])


  @doc """
  Calculates the **Average Price** indicator.

  `TA-LIB` source name: `AVGPRICE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `avgprice`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.avgprice(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          avgprice f64 [3.5, 4.5, 5.5]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.avgprice(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [3.5, 4.5, 5.5]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.avgprice(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [3.5, 4.5, 5.5]
          >
        }}

  """
  @doc type: :price_transform
  @spec avgprice(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec avgprice(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def avgprice(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def avgprice(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:avgprice, options, dataframe])
  def avgprice(open, high, low, close,  options), do: run([:avgprice, options, open, high, low, close])
  @doc """
  A bang! version of `avgprice/5`. It does **not** perform any validations.

  Please refer to `avgprice/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `avgprice/5`.
  """
  @doc type: :price_transform
  @spec avgprice!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec avgprice!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def avgprice!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def avgprice!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:avgprice, options, dataframe])
  def avgprice!(open, high, low, close, options), do: run!([:avgprice, options, open, high, low, close])


  @doc """
  Calculates the **Average Deviation** indicator.

  `TA-LIB` source name: `AVGDEV`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `avgdev`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.avgdev(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          avgdev_2 f64 [NaN, 0.5, 0.5]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.avgdev(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 0.5, 0.5]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.avgdev(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 0.5, 0.5]
          >
        }}

  """
  @doc type: :price_transform
  @spec avgdev(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec avgdev(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def avgdev(values_or_dataframe, time_period \\ 30, options \\ [])
  def avgdev(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:avgdev, options, dataframe, time_period])
  def avgdev(values, time_period, options), do: run([:avgdev, options, values, time_period])
  @doc """
  A bang! version of `avgdev/3`. It does **not** perform any validations.

  Please refer to `avgdev/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `avgdev/3`.
  """
  @doc type: :price_transform
  @spec avgdev!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec avgdev!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def avgdev!(values_or_dataframe, time_period \\ 30, options \\ [])
  def avgdev!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:avgdev, options, dataframe, time_period])
  def avgdev!(values, time_period, options), do: run!([:avgdev, options, values, time_period])


  @doc """
  Calculates the **Bollinger Bands** indicator.

  `TA-LIB` source name: `BBANDS`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      *Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      *Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `bbands_upperband`, type: `[:f64]`
    - `bbands_middleband`, type: `[:f64]`
    - `bbands_lowerband`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.bbands(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 6]
          values f64 [3.0, 4.0, 5.0]
          bbands_upperband_2_2.0_2.0 f64 [NaN, 4.5, 5.5]
          bbands_middleband_2_2.0_2.0 f64 [NaN, 3.5, 4.5]
          bbands_lowerband_2_2.0_2.0 f64 [NaN, 2.5, 3.5]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.bbands(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 4.5, 5.5]
          >,
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 3.5, 4.5]
          >,
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 2.5, 3.5]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.bbands(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 4.5, 5.5]
          >,
          #Nx.Tensor<
            f64[3]
            [NaN, 3.5, 4.5]
          >,
          #Nx.Tensor<
            f64[3]
            [NaN, 2.5, 3.5]
          >
        }}

  """
  @doc type: :overlap_studies
  @spec bbands(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), deviations_up :: float(), deviations_down :: float(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec bbands(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), deviations_up :: float(), deviations_down :: float(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def bbands(values_or_dataframe, time_period \\ 5, deviations_up \\ 2.0, deviations_down \\ 2.0, ma_type \\ :sma, options \\ [])
  def bbands(dataframe, time_period, deviations_up, deviations_down, ma_type, options) when is_dataframe(dataframe), do: run_df([:bbands, options, dataframe, time_period, deviations_up, deviations_down, ma_type])
  def bbands(values, time_period, deviations_up, deviations_down, ma_type, options), do: run([:bbands, options, values, time_period, deviations_up, deviations_down, ma_type])
  @doc """
  A bang! version of `bbands/6`. It does **not** perform any validations.

  Please refer to `bbands/6` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `bbands/6`.
  """
  @doc type: :overlap_studies
  @spec bbands!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), deviations_up :: float(), deviations_down :: float(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec bbands!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), deviations_up :: float(), deviations_down :: float(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def bbands!(values_or_dataframe, time_period \\ 5, deviations_up \\ 2.0, deviations_down \\ 2.0, ma_type \\ :sma, options \\ [])
  def bbands!(dataframe, time_period, deviations_up, deviations_down, ma_type, options) when is_dataframe(dataframe), do: run_df!([:bbands, options, dataframe, time_period, deviations_up, deviations_down, ma_type])
  def bbands!(values, time_period, deviations_up, deviations_down, ma_type, options), do: run!([:bbands, options, values, time_period, deviations_up, deviations_down, ma_type])


  @doc """
  Calculates the **Beta** indicator.

  `TA-LIB` source name: `BETA`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values_a`, `values_b`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `beta`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values_a: [5.0, 6.0, 7.0], values_b: [2.0, 3.0, 4.0]})
      iex> ExTalib.beta(df, nil, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 3]
          values_a f64 [5.0, 6.0, 7.0]
          values_b f64 [2.0, 3.0, 4.0]
          beta_2 f64 [NaN, NaN, 5.000000000000075]
        >}
  ## Example Using Series:
      iex> [values_a, values_b] = [Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0])]
      iex> ExTalib.beta(values_a, values_b, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, 5.000000000000075]
          >
        }}

  ## Example Using Tensors:
      iex> [values_a, values_b] = [Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64)]
      iex> ExTalib.beta(values_a, values_b, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, 5.000000000000075]
          >
        }}

  """
  @doc type: :statistic_functions
  @spec beta(dataframe :: Explorer.DataFrame.t(), nil, time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec beta(values_a :: Explorer.Series.t() | Nx.Tensor.t(), values_b :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(),options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def beta(values_a_or_dataframe, values_b \\ nil, time_period \\ 5, options \\ [])
  def beta(dataframe, nil, time_period, options) when is_dataframe(dataframe), do: run_df([:beta, options, dataframe, time_period])
  def beta(values_a, values_b, time_period, options), do: run([:beta, options, values_a, values_b, time_period])
  @doc """
  A bang! version of `beta/4`. It does **not** perform any validations.

  Please refer to `beta/4` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `beta/4`.
  """
  @doc type: :statistic_functions
  @spec beta!(dataframe :: Explorer.DataFrame.t(), nil, time_period :: integer(),options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec beta!(values_a :: Explorer.Series.t() | Nx.Tensor.t(), values_b :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(),options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def beta!(values_a_or_dataframe, values_b \\ nil, time_period \\ 5, options \\ [])
  def beta!(dataframe, nil, time_period, options) when is_dataframe(dataframe), do: run_df!([:beta, options, dataframe, time_period])
  def beta!(values_a, values_b, time_period, options), do: run!([:beta, options, values_a, values_b, time_period])


  @doc """
  Calculates the **Balance Of Power** indicator.

  `TA-LIB` source name: `BOP`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `bop`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.bop(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          bop f64 [-0.3333333333333333, -0.3333333333333333, -0.3333333333333333]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.bop(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [-0.3333333333333333, -0.3333333333333333, -0.3333333333333333]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.bop(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [-0.3333333333333333, -0.3333333333333333, -0.3333333333333333]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec bop(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec bop(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def bop(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def bop(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:bop, options, dataframe])
  def bop(open, high, low, close,  options), do: run([:bop, options, open, high, low, close])
  @doc """
  A bang! version of `bop/5`. It does **not** perform any validations.

  Please refer to `bop/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `bop/5`.
  """
  @doc type: :momentum_indicators
  @spec bop!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec bop!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def bop!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def bop!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:bop, options, dataframe])
  def bop!(open, high, low, close, options), do: run!([:bop, options, open, high, low, close])


  @doc """
  Calculates the **Commodity Channel Index** indicator.

  `TA-LIB` source name: `CCI`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cci`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cci(df, nil ,nil, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 6]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          cci_2 f64 [NaN, 66.6666666666667, 66.66666666666667]
        >}
  ## Example Using Series:
      iex> [high, low, close] = [Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cci(high, low, close, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 66.6666666666667, 66.66666666666667]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low, close] = [Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0], type: :f64)]
      iex> ExTalib.cci(high, low, close, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 66.6666666666667, 66.66666666666667]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec cci(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cci(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cci(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 14, options \\ [])
  def cci(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df([:cci, options, dataframe, time_period])
  def cci(high, low, close, time_period, options), do: run([:cci, options, high, low, close, time_period])
  @doc """
  A bang! version of `cci/5`. It does **not** perform any validations.

  Please refer to `cci/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cci/5`.
  """
  @doc type: :momentum_indicators
  @spec cci!(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cci!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cci!(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 14, options \\ [])
  def cci!(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df!([:cci, options, dataframe, time_period])
  def cci!(high, low, close, time_period, options), do: run!([:cci, options, high, low, close, time_period])


  @doc """
  Calculates the **Two Crows** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDL2CROWS`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdl2crows`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdl2crows(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdl2crows f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdl2crows(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdl2crows(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdl2crows(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdl2crows(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdl2crows(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdl2crows(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdl2crows, options, dataframe])
  def cdl2crows(open, high, low, close,  options), do: run([:cdl2crows, options, open, high, low, close])
  @doc """
  A bang! version of `cdl2crows/5`. It does **not** perform any validations.

  Please refer to `cdl2crows/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdl2crows/5`.
  """
  @doc type: :pattern_recognition
  @spec cdl2crows!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdl2crows!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdl2crows!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdl2crows!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdl2crows, options, dataframe])
  def cdl2crows!(open, high, low, close, options), do: run!([:cdl2crows, options, open, high, low, close])


  @doc """
  Calculates the **Three Black Crows** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDL3BLACKCROWS`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdl3blackcrows`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdl3blackcrows(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdl3blackcrows f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdl3blackcrows(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdl3blackcrows(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdl3blackcrows(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdl3blackcrows(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdl3blackcrows(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdl3blackcrows(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdl3blackcrows, options, dataframe])
  def cdl3blackcrows(open, high, low, close,  options), do: run([:cdl3blackcrows, options, open, high, low, close])
  @doc """
  A bang! version of `cdl3blackcrows/5`. It does **not** perform any validations.

  Please refer to `cdl3blackcrows/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdl3blackcrows/5`.
  """
  @doc type: :pattern_recognition
  @spec cdl3blackcrows!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdl3blackcrows!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdl3blackcrows!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdl3blackcrows!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdl3blackcrows, options, dataframe])
  def cdl3blackcrows!(open, high, low, close, options), do: run!([:cdl3blackcrows, options, open, high, low, close])


  @doc """
  Calculates the **Three Inside Up/Down** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDL3INSIDE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdl3inside`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdl3inside(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdl3inside f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdl3inside(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdl3inside(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdl3inside(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdl3inside(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdl3inside(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdl3inside(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdl3inside, options, dataframe])
  def cdl3inside(open, high, low, close,  options), do: run([:cdl3inside, options, open, high, low, close])
  @doc """
  A bang! version of `cdl3inside/5`. It does **not** perform any validations.

  Please refer to `cdl3inside/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdl3inside/5`.
  """
  @doc type: :pattern_recognition
  @spec cdl3inside!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdl3inside!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdl3inside!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdl3inside!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdl3inside, options, dataframe])
  def cdl3inside!(open, high, low, close, options), do: run!([:cdl3inside, options, open, high, low, close])


  @doc """
  Calculates the **Three-Line Strike** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDL3LINESTRIKE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdl3linestrike`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdl3linestrike(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdl3linestrike f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdl3linestrike(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdl3linestrike(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdl3linestrike(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdl3linestrike(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdl3linestrike(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdl3linestrike(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdl3linestrike, options, dataframe])
  def cdl3linestrike(open, high, low, close,  options), do: run([:cdl3linestrike, options, open, high, low, close])
  @doc """
  A bang! version of `cdl3linestrike/5`. It does **not** perform any validations.

  Please refer to `cdl3linestrike/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdl3linestrike/5`.
  """
  @doc type: :pattern_recognition
  @spec cdl3linestrike!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdl3linestrike!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdl3linestrike!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdl3linestrike!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdl3linestrike, options, dataframe])
  def cdl3linestrike!(open, high, low, close, options), do: run!([:cdl3linestrike, options, open, high, low, close])


  @doc """
  Calculates the **Three Outside Up/Down** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDL3OUTSIDE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdl3outside`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdl3outside(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdl3outside f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdl3outside(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdl3outside(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdl3outside(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdl3outside(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdl3outside(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdl3outside(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdl3outside, options, dataframe])
  def cdl3outside(open, high, low, close,  options), do: run([:cdl3outside, options, open, high, low, close])
  @doc """
  A bang! version of `cdl3outside/5`. It does **not** perform any validations.

  Please refer to `cdl3outside/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdl3outside/5`.
  """
  @doc type: :pattern_recognition
  @spec cdl3outside!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdl3outside!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdl3outside!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdl3outside!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdl3outside, options, dataframe])
  def cdl3outside!(open, high, low, close, options), do: run!([:cdl3outside, options, open, high, low, close])


  @doc """
  Calculates the **Three Stars In The South** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDL3STARSINSOUTH`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdl3starsinsouth`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdl3starsinsouth(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdl3starsinsouth f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdl3starsinsouth(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdl3starsinsouth(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdl3starsinsouth(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdl3starsinsouth(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdl3starsinsouth(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdl3starsinsouth(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdl3starsinsouth, options, dataframe])
  def cdl3starsinsouth(open, high, low, close,  options), do: run([:cdl3starsinsouth, options, open, high, low, close])
  @doc """
  A bang! version of `cdl3starsinsouth/5`. It does **not** perform any validations.

  Please refer to `cdl3starsinsouth/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdl3starsinsouth/5`.
  """
  @doc type: :pattern_recognition
  @spec cdl3starsinsouth!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdl3starsinsouth!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdl3starsinsouth!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdl3starsinsouth!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdl3starsinsouth, options, dataframe])
  def cdl3starsinsouth!(open, high, low, close, options), do: run!([:cdl3starsinsouth, options, open, high, low, close])


  @doc """
  Calculates the **Three Advancing White Soldiers** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDL3WHITESOLDIERS`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdl3whitesoldiers`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdl3whitesoldiers(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdl3whitesoldiers f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdl3whitesoldiers(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdl3whitesoldiers(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdl3whitesoldiers(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdl3whitesoldiers(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdl3whitesoldiers(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdl3whitesoldiers(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdl3whitesoldiers, options, dataframe])
  def cdl3whitesoldiers(open, high, low, close,  options), do: run([:cdl3whitesoldiers, options, open, high, low, close])
  @doc """
  A bang! version of `cdl3whitesoldiers/5`. It does **not** perform any validations.

  Please refer to `cdl3whitesoldiers/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdl3whitesoldiers/5`.
  """
  @doc type: :pattern_recognition
  @spec cdl3whitesoldiers!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdl3whitesoldiers!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdl3whitesoldiers!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdl3whitesoldiers!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdl3whitesoldiers, options, dataframe])
  def cdl3whitesoldiers!(open, high, low, close, options), do: run!([:cdl3whitesoldiers, options, open, high, low, close])


  @doc """
  Calculates the **Abandoned Baby** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.
  `penetration`: Percentage of penetration of a candle within another candle

  `TA-LIB` source name: `CDLABANDONEDBABY`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlabandonedbaby`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlabandonedbaby(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlabandonedbaby_0.3 f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlabandonedbaby(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlabandonedbaby(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlabandonedbaby(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, penetration :: float(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlabandonedbaby(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), penetration :: float(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlabandonedbaby(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, penetration \\ 0.3, options \\ [])
  def cdlabandonedbaby(dataframe, nil, nil, nil, penetration, options) when is_dataframe(dataframe), do: run_df([:cdlabandonedbaby, options, dataframe, penetration])
  def cdlabandonedbaby(open, high, low, close, penetration, options), do: run([:cdlabandonedbaby, options, open, high, low, close, penetration])
  @doc """
  A bang! version of `cdlabandonedbaby/6`. It does **not** perform any validations.

  Please refer to `cdlabandonedbaby/6` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlabandonedbaby/6`.
  """
  @doc type: :pattern_recognition
  @spec cdlabandonedbaby!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, penetration :: float(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlabandonedbaby!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), penetration :: float(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlabandonedbaby!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, penetration \\ 0.3, options \\ [])
  def cdlabandonedbaby!(dataframe, nil, nil, nil, penetration, options) when is_dataframe(dataframe), do: run_df!([:cdlabandonedbaby, options, dataframe, penetration])
  def cdlabandonedbaby!(open, high, low, close, penetration, options), do: run!([:cdlabandonedbaby, options, open, high, low, close, penetration])


  @doc """
  Calculates the **Advance Block** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLADVANCEBLOCK`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdladvanceblock`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdladvanceblock(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdladvanceblock f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdladvanceblock(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdladvanceblock(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdladvanceblock(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdladvanceblock(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdladvanceblock(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdladvanceblock(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdladvanceblock, options, dataframe])
  def cdladvanceblock(open, high, low, close,  options), do: run([:cdladvanceblock, options, open, high, low, close])
  @doc """
  A bang! version of `cdladvanceblock/5`. It does **not** perform any validations.

  Please refer to `cdladvanceblock/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdladvanceblock/5`.
  """
  @doc type: :pattern_recognition
  @spec cdladvanceblock!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdladvanceblock!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdladvanceblock!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdladvanceblock!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdladvanceblock, options, dataframe])
  def cdladvanceblock!(open, high, low, close, options), do: run!([:cdladvanceblock, options, open, high, low, close])


  @doc """
  Calculates the **Belt-hold** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLBELTHOLD`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlbelthold`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlbelthold(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlbelthold f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlbelthold(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlbelthold(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlbelthold(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlbelthold(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlbelthold(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlbelthold(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlbelthold, options, dataframe])
  def cdlbelthold(open, high, low, close,  options), do: run([:cdlbelthold, options, open, high, low, close])
  @doc """
  A bang! version of `cdlbelthold/5`. It does **not** perform any validations.

  Please refer to `cdlbelthold/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlbelthold/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlbelthold!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlbelthold!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlbelthold!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlbelthold!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlbelthold, options, dataframe])
  def cdlbelthold!(open, high, low, close, options), do: run!([:cdlbelthold, options, open, high, low, close])


  @doc """
  Calculates the **Breakaway** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLBREAKAWAY`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlbreakaway`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlbreakaway(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlbreakaway f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlbreakaway(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlbreakaway(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlbreakaway(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlbreakaway(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlbreakaway(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlbreakaway(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlbreakaway, options, dataframe])
  def cdlbreakaway(open, high, low, close,  options), do: run([:cdlbreakaway, options, open, high, low, close])
  @doc """
  A bang! version of `cdlbreakaway/5`. It does **not** perform any validations.

  Please refer to `cdlbreakaway/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlbreakaway/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlbreakaway!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlbreakaway!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlbreakaway!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlbreakaway!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlbreakaway, options, dataframe])
  def cdlbreakaway!(open, high, low, close, options), do: run!([:cdlbreakaway, options, open, high, low, close])


  @doc """
  Calculates the **Closing Marubozu** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLCLOSINGMARUBOZU`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlclosingmarubozu`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlclosingmarubozu(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlclosingmarubozu f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlclosingmarubozu(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlclosingmarubozu(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlclosingmarubozu(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlclosingmarubozu(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlclosingmarubozu(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlclosingmarubozu(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlclosingmarubozu, options, dataframe])
  def cdlclosingmarubozu(open, high, low, close,  options), do: run([:cdlclosingmarubozu, options, open, high, low, close])
  @doc """
  A bang! version of `cdlclosingmarubozu/5`. It does **not** perform any validations.

  Please refer to `cdlclosingmarubozu/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlclosingmarubozu/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlclosingmarubozu!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlclosingmarubozu!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlclosingmarubozu!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlclosingmarubozu!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlclosingmarubozu, options, dataframe])
  def cdlclosingmarubozu!(open, high, low, close, options), do: run!([:cdlclosingmarubozu, options, open, high, low, close])


  @doc """
  Calculates the **Concealing Baby Swallow** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLCONCEALBABYSWALL`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlconcealbabyswall`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlconcealbabyswall(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlconcealbabyswall f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlconcealbabyswall(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlconcealbabyswall(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlconcealbabyswall(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlconcealbabyswall(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlconcealbabyswall(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlconcealbabyswall(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlconcealbabyswall, options, dataframe])
  def cdlconcealbabyswall(open, high, low, close,  options), do: run([:cdlconcealbabyswall, options, open, high, low, close])
  @doc """
  A bang! version of `cdlconcealbabyswall/5`. It does **not** perform any validations.

  Please refer to `cdlconcealbabyswall/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlconcealbabyswall/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlconcealbabyswall!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlconcealbabyswall!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlconcealbabyswall!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlconcealbabyswall!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlconcealbabyswall, options, dataframe])
  def cdlconcealbabyswall!(open, high, low, close, options), do: run!([:cdlconcealbabyswall, options, open, high, low, close])


  @doc """
  Calculates the **Counterattack** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLCOUNTERATTACK`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlcounterattack`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlcounterattack(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlcounterattack f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlcounterattack(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlcounterattack(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlcounterattack(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlcounterattack(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlcounterattack(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlcounterattack(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlcounterattack, options, dataframe])
  def cdlcounterattack(open, high, low, close,  options), do: run([:cdlcounterattack, options, open, high, low, close])
  @doc """
  A bang! version of `cdlcounterattack/5`. It does **not** perform any validations.

  Please refer to `cdlcounterattack/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlcounterattack/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlcounterattack!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlcounterattack!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlcounterattack!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlcounterattack!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlcounterattack, options, dataframe])
  def cdlcounterattack!(open, high, low, close, options), do: run!([:cdlcounterattack, options, open, high, low, close])


  @doc """
  Calculates the **Dark Cloud Cover** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.
  `penetration`: Percentage of penetration of a candle within another candle

  `TA-LIB` source name: `CDLDARKCLOUDCOVER`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdldarkcloudcover`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdldarkcloudcover(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdldarkcloudcover_0.3 f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdldarkcloudcover(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdldarkcloudcover(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdldarkcloudcover(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, penetration :: float(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdldarkcloudcover(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), penetration :: float(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdldarkcloudcover(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, penetration \\ 0.3, options \\ [])
  def cdldarkcloudcover(dataframe, nil, nil, nil, penetration, options) when is_dataframe(dataframe), do: run_df([:cdldarkcloudcover, options, dataframe, penetration])
  def cdldarkcloudcover(open, high, low, close, penetration, options), do: run([:cdldarkcloudcover, options, open, high, low, close, penetration])
  @doc """
  A bang! version of `cdldarkcloudcover/6`. It does **not** perform any validations.

  Please refer to `cdldarkcloudcover/6` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdldarkcloudcover/6`.
  """
  @doc type: :pattern_recognition
  @spec cdldarkcloudcover!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, penetration :: float(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdldarkcloudcover!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), penetration :: float(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdldarkcloudcover!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, penetration \\ 0.3, options \\ [])
  def cdldarkcloudcover!(dataframe, nil, nil, nil, penetration, options) when is_dataframe(dataframe), do: run_df!([:cdldarkcloudcover, options, dataframe, penetration])
  def cdldarkcloudcover!(open, high, low, close, penetration, options), do: run!([:cdldarkcloudcover, options, open, high, low, close, penetration])


  @doc """
  Calculates the **Doji** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLDOJI`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdldoji`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdldoji(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdldoji f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdldoji(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdldoji(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdldoji(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdldoji(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdldoji(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdldoji(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdldoji, options, dataframe])
  def cdldoji(open, high, low, close,  options), do: run([:cdldoji, options, open, high, low, close])
  @doc """
  A bang! version of `cdldoji/5`. It does **not** perform any validations.

  Please refer to `cdldoji/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdldoji/5`.
  """
  @doc type: :pattern_recognition
  @spec cdldoji!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdldoji!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdldoji!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdldoji!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdldoji, options, dataframe])
  def cdldoji!(open, high, low, close, options), do: run!([:cdldoji, options, open, high, low, close])


  @doc """
  Calculates the **Doji Star** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLDOJISTAR`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdldojistar`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdldojistar(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdldojistar f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdldojistar(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdldojistar(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdldojistar(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdldojistar(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdldojistar(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdldojistar(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdldojistar, options, dataframe])
  def cdldojistar(open, high, low, close,  options), do: run([:cdldojistar, options, open, high, low, close])
  @doc """
  A bang! version of `cdldojistar/5`. It does **not** perform any validations.

  Please refer to `cdldojistar/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdldojistar/5`.
  """
  @doc type: :pattern_recognition
  @spec cdldojistar!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdldojistar!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdldojistar!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdldojistar!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdldojistar, options, dataframe])
  def cdldojistar!(open, high, low, close, options), do: run!([:cdldojistar, options, open, high, low, close])


  @doc """
  Calculates the **Dragonfly Doji** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLDRAGONFLYDOJI`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdldragonflydoji`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdldragonflydoji(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdldragonflydoji f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdldragonflydoji(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdldragonflydoji(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdldragonflydoji(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdldragonflydoji(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdldragonflydoji(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdldragonflydoji(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdldragonflydoji, options, dataframe])
  def cdldragonflydoji(open, high, low, close,  options), do: run([:cdldragonflydoji, options, open, high, low, close])
  @doc """
  A bang! version of `cdldragonflydoji/5`. It does **not** perform any validations.

  Please refer to `cdldragonflydoji/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdldragonflydoji/5`.
  """
  @doc type: :pattern_recognition
  @spec cdldragonflydoji!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdldragonflydoji!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdldragonflydoji!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdldragonflydoji!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdldragonflydoji, options, dataframe])
  def cdldragonflydoji!(open, high, low, close, options), do: run!([:cdldragonflydoji, options, open, high, low, close])


  @doc """
  Calculates the **Engulfing Pattern** candle pattern indicator.

  `TA-LIB` source name: `CDLENGULFING`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlengulfing`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlengulfing(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlengulfing f64 [NaN, NaN, 0.0]]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlengulfing(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, 0.0]]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlengulfing(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, 0.0]]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlengulfing(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlengulfing(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlengulfing(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlengulfing(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlengulfing, options, dataframe])
  def cdlengulfing(open, high, low, close,  options), do: run([:cdlengulfing, options, open, high, low, close])
  @doc """
  A bang! version of `cdlengulfing/5`. It does **not** perform any validations.

  Please refer to `cdlengulfing/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlengulfing/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlengulfing!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlengulfing!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlengulfing!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlengulfing!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlengulfing, options, dataframe])
  def cdlengulfing!(open, high, low, close, options), do: run!([:cdlengulfing, options, open, high, low, close])


  @doc """
  Calculates the **Evening Doji Star** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.
  `penetration`: Percentage of penetration of a candle within another candle

  `TA-LIB` source name: `CDLEVENINGDOJISTAR`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdleveningdojistar`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdleveningdojistar(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdleveningdojistar_0.3 f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdleveningdojistar(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdleveningdojistar(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdleveningdojistar(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, penetration :: float(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdleveningdojistar(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), penetration :: float(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdleveningdojistar(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, penetration \\ 0.3, options \\ [])
  def cdleveningdojistar(dataframe, nil, nil, nil, penetration, options) when is_dataframe(dataframe), do: run_df([:cdleveningdojistar, options, dataframe, penetration])
  def cdleveningdojistar(open, high, low, close, penetration, options), do: run([:cdleveningdojistar, options, open, high, low, close, penetration])
  @doc """
  A bang! version of `cdleveningdojistar/6`. It does **not** perform any validations.

  Please refer to `cdleveningdojistar/6` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdleveningdojistar/6`.
  """
  @doc type: :pattern_recognition
  @spec cdleveningdojistar!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, penetration :: float(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdleveningdojistar!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), penetration :: float(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdleveningdojistar!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, penetration \\ 0.3, options \\ [])
  def cdleveningdojistar!(dataframe, nil, nil, nil, penetration, options) when is_dataframe(dataframe), do: run_df!([:cdleveningdojistar, options, dataframe, penetration])
  def cdleveningdojistar!(open, high, low, close, penetration, options), do: run!([:cdleveningdojistar, options, open, high, low, close, penetration])


  @doc """
  Calculates the **Evening Star** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.
  `penetration`: Percentage of penetration of a candle within another candle

  `TA-LIB` source name: `CDLEVENINGSTAR`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdleveningstar`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdleveningstar(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdleveningstar_0.3 f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdleveningstar(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdleveningstar(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdleveningstar(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, penetration :: float(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdleveningstar(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), penetration :: float(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdleveningstar(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, penetration \\ 0.3, options \\ [])
  def cdleveningstar(dataframe, nil, nil, nil, penetration, options) when is_dataframe(dataframe), do: run_df([:cdleveningstar, options, dataframe, penetration])
  def cdleveningstar(open, high, low, close, penetration, options), do: run([:cdleveningstar, options, open, high, low, close, penetration])
  @doc """
  A bang! version of `cdleveningstar/6`. It does **not** perform any validations.

  Please refer to `cdleveningstar/6` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdleveningstar/6`.
  """
  @doc type: :pattern_recognition
  @spec cdleveningstar!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, penetration :: float(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdleveningstar!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), penetration :: float(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdleveningstar!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, penetration \\ 0.3, options \\ [])
  def cdleveningstar!(dataframe, nil, nil, nil, penetration, options) when is_dataframe(dataframe), do: run_df!([:cdleveningstar, options, dataframe, penetration])
  def cdleveningstar!(open, high, low, close, penetration, options), do: run!([:cdleveningstar, options, open, high, low, close, penetration])


  @doc """
  Calculates the **Up/Down-gap side-by-side white lines** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLGAPSIDESIDEWHITE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlgapsidesidewhite`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlgapsidesidewhite(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlgapsidesidewhite f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlgapsidesidewhite(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlgapsidesidewhite(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlgapsidesidewhite(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlgapsidesidewhite(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlgapsidesidewhite(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlgapsidesidewhite(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlgapsidesidewhite, options, dataframe])
  def cdlgapsidesidewhite(open, high, low, close,  options), do: run([:cdlgapsidesidewhite, options, open, high, low, close])
  @doc """
  A bang! version of `cdlgapsidesidewhite/5`. It does **not** perform any validations.

  Please refer to `cdlgapsidesidewhite/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlgapsidesidewhite/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlgapsidesidewhite!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlgapsidesidewhite!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlgapsidesidewhite!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlgapsidesidewhite!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlgapsidesidewhite, options, dataframe])
  def cdlgapsidesidewhite!(open, high, low, close, options), do: run!([:cdlgapsidesidewhite, options, open, high, low, close])


  @doc """
  Calculates the **Gravestone Doji** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLGRAVESTONEDOJI`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlgravestonedoji`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlgravestonedoji(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlgravestonedoji f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlgravestonedoji(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlgravestonedoji(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlgravestonedoji(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlgravestonedoji(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlgravestonedoji(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlgravestonedoji(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlgravestonedoji, options, dataframe])
  def cdlgravestonedoji(open, high, low, close,  options), do: run([:cdlgravestonedoji, options, open, high, low, close])
  @doc """
  A bang! version of `cdlgravestonedoji/5`. It does **not** perform any validations.

  Please refer to `cdlgravestonedoji/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlgravestonedoji/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlgravestonedoji!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlgravestonedoji!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlgravestonedoji!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlgravestonedoji!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlgravestonedoji, options, dataframe])
  def cdlgravestonedoji!(open, high, low, close, options), do: run!([:cdlgravestonedoji, options, open, high, low, close])


  @doc """
  Calculates the **Hammer** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLHAMMER`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlhammer`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlhammer(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlhammer f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlhammer(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlhammer(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlhammer(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlhammer(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlhammer(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlhammer(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlhammer, options, dataframe])
  def cdlhammer(open, high, low, close,  options), do: run([:cdlhammer, options, open, high, low, close])
  @doc """
  A bang! version of `cdlhammer/5`. It does **not** perform any validations.

  Please refer to `cdlhammer/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlhammer/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlhammer!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlhammer!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlhammer!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlhammer!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlhammer, options, dataframe])
  def cdlhammer!(open, high, low, close, options), do: run!([:cdlhammer, options, open, high, low, close])


  @doc """
  Calculates the **Hanging Man** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLHANGINGMAN`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlhangingman`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlhangingman(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlhangingman f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlhangingman(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlhangingman(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlhangingman(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlhangingman(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlhangingman(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlhangingman(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlhangingman, options, dataframe])
  def cdlhangingman(open, high, low, close,  options), do: run([:cdlhangingman, options, open, high, low, close])
  @doc """
  A bang! version of `cdlhangingman/5`. It does **not** perform any validations.

  Please refer to `cdlhangingman/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlhangingman/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlhangingman!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlhangingman!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlhangingman!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlhangingman!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlhangingman, options, dataframe])
  def cdlhangingman!(open, high, low, close, options), do: run!([:cdlhangingman, options, open, high, low, close])


  @doc """
  Calculates the **Harami Pattern** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLHARAMI`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlharami`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlharami(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlharami f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlharami(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlharami(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlharami(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlharami(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlharami(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlharami(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlharami, options, dataframe])
  def cdlharami(open, high, low, close,  options), do: run([:cdlharami, options, open, high, low, close])
  @doc """
  A bang! version of `cdlharami/5`. It does **not** perform any validations.

  Please refer to `cdlharami/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlharami/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlharami!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlharami!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlharami!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlharami!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlharami, options, dataframe])
  def cdlharami!(open, high, low, close, options), do: run!([:cdlharami, options, open, high, low, close])


  @doc """
  Calculates the **Harami Cross Pattern** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLHARAMICROSS`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlharamicross`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlharamicross(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlharamicross f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlharamicross(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlharamicross(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlharamicross(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlharamicross(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlharamicross(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlharamicross(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlharamicross, options, dataframe])
  def cdlharamicross(open, high, low, close,  options), do: run([:cdlharamicross, options, open, high, low, close])
  @doc """
  A bang! version of `cdlharamicross/5`. It does **not** perform any validations.

  Please refer to `cdlharamicross/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlharamicross/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlharamicross!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlharamicross!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlharamicross!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlharamicross!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlharamicross, options, dataframe])
  def cdlharamicross!(open, high, low, close, options), do: run!([:cdlharamicross, options, open, high, low, close])


  @doc """
  Calculates the **High-Wave Candle** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLHIGHWAVE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlhighwave`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlhighwave(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlhighwave f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlhighwave(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlhighwave(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlhighwave(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlhighwave(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlhighwave(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlhighwave(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlhighwave, options, dataframe])
  def cdlhighwave(open, high, low, close,  options), do: run([:cdlhighwave, options, open, high, low, close])
  @doc """
  A bang! version of `cdlhighwave/5`. It does **not** perform any validations.

  Please refer to `cdlhighwave/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlhighwave/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlhighwave!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlhighwave!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlhighwave!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlhighwave!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlhighwave, options, dataframe])
  def cdlhighwave!(open, high, low, close, options), do: run!([:cdlhighwave, options, open, high, low, close])


  @doc """
  Calculates the **Hikkake Pattern** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLHIKKAKE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlhikkake`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlhikkake(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlhikkake f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlhikkake(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlhikkake(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlhikkake(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlhikkake(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlhikkake(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlhikkake(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlhikkake, options, dataframe])
  def cdlhikkake(open, high, low, close,  options), do: run([:cdlhikkake, options, open, high, low, close])
  @doc """
  A bang! version of `cdlhikkake/5`. It does **not** perform any validations.

  Please refer to `cdlhikkake/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlhikkake/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlhikkake!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlhikkake!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlhikkake!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlhikkake!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlhikkake, options, dataframe])
  def cdlhikkake!(open, high, low, close, options), do: run!([:cdlhikkake, options, open, high, low, close])


  @doc """
  Calculates the **Modified Hikkake Pattern** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLHIKKAKEMOD`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlhikkakemod`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlhikkakemod(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlhikkakemod f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlhikkakemod(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlhikkakemod(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlhikkakemod(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlhikkakemod(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlhikkakemod(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlhikkakemod(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlhikkakemod, options, dataframe])
  def cdlhikkakemod(open, high, low, close,  options), do: run([:cdlhikkakemod, options, open, high, low, close])
  @doc """
  A bang! version of `cdlhikkakemod/5`. It does **not** perform any validations.

  Please refer to `cdlhikkakemod/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlhikkakemod/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlhikkakemod!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlhikkakemod!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlhikkakemod!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlhikkakemod!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlhikkakemod, options, dataframe])
  def cdlhikkakemod!(open, high, low, close, options), do: run!([:cdlhikkakemod, options, open, high, low, close])


  @doc """
  Calculates the **Homing Pigeon** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLHOMINGPIGEON`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlhomingpigeon`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlhomingpigeon(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlhomingpigeon f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlhomingpigeon(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlhomingpigeon(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlhomingpigeon(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlhomingpigeon(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlhomingpigeon(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlhomingpigeon(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlhomingpigeon, options, dataframe])
  def cdlhomingpigeon(open, high, low, close,  options), do: run([:cdlhomingpigeon, options, open, high, low, close])
  @doc """
  A bang! version of `cdlhomingpigeon/5`. It does **not** perform any validations.

  Please refer to `cdlhomingpigeon/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlhomingpigeon/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlhomingpigeon!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlhomingpigeon!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlhomingpigeon!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlhomingpigeon!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlhomingpigeon, options, dataframe])
  def cdlhomingpigeon!(open, high, low, close, options), do: run!([:cdlhomingpigeon, options, open, high, low, close])


  @doc """
  Calculates the **Identical Three Crows** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLIDENTICAL3CROWS`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlidentical3crows`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlidentical3crows(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlidentical3crows f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlidentical3crows(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlidentical3crows(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlidentical3crows(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlidentical3crows(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlidentical3crows(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlidentical3crows(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlidentical3crows, options, dataframe])
  def cdlidentical3crows(open, high, low, close,  options), do: run([:cdlidentical3crows, options, open, high, low, close])
  @doc """
  A bang! version of `cdlidentical3crows/5`. It does **not** perform any validations.

  Please refer to `cdlidentical3crows/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlidentical3crows/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlidentical3crows!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlidentical3crows!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlidentical3crows!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlidentical3crows!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlidentical3crows, options, dataframe])
  def cdlidentical3crows!(open, high, low, close, options), do: run!([:cdlidentical3crows, options, open, high, low, close])


  @doc """
  Calculates the **In-Neck Pattern** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLINNECK`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlinneck`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlinneck(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlinneck f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlinneck(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlinneck(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlinneck(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlinneck(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlinneck(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlinneck(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlinneck, options, dataframe])
  def cdlinneck(open, high, low, close,  options), do: run([:cdlinneck, options, open, high, low, close])
  @doc """
  A bang! version of `cdlinneck/5`. It does **not** perform any validations.

  Please refer to `cdlinneck/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlinneck/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlinneck!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlinneck!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlinneck!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlinneck!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlinneck, options, dataframe])
  def cdlinneck!(open, high, low, close, options), do: run!([:cdlinneck, options, open, high, low, close])


  @doc """
  Calculates the **Inverted Hammer** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLINVERTEDHAMMER`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlinvertedhammer`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlinvertedhammer(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlinvertedhammer f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlinvertedhammer(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlinvertedhammer(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlinvertedhammer(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlinvertedhammer(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlinvertedhammer(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlinvertedhammer(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlinvertedhammer, options, dataframe])
  def cdlinvertedhammer(open, high, low, close,  options), do: run([:cdlinvertedhammer, options, open, high, low, close])
  @doc """
  A bang! version of `cdlinvertedhammer/5`. It does **not** perform any validations.

  Please refer to `cdlinvertedhammer/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlinvertedhammer/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlinvertedhammer!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlinvertedhammer!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlinvertedhammer!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlinvertedhammer!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlinvertedhammer, options, dataframe])
  def cdlinvertedhammer!(open, high, low, close, options), do: run!([:cdlinvertedhammer, options, open, high, low, close])


  @doc """
  Calculates the **Kicking** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLKICKING`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlkicking`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlkicking(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlkicking f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlkicking(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlkicking(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlkicking(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlkicking(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlkicking(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlkicking(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlkicking, options, dataframe])
  def cdlkicking(open, high, low, close,  options), do: run([:cdlkicking, options, open, high, low, close])
  @doc """
  A bang! version of `cdlkicking/5`. It does **not** perform any validations.

  Please refer to `cdlkicking/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlkicking/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlkicking!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlkicking!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlkicking!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlkicking!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlkicking, options, dataframe])
  def cdlkicking!(open, high, low, close, options), do: run!([:cdlkicking, options, open, high, low, close])


  @doc """
  Calculates the **Kicking - bull/bear determined by the longer marubozu** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLKICKINGBYLENGTH`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlkickingbylength`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlkickingbylength(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlkickingbylength f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlkickingbylength(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlkickingbylength(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlkickingbylength(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlkickingbylength(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlkickingbylength(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlkickingbylength(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlkickingbylength, options, dataframe])
  def cdlkickingbylength(open, high, low, close,  options), do: run([:cdlkickingbylength, options, open, high, low, close])
  @doc """
  A bang! version of `cdlkickingbylength/5`. It does **not** perform any validations.

  Please refer to `cdlkickingbylength/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlkickingbylength/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlkickingbylength!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlkickingbylength!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlkickingbylength!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlkickingbylength!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlkickingbylength, options, dataframe])
  def cdlkickingbylength!(open, high, low, close, options), do: run!([:cdlkickingbylength, options, open, high, low, close])


  @doc """
  Calculates the **Ladder Bottom** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLLADDERBOTTOM`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlladderbottom`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlladderbottom(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlladderbottom f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlladderbottom(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlladderbottom(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlladderbottom(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlladderbottom(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlladderbottom(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlladderbottom(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlladderbottom, options, dataframe])
  def cdlladderbottom(open, high, low, close,  options), do: run([:cdlladderbottom, options, open, high, low, close])
  @doc """
  A bang! version of `cdlladderbottom/5`. It does **not** perform any validations.

  Please refer to `cdlladderbottom/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlladderbottom/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlladderbottom!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlladderbottom!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlladderbottom!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlladderbottom!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlladderbottom, options, dataframe])
  def cdlladderbottom!(open, high, low, close, options), do: run!([:cdlladderbottom, options, open, high, low, close])


  @doc """
  Calculates the **Long Legged Doji** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLLONGLEGGEDDOJI`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdllongleggeddoji`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdllongleggeddoji(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdllongleggeddoji f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdllongleggeddoji(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdllongleggeddoji(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdllongleggeddoji(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdllongleggeddoji(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdllongleggeddoji(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdllongleggeddoji(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdllongleggeddoji, options, dataframe])
  def cdllongleggeddoji(open, high, low, close,  options), do: run([:cdllongleggeddoji, options, open, high, low, close])
  @doc """
  A bang! version of `cdllongleggeddoji/5`. It does **not** perform any validations.

  Please refer to `cdllongleggeddoji/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdllongleggeddoji/5`.
  """
  @doc type: :pattern_recognition
  @spec cdllongleggeddoji!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdllongleggeddoji!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdllongleggeddoji!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdllongleggeddoji!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdllongleggeddoji, options, dataframe])
  def cdllongleggeddoji!(open, high, low, close, options), do: run!([:cdllongleggeddoji, options, open, high, low, close])


  @doc """
  Calculates the **Long Line Candle** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLLONGLINE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdllongline`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdllongline(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdllongline f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdllongline(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdllongline(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdllongline(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdllongline(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdllongline(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdllongline(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdllongline, options, dataframe])
  def cdllongline(open, high, low, close,  options), do: run([:cdllongline, options, open, high, low, close])
  @doc """
  A bang! version of `cdllongline/5`. It does **not** perform any validations.

  Please refer to `cdllongline/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdllongline/5`.
  """
  @doc type: :pattern_recognition
  @spec cdllongline!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdllongline!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdllongline!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdllongline!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdllongline, options, dataframe])
  def cdllongline!(open, high, low, close, options), do: run!([:cdllongline, options, open, high, low, close])


  @doc """
  Calculates the **Marubozu** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLMARUBOZU`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlmarubozu`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlmarubozu(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlmarubozu f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlmarubozu(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlmarubozu(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlmarubozu(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlmarubozu(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlmarubozu(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlmarubozu(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlmarubozu, options, dataframe])
  def cdlmarubozu(open, high, low, close,  options), do: run([:cdlmarubozu, options, open, high, low, close])
  @doc """
  A bang! version of `cdlmarubozu/5`. It does **not** perform any validations.

  Please refer to `cdlmarubozu/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlmarubozu/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlmarubozu!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlmarubozu!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlmarubozu!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlmarubozu!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlmarubozu, options, dataframe])
  def cdlmarubozu!(open, high, low, close, options), do: run!([:cdlmarubozu, options, open, high, low, close])


  @doc """
  Calculates the **Matching Low** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLMATCHINGLOW`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlmatchinglow`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlmatchinglow(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlmatchinglow f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlmatchinglow(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlmatchinglow(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlmatchinglow(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlmatchinglow(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlmatchinglow(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlmatchinglow(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlmatchinglow, options, dataframe])
  def cdlmatchinglow(open, high, low, close,  options), do: run([:cdlmatchinglow, options, open, high, low, close])
  @doc """
  A bang! version of `cdlmatchinglow/5`. It does **not** perform any validations.

  Please refer to `cdlmatchinglow/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlmatchinglow/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlmatchinglow!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlmatchinglow!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlmatchinglow!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlmatchinglow!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlmatchinglow, options, dataframe])
  def cdlmatchinglow!(open, high, low, close, options), do: run!([:cdlmatchinglow, options, open, high, low, close])


  @doc """
  Calculates the **Mat Hold** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.
  `penetration`: Percentage of penetration of a candle within another candle

  `TA-LIB` source name: `CDLMATHOLD`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlmathold`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlmathold(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlmathold_0.3 f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlmathold(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlmathold(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlmathold(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, penetration :: float(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlmathold(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), penetration :: float(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlmathold(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, penetration \\ 0.3, options \\ [])
  def cdlmathold(dataframe, nil, nil, nil, penetration, options) when is_dataframe(dataframe), do: run_df([:cdlmathold, options, dataframe, penetration])
  def cdlmathold(open, high, low, close, penetration, options), do: run([:cdlmathold, options, open, high, low, close, penetration])
  @doc """
  A bang! version of `cdlmathold/6`. It does **not** perform any validations.

  Please refer to `cdlmathold/6` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlmathold/6`.
  """
  @doc type: :pattern_recognition
  @spec cdlmathold!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, penetration :: float(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlmathold!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), penetration :: float(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlmathold!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, penetration \\ 0.3, options \\ [])
  def cdlmathold!(dataframe, nil, nil, nil, penetration, options) when is_dataframe(dataframe), do: run_df!([:cdlmathold, options, dataframe, penetration])
  def cdlmathold!(open, high, low, close, penetration, options), do: run!([:cdlmathold, options, open, high, low, close, penetration])


  @doc """
  Calculates the **Morning Doji Star** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.
  `penetration`: Percentage of penetration of a candle within another candle

  `TA-LIB` source name: `CDLMORNINGDOJISTAR`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlmorningdojistar`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlmorningdojistar(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlmorningdojistar_0.3 f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlmorningdojistar(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlmorningdojistar(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlmorningdojistar(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, penetration :: float(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlmorningdojistar(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), penetration :: float(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlmorningdojistar(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, penetration \\ 0.3, options \\ [])
  def cdlmorningdojistar(dataframe, nil, nil, nil, penetration, options) when is_dataframe(dataframe), do: run_df([:cdlmorningdojistar, options, dataframe, penetration])
  def cdlmorningdojistar(open, high, low, close, penetration, options), do: run([:cdlmorningdojistar, options, open, high, low, close, penetration])
  @doc """
  A bang! version of `cdlmorningdojistar/6`. It does **not** perform any validations.

  Please refer to `cdlmorningdojistar/6` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlmorningdojistar/6`.
  """
  @doc type: :pattern_recognition
  @spec cdlmorningdojistar!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, penetration :: float(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlmorningdojistar!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), penetration :: float(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlmorningdojistar!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, penetration \\ 0.3, options \\ [])
  def cdlmorningdojistar!(dataframe, nil, nil, nil, penetration, options) when is_dataframe(dataframe), do: run_df!([:cdlmorningdojistar, options, dataframe, penetration])
  def cdlmorningdojistar!(open, high, low, close, penetration, options), do: run!([:cdlmorningdojistar, options, open, high, low, close, penetration])


  @doc """
  Calculates the **Morning Star** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.
  `penetration`: Percentage of penetration of a candle within another candle

  `TA-LIB` source name: `CDLMORNINGSTAR`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlmorningstar`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlmorningstar(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlmorningstar_0.3 f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlmorningstar(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlmorningstar(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlmorningstar(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, penetration :: float(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlmorningstar(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), penetration :: float(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlmorningstar(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, penetration \\ 0.3, options \\ [])
  def cdlmorningstar(dataframe, nil, nil, nil, penetration, options) when is_dataframe(dataframe), do: run_df([:cdlmorningstar, options, dataframe, penetration])
  def cdlmorningstar(open, high, low, close, penetration, options), do: run([:cdlmorningstar, options, open, high, low, close, penetration])
  @doc """
  A bang! version of `cdlmorningstar/6`. It does **not** perform any validations.

  Please refer to `cdlmorningstar/6` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlmorningstar/6`.
  """
  @doc type: :pattern_recognition
  @spec cdlmorningstar!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, penetration :: float(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlmorningstar!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), penetration :: float(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlmorningstar!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, penetration \\ 0.3, options \\ [])
  def cdlmorningstar!(dataframe, nil, nil, nil, penetration, options) when is_dataframe(dataframe), do: run_df!([:cdlmorningstar, options, dataframe, penetration])
  def cdlmorningstar!(open, high, low, close, penetration, options), do: run!([:cdlmorningstar, options, open, high, low, close, penetration])


  @doc """
  Calculates the **On-Neck Pattern** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLONNECK`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlonneck`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlonneck(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlonneck f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlonneck(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlonneck(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlonneck(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlonneck(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlonneck(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlonneck(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlonneck, options, dataframe])
  def cdlonneck(open, high, low, close,  options), do: run([:cdlonneck, options, open, high, low, close])
  @doc """
  A bang! version of `cdlonneck/5`. It does **not** perform any validations.

  Please refer to `cdlonneck/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlonneck/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlonneck!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlonneck!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlonneck!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlonneck!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlonneck, options, dataframe])
  def cdlonneck!(open, high, low, close, options), do: run!([:cdlonneck, options, open, high, low, close])


  @doc """
  Calculates the **Piercing Pattern** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLPIERCING`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlpiercing`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlpiercing(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlpiercing f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlpiercing(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlpiercing(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlpiercing(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlpiercing(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlpiercing(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlpiercing(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlpiercing, options, dataframe])
  def cdlpiercing(open, high, low, close,  options), do: run([:cdlpiercing, options, open, high, low, close])
  @doc """
  A bang! version of `cdlpiercing/5`. It does **not** perform any validations.

  Please refer to `cdlpiercing/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlpiercing/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlpiercing!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlpiercing!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlpiercing!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlpiercing!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlpiercing, options, dataframe])
  def cdlpiercing!(open, high, low, close, options), do: run!([:cdlpiercing, options, open, high, low, close])


  @doc """
  Calculates the **Rickshaw Man** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLRICKSHAWMAN`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlrickshawman`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlrickshawman(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlrickshawman f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlrickshawman(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlrickshawman(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlrickshawman(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlrickshawman(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlrickshawman(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlrickshawman(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlrickshawman, options, dataframe])
  def cdlrickshawman(open, high, low, close,  options), do: run([:cdlrickshawman, options, open, high, low, close])
  @doc """
  A bang! version of `cdlrickshawman/5`. It does **not** perform any validations.

  Please refer to `cdlrickshawman/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlrickshawman/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlrickshawman!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlrickshawman!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlrickshawman!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlrickshawman!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlrickshawman, options, dataframe])
  def cdlrickshawman!(open, high, low, close, options), do: run!([:cdlrickshawman, options, open, high, low, close])


  @doc """
  Calculates the **Rising/Falling Three Methods** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLRISEFALL3METHODS`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlrisefall3methods`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlrisefall3methods(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlrisefall3methods f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlrisefall3methods(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlrisefall3methods(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlrisefall3methods(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlrisefall3methods(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlrisefall3methods(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlrisefall3methods(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlrisefall3methods, options, dataframe])
  def cdlrisefall3methods(open, high, low, close,  options), do: run([:cdlrisefall3methods, options, open, high, low, close])
  @doc """
  A bang! version of `cdlrisefall3methods/5`. It does **not** perform any validations.

  Please refer to `cdlrisefall3methods/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlrisefall3methods/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlrisefall3methods!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlrisefall3methods!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlrisefall3methods!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlrisefall3methods!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlrisefall3methods, options, dataframe])
  def cdlrisefall3methods!(open, high, low, close, options), do: run!([:cdlrisefall3methods, options, open, high, low, close])


  @doc """
  Calculates the **Separating Lines** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLSEPARATINGLINES`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlseparatinglines`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlseparatinglines(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlseparatinglines f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlseparatinglines(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlseparatinglines(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlseparatinglines(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlseparatinglines(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlseparatinglines(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlseparatinglines(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlseparatinglines, options, dataframe])
  def cdlseparatinglines(open, high, low, close,  options), do: run([:cdlseparatinglines, options, open, high, low, close])
  @doc """
  A bang! version of `cdlseparatinglines/5`. It does **not** perform any validations.

  Please refer to `cdlseparatinglines/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlseparatinglines/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlseparatinglines!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlseparatinglines!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlseparatinglines!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlseparatinglines!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlseparatinglines, options, dataframe])
  def cdlseparatinglines!(open, high, low, close, options), do: run!([:cdlseparatinglines, options, open, high, low, close])


  @doc """
  Calculates the **Shooting Star** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLSHOOTINGSTAR`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlshootingstar`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlshootingstar(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlshootingstar f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlshootingstar(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlshootingstar(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlshootingstar(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlshootingstar(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlshootingstar(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlshootingstar(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlshootingstar, options, dataframe])
  def cdlshootingstar(open, high, low, close,  options), do: run([:cdlshootingstar, options, open, high, low, close])
  @doc """
  A bang! version of `cdlshootingstar/5`. It does **not** perform any validations.

  Please refer to `cdlshootingstar/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlshootingstar/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlshootingstar!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlshootingstar!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlshootingstar!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlshootingstar!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlshootingstar, options, dataframe])
  def cdlshootingstar!(open, high, low, close, options), do: run!([:cdlshootingstar, options, open, high, low, close])


  @doc """
  Calculates the **Short Line Candle** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLSHORTLINE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlshortline`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlshortline(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlshortline f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlshortline(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlshortline(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlshortline(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlshortline(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlshortline(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlshortline(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlshortline, options, dataframe])
  def cdlshortline(open, high, low, close,  options), do: run([:cdlshortline, options, open, high, low, close])
  @doc """
  A bang! version of `cdlshortline/5`. It does **not** perform any validations.

  Please refer to `cdlshortline/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlshortline/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlshortline!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlshortline!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlshortline!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlshortline!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlshortline, options, dataframe])
  def cdlshortline!(open, high, low, close, options), do: run!([:cdlshortline, options, open, high, low, close])


  @doc """
  Calculates the **Spinning Top** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLSPINNINGTOP`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlspinningtop`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlspinningtop(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlspinningtop f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlspinningtop(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlspinningtop(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlspinningtop(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlspinningtop(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlspinningtop(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlspinningtop(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlspinningtop, options, dataframe])
  def cdlspinningtop(open, high, low, close,  options), do: run([:cdlspinningtop, options, open, high, low, close])
  @doc """
  A bang! version of `cdlspinningtop/5`. It does **not** perform any validations.

  Please refer to `cdlspinningtop/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlspinningtop/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlspinningtop!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlspinningtop!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlspinningtop!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlspinningtop!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlspinningtop, options, dataframe])
  def cdlspinningtop!(open, high, low, close, options), do: run!([:cdlspinningtop, options, open, high, low, close])


  @doc """
  Calculates the **Stalled Pattern** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLSTALLEDPATTERN`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlstalledpattern`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlstalledpattern(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlstalledpattern f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlstalledpattern(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlstalledpattern(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlstalledpattern(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlstalledpattern(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlstalledpattern(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlstalledpattern(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlstalledpattern, options, dataframe])
  def cdlstalledpattern(open, high, low, close,  options), do: run([:cdlstalledpattern, options, open, high, low, close])
  @doc """
  A bang! version of `cdlstalledpattern/5`. It does **not** perform any validations.

  Please refer to `cdlstalledpattern/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlstalledpattern/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlstalledpattern!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlstalledpattern!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlstalledpattern!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlstalledpattern!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlstalledpattern, options, dataframe])
  def cdlstalledpattern!(open, high, low, close, options), do: run!([:cdlstalledpattern, options, open, high, low, close])


  @doc """
  Calculates the **Stick Sandwich** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLSTICKSANDWICH`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlsticksandwich`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlsticksandwich(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlsticksandwich f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlsticksandwich(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlsticksandwich(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlsticksandwich(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlsticksandwich(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlsticksandwich(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlsticksandwich(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlsticksandwich, options, dataframe])
  def cdlsticksandwich(open, high, low, close,  options), do: run([:cdlsticksandwich, options, open, high, low, close])
  @doc """
  A bang! version of `cdlsticksandwich/5`. It does **not** perform any validations.

  Please refer to `cdlsticksandwich/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlsticksandwich/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlsticksandwich!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlsticksandwich!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlsticksandwich!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlsticksandwich!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlsticksandwich, options, dataframe])
  def cdlsticksandwich!(open, high, low, close, options), do: run!([:cdlsticksandwich, options, open, high, low, close])


  @doc """
  Calculates the **Takuri (Dragonfly Doji with very long lower shadow)** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLTAKURI`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdltakuri`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdltakuri(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdltakuri f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdltakuri(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdltakuri(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdltakuri(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdltakuri(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdltakuri(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdltakuri(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdltakuri, options, dataframe])
  def cdltakuri(open, high, low, close,  options), do: run([:cdltakuri, options, open, high, low, close])
  @doc """
  A bang! version of `cdltakuri/5`. It does **not** perform any validations.

  Please refer to `cdltakuri/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdltakuri/5`.
  """
  @doc type: :pattern_recognition
  @spec cdltakuri!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdltakuri!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdltakuri!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdltakuri!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdltakuri, options, dataframe])
  def cdltakuri!(open, high, low, close, options), do: run!([:cdltakuri, options, open, high, low, close])


  @doc """
  Calculates the **Tasuki Gap** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLTASUKIGAP`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdltasukigap`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdltasukigap(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdltasukigap f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdltasukigap(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdltasukigap(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdltasukigap(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdltasukigap(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdltasukigap(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdltasukigap(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdltasukigap, options, dataframe])
  def cdltasukigap(open, high, low, close,  options), do: run([:cdltasukigap, options, open, high, low, close])
  @doc """
  A bang! version of `cdltasukigap/5`. It does **not** perform any validations.

  Please refer to `cdltasukigap/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdltasukigap/5`.
  """
  @doc type: :pattern_recognition
  @spec cdltasukigap!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdltasukigap!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdltasukigap!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdltasukigap!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdltasukigap, options, dataframe])
  def cdltasukigap!(open, high, low, close, options), do: run!([:cdltasukigap, options, open, high, low, close])


  @doc """
  Calculates the **Thrusting Pattern** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLTHRUSTING`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlthrusting`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlthrusting(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlthrusting f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlthrusting(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlthrusting(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlthrusting(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlthrusting(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlthrusting(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlthrusting(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlthrusting, options, dataframe])
  def cdlthrusting(open, high, low, close,  options), do: run([:cdlthrusting, options, open, high, low, close])
  @doc """
  A bang! version of `cdlthrusting/5`. It does **not** perform any validations.

  Please refer to `cdlthrusting/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlthrusting/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlthrusting!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlthrusting!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlthrusting!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlthrusting!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlthrusting, options, dataframe])
  def cdlthrusting!(open, high, low, close, options), do: run!([:cdlthrusting, options, open, high, low, close])


  @doc """
  Calculates the **Tristar Pattern** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLTRISTAR`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdltristar`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdltristar(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdltristar f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdltristar(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdltristar(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdltristar(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdltristar(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdltristar(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdltristar(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdltristar, options, dataframe])
  def cdltristar(open, high, low, close,  options), do: run([:cdltristar, options, open, high, low, close])
  @doc """
  A bang! version of `cdltristar/5`. It does **not** perform any validations.

  Please refer to `cdltristar/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdltristar/5`.
  """
  @doc type: :pattern_recognition
  @spec cdltristar!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdltristar!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdltristar!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdltristar!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdltristar, options, dataframe])
  def cdltristar!(open, high, low, close, options), do: run!([:cdltristar, options, open, high, low, close])


  @doc """
  Calculates the **Unique 3 River** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLUNIQUE3RIVER`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlunique3river`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlunique3river(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlunique3river f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlunique3river(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlunique3river(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlunique3river(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlunique3river(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlunique3river(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlunique3river(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlunique3river, options, dataframe])
  def cdlunique3river(open, high, low, close,  options), do: run([:cdlunique3river, options, open, high, low, close])
  @doc """
  A bang! version of `cdlunique3river/5`. It does **not** perform any validations.

  Please refer to `cdlunique3river/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlunique3river/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlunique3river!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlunique3river!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlunique3river!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlunique3river!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlunique3river, options, dataframe])
  def cdlunique3river!(open, high, low, close, options), do: run!([:cdlunique3river, options, open, high, low, close])


  @doc """
  Calculates the **Upside Gap Two Crows** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLUPSIDEGAP2CROWS`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlupsidegap2crows`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlupsidegap2crows(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlupsidegap2crows f64 [NaN, NaN, NaN]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlupsidegap2crows(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlupsidegap2crows(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlupsidegap2crows(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlupsidegap2crows(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlupsidegap2crows(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlupsidegap2crows(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlupsidegap2crows, options, dataframe])
  def cdlupsidegap2crows(open, high, low, close,  options), do: run([:cdlupsidegap2crows, options, open, high, low, close])
  @doc """
  A bang! version of `cdlupsidegap2crows/5`. It does **not** perform any validations.

  Please refer to `cdlupsidegap2crows/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlupsidegap2crows/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlupsidegap2crows!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlupsidegap2crows!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlupsidegap2crows!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlupsidegap2crows!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlupsidegap2crows, options, dataframe])
  def cdlupsidegap2crows!(open, high, low, close, options), do: run!([:cdlupsidegap2crows, options, open, high, low, close])


  @doc """
  Calculates the **Upside/Downside Gap Three Methods** candle pattern indicator.
  This function requires **at least** `12` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CDLXSIDEGAP3METHODS`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cdlxsidegap3methods`, type: `[:f64]` (`100.0` when pattern identified, `0.0` otherwise)

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [4.0, 5.0, 6.0], high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.cdlxsidegap3methods(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          open f64 [4.0, 5.0, 6.0]
          cdlxsidegap3methods f64 [NaN, NaN, 0.0]]
        >}
  ## Example Using Series:
      iex> [open, high, low, close] = [Explorer.Series.from_list([4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.cdlxsidegap3methods(open, high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, 0.0]]
          >
        }}

  ## Example Using Tensors:
      iex> [open, high, low, close] = [Nx.tensor([4.0, 5.0, 6.0], type: :f64), Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.cdlxsidegap3methods(open, high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, 0.0]]
          >
        }}

  """
  @doc type: :pattern_recognition
  @spec cdlxsidegap3methods(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cdlxsidegap3methods(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cdlxsidegap3methods(open_or_dataframe, high \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlxsidegap3methods(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df([:cdlxsidegap3methods, options, dataframe])
  def cdlxsidegap3methods(open, high, low, close,  options), do: run([:cdlxsidegap3methods, options, open, high, low, close])
  @doc """
  A bang! version of `cdlxsidegap3methods/5`. It does **not** perform any validations.

  Please refer to `cdlxsidegap3methods/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cdlxsidegap3methods/5`.
  """
  @doc type: :pattern_recognition
  @spec cdlxsidegap3methods!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cdlxsidegap3methods!(open :: Explorer.Series.t() | Nx.Tensor.t(), high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cdlxsidegap3methods!(open_or_dataframe, open \\ nil, low \\ nil, close \\ nil, options \\ [])
  def cdlxsidegap3methods!(dataframe, nil, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:cdlxsidegap3methods, options, dataframe])
  def cdlxsidegap3methods!(open, high, low, close, options), do: run!([:cdlxsidegap3methods, options, open, high, low, close])


  @doc """
  Calculates the **Vector Ceil** indicator.

  `TA-LIB` source name: `CEIL`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `ceil`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.5, 4.5, 5.0]})
      iex> ExTalib.ceil(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 6]
          values f64 [3.5, 4.5, 5.0]
          ceil f64 [4.0, 5.0, 5.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.5, 4.5, 5.0], dtype: {:f, 64})
      iex> ExTalib.ceil(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [4.0, 5.0, 5.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.5, 4.5, 5.0], type: :f64)
      iex> ExTalib.ceil(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [4.0, 5.0, 5.0]
          >
        }}

  """
  @doc type: :math_transform
  @spec ceil(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec ceil(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def ceil(values_or_dataframe, options \\ [])
  def ceil(dataframe, options) when is_dataframe(dataframe), do: run_df([:ceil, options, dataframe])
  def ceil(values, options), do: run([:ceil, options, values])
  @doc """
  A bang! version of `ceil/2`. It does **not** perform any validations.

  Please refer to `ceil/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `ceil/2`.
  """
  @doc type: :math_transform
  @spec ceil!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec ceil!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def ceil!(values_or_dataframe, options \\ [])
  def ceil!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:ceil, options, dataframe])
  def ceil!(values, options), do: run!([:ceil, options, values])


  @doc """
  Calculates the **Chande Momentum Oscillator** indicator.
  This function requires **at least** `14` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `CMO`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cmo`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.cmo(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          cmo_2 f64 [NNaN, NaN, 100.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.cmo(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, 100.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.cmo(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, 100.0]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec cmo(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cmo(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cmo(values_or_dataframe, time_period \\ 14, options \\ [])
  def cmo(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:cmo, options, dataframe, time_period])
  def cmo(values, time_period, options), do: run([:cmo, options, values, time_period])
  @doc """
  A bang! version of `cmo/3`. It does **not** perform any validations.

  Please refer to `cmo/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cmo/3`.
  """
  @doc type: :momentum_indicators
  @spec cmo!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cmo!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cmo!(values_or_dataframe, time_period \\ 14, options \\ [])
  def cmo!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:cmo, options, dataframe, time_period])
  def cmo!(values, time_period, options), do: run!([:cmo, options, values, time_period])


  @doc """
  Calculates the **Pearson's Correlation Coefficient (r)** indicator.

  `TA-LIB` source name: `CORREL`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values_a`, `values_b`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `correl`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values_a: [5.0, 6.0, 7.0], values_b: [2.0, 3.0, 3.0]})
      iex> ExTalib.correl(df, nil, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 3]
          values_a f64 [5.0, 6.0, 7.0]
          values_b f64 [2.0, 3.0, 3.0]
          correl_2 f64 [NaN, 1.0, 0.0]
        >}
  ## Example Using Series:
      iex> [values_a, values_b] = [Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 3.0])]
      iex> ExTalib.correl(values_a, values_b, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 1.0, 0.0]
          >
        }}

  ## Example Using Tensors:
      iex> [values_a, values_b] = [Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 3.0], type: :f64)]
      iex> ExTalib.correl(values_a, values_b, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 1.0, 0.0]
          >
        }}

  """
  @doc type: :statistic_functions
  @spec correl(dataframe :: Explorer.DataFrame.t(), nil, time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec correl(values_a :: Explorer.Series.t() | Nx.Tensor.t(), values_b :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(),options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def correl(values_a_or_dataframe, values_b \\ nil, time_period \\ 30, options \\ [])
  def correl(dataframe, nil, time_period, options) when is_dataframe(dataframe), do: run_df([:correl, options, dataframe, time_period])
  def correl(values_a, values_b, time_period, options), do: run([:correl, options, values_a, values_b, time_period])
  @doc """
  A bang! version of `correl/3`. It does **not** perform any validations.

  Please refer to `correl/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `correl/3`.
  """
  @doc type: :statistic_functions
  @spec correl!(dataframe :: Explorer.DataFrame.t(), nil, time_period :: integer(),options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec correl!(values_a :: Explorer.Series.t() | Nx.Tensor.t(), values_b :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(),options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def correl!(values_a_or_dataframe, values_b \\ nil, time_period \\ 30, options \\ [])
  def correl!(dataframe, nil, time_period, options) when is_dataframe(dataframe), do: run_df!([:correl, options, dataframe, time_period])
  def correl!(values_a, values_b, time_period, options), do: run!([:correl, options, values_a, values_b, time_period])


  @doc """
  Calculates the **Vector Trigonometric Cos** indicator.

  `TA-LIB` source name: `COS`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cos`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.5, 4.5, 5.0]})
      iex> ExTalib.cos(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.5, 4.5, 5.0]
          cos f64 [-0.9364566872907963, -0.2107957994307797, 0.28366218546322625]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.5, 4.5, 5.0], dtype: {:f, 64})
      iex> ExTalib.cos(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [-0.9364566872907963, -0.2107957994307797, 0.28366218546322625]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.5, 4.5, 5.0], type: :f64)
      iex> ExTalib.cos(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [-0.9364566872907963, -0.2107957994307797, 0.28366218546322625]
          >
        }}

  """
  @doc type: :math_transform
  @spec cos(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cos(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cos(values_or_dataframe, options \\ [])
  def cos(dataframe, options) when is_dataframe(dataframe), do: run_df([:cos, options, dataframe])
  def cos(values, options), do: run([:cos, options, values])
  @doc """
  A bang! version of `cos/2`. It does **not** perform any validations.

  Please refer to `cos/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cos/2`.
  """
  @doc type: :math_transform
  @spec cos!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cos!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cos!(values_or_dataframe, options \\ [])
  def cos!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:cos, options, dataframe])
  def cos!(values, options), do: run!([:cos, options, values])


  @doc """
  Calculates the **Vector Trigonometric Cosh** indicator.

  `TA-LIB` source name: `COSH`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `cosh`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.5, 4.5, 5.0]})
      iex> ExTalib.cosh(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.5, 4.5, 5.0]
          cosh f64 [-0.9364566872907963, -0.2107957994307797, 0.28366218546322625]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.5, 4.5, 5.0], dtype: {:f, 64})
      iex> ExTalib.cosh(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [-0.9364566872907963, -0.2107957994307797, 0.28366218546322625]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.5, 4.5, 5.0], type: :f64)
      iex> ExTalib.cosh(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [-0.9364566872907963, -0.2107957994307797, 0.28366218546322625]
          >
        }}

  """
  @doc type: :math_transform
  @spec cosh(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec cosh(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def cosh(values_or_dataframe, options \\ [])
  def cosh(dataframe, options) when is_dataframe(dataframe), do: run_df([:cosh, options, dataframe])
  def cosh(values, options), do: run([:cosh, options, values])
  @doc """
  A bang! version of `cosh/2`. It does **not** perform any validations.

  Please refer to `cosh/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `cosh/2`.
  """
  @doc type: :math_transform
  @spec cosh!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec cosh!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def cosh!(values_or_dataframe, options \\ [])
  def cosh!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:cosh, options, dataframe])
  def cosh!(values, options), do: run!([:cosh, options, values])


  @doc """
  Calculates the **Double Exponential Moving Average** indicator.

  `TA-LIB` source name: `DEMA`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `dema`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.dema(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          dema_2 f64 [NaN, NaN, 5.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.dema(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, 5.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.dema(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, 5.0]
          >
        }}

  """
  @doc type: :overlap_studies
  @spec dema(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec dema(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def dema(values_or_dataframe, time_period \\ 30, options \\ [])
  def dema(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:dema, options, dataframe, time_period])
  def dema(values, time_period, options), do: run([:dema, options, values, time_period])
  @doc """
  A bang! version of `dema/3`. It does **not** perform any validations.

  Please refer to `dema/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `dema/3`.
  """
  @doc type: :overlap_studies
  @spec dema!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec dema!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def dema!(values_or_dataframe, time_period \\ 30, options \\ [])
  def dema!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:dema, options, dataframe, time_period])
  def dema!(values, time_period, options), do: run!([:dema, options, values, time_period])


  @doc """
  Calculates the **Vector Arithmetic Div** indicator.

  `TA-LIB` source name: `DIV`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values_a`, `values_b`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `div`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values_a: [5.0, 6.0, 7.0], values_b: [2.0, 3.0, 4.0]})
      iex> ExTalib.div(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 3]
          values_a f64 [5.0, 6.0, 7.0]
          values_b f64 [2.0, 3.0, 4.0]
          div f64 [2.5, 2.0, 1.75]]
        >}
  ## Example Using Series:
      iex> [values_a, values_b] = [Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0])]
      iex> ExTalib.div(values_a, values_b)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [2.5, 2.0, 1.75]]
          >
        }}

  ## Example Using Tensors:
      iex> [values_a, values_b] = [Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64)]
      iex> ExTalib.div(values_a, values_b)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [2.5, 2.0, 1.75]]
          >
        }}

  """
  @doc type: :math_operators
  @spec div(dataframe :: Explorer.DataFrame.t(), nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec div(values_a :: Explorer.Series.t() | Nx.Tensor.t(), values_b :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def div(values_a_or_dataframe, values_b \\ nil, options \\ [])
  def div(dataframe, nil, options) when is_dataframe(dataframe), do: run_df([:div, options, dataframe])
  def div(values_a, values_b, options), do: run([:div, options, values_a, values_b])
  @doc """
  A bang! version of `div/3`. It does **not** perform any validations.

  Please refer to `div/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `div/3`.
  """
  @doc type: :math_operators
  @spec div!(dataframe :: Explorer.DataFrame.t(), nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec div!(values_a :: Explorer.Series.t() | Nx.Tensor.t(), values_b :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def div!(values_a_or_dataframe, values_b \\ nil, options \\ [])
  def div!(dataframe, nil, options) when is_dataframe(dataframe), do: run_df!([:div, options, dataframe])
  def div!(values_a, values_b, options), do: run!([:div, options, values_a, values_b])


  @doc """
  Calculates the **Directional Movement Index** indicator.

  `TA-LIB` source name: `DX`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `dx`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0, 8.0, 9.0], low: [2.0, 3.0, 4.0, 5.0, 6.0], close: [3.0, 4.0, 5.0, 6.0, 7.0]})
      iex> ExTalib.dx(df, nil ,nil, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[5 x 4]
          close f64 [3.0, 4.0, 5.0, 6.0, 7.0]
          high f64 [5.0, 6.0, 7.0, 8.0, 9.0]
          low f64 [2.0, 3.0, 4.0, 5.0, 6.0]
          dx_2 f64 [NaN, NaN, 100.0, 100.0, 100.0]
        >}
  ## Example Using Series:
      iex> [high, low, close] = [Explorer.Series.from_list([5.0, 6.0, 7.0, 8.0, 9.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0, 6.0, 7.0], dtype: {:f, 64})]
      iex> ExTalib.dx(high, low, close, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[5]
            f64 [NaN, NaN, 100.0, 100.0, 100.0]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low, close] = [Nx.tensor([5.0, 6.0, 7.0, 8.0, 9.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0, 5.0, 6.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0, 6.0, 7.0], type: :f64)]
      iex> ExTalib.dx(high, low, close, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[5]
            [NaN, NaN, 100.0, 100.0, 100.0]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec dx(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec dx(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def dx(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 14, options \\ [])
  def dx(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df([:dx, options, dataframe, time_period])
  def dx(high, low, close, time_period, options), do: run([:dx, options, high, low, close, time_period])
  @doc """
  A bang! version of `dx/5`. It does **not** perform any validations.

  Please refer to `dx/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `dx/5`.
  """
  @doc type: :momentum_indicators
  @spec dx!(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec dx!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def dx!(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 14, options \\ [])
  def dx!(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df!([:dx, options, dataframe, time_period])
  def dx!(high, low, close, time_period, options), do: run!([:dx, options, high, low, close, time_period])


  @doc """
  Calculates the **Exponential Moving Average** indicator.

  `TA-LIB` source name: `EMA`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `ema`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.ema(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          ema_2 f64 [NaN, 3.5, 4.5]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.ema(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 3.5, 4.5]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.ema(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 3.5, 4.5]
          >
        }}

  """
  @doc type: :overlap_studies
  @spec ema(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec ema(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def ema(values_or_dataframe, time_period \\ 30, options \\ [])
  def ema(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:ema, options, dataframe, time_period])
  def ema(values, time_period, options), do: run([:ema, options, values, time_period])
  @doc """
  A bang! version of `ema/3`. It does **not** perform any validations.

  Please refer to `ema/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `ema/3`.
  """
  @doc type: :overlap_studies
  @spec ema!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec ema!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def ema!(values_or_dataframe, time_period \\ 30, options \\ [])
  def ema!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:ema, options, dataframe, time_period])
  def ema!(values, time_period, options), do: run!([:ema, options, values, time_period])


  @doc """
  Calculates the **Vector Arithmetic Exp** indicator.

  `TA-LIB` source name: `EXP`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `exp`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.5, 4.5, 5.0]})
      iex> ExTalib.exp(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.5, 4.5, 5.0]
          exp f64 [33.11545195869231, 90.01713130052181, 148.4131591025766]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.5, 4.5, 5.0], dtype: {:f, 64})
      iex> ExTalib.exp(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [33.11545195869231, 90.01713130052181, 148.4131591025766]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.5, 4.5, 5.0], type: :f64)
      iex> ExTalib.exp(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [33.11545195869231, 90.01713130052181, 148.4131591025766]
          >
        }}

  """
  @doc type: :math_transform
  @spec exp(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec exp(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def exp(values_or_dataframe, options \\ [])
  def exp(dataframe, options) when is_dataframe(dataframe), do: run_df([:exp, options, dataframe])
  def exp(values, options), do: run([:exp, options, values])
  @doc """
  A bang! version of `exp/2`. It does **not** perform any validations.

  Please refer to `exp/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `exp/2`.
  """
  @doc type: :math_transform
  @spec exp!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec exp!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def exp!(values_or_dataframe, options \\ [])
  def exp!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:exp, options, dataframe])
  def exp!(values, options), do: run!([:exp, options, values])


  @doc """
  Calculates the **Vector Floor** indicator.

  `TA-LIB` source name: `FLOOR`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `floor`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.5, 4.5, 5.0]})
      iex> ExTalib.floor(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.5, 4.5, 5.0]
          floor f64 [3.0, 4.0, 5.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.5, 4.5, 5.0], dtype: {:f, 64})
      iex> ExTalib.floor(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [3.0, 4.0, 5.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.5, 4.5, 5.0], type: :f64)
      iex> ExTalib.floor(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [3.0, 4.0, 5.0]
          >
        }}

  """
  @doc type: :math_transform
  @spec floor(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec floor(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def floor(values_or_dataframe, options \\ [])
  def floor(dataframe, options) when is_dataframe(dataframe), do: run_df([:floor, options, dataframe])
  def floor(values, options), do: run([:floor, options, values])
  @doc """
  A bang! version of `floor/2`. It does **not** perform any validations.

  Please refer to `floor/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `floor/2`.
  """
  @doc type: :math_transform
  @spec floor!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec floor!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def floor!(values_or_dataframe, options \\ [])
  def floor!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:floor, options, dataframe])
  def floor!(values, options), do: run!([:floor, options, values])


  @doc """
  Calculates the **Hilbert Transform - Dominant Cycle Period** indicator.
  This function requires **at least** `32` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `HT_DCPERIOD`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `ht_dcperiod`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.5, 4.5, 5.0]})
      iex> ExTalib.ht_dcperiod(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.5, 4.5, 5.0]
          ht_dcperiod f64 [NaN, NaN, NaN]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.5, 4.5, 5.0], dtype: {:f, 64})
      iex> ExTalib.ht_dcperiod(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.5, 4.5, 5.0], type: :f64)
      iex> ExTalib.ht_dcperiod(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :cycle_indicators
  @spec ht_dcperiod(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec ht_dcperiod(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def ht_dcperiod(values_or_dataframe, options \\ [])
  def ht_dcperiod(dataframe, options) when is_dataframe(dataframe), do: run_df([:ht_dcperiod, options, dataframe])
  def ht_dcperiod(values, options), do: run([:ht_dcperiod, options, values])
  @doc """
  A bang! version of `ht_dcperiod/2`. It does **not** perform any validations.

  Please refer to `ht_dcperiod/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `ht_dcperiod/2`.
  """
  @doc type: :cycle_indicators
  @spec ht_dcperiod!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec ht_dcperiod!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def ht_dcperiod!(values_or_dataframe, options \\ [])
  def ht_dcperiod!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:ht_dcperiod, options, dataframe])
  def ht_dcperiod!(values, options), do: run!([:ht_dcperiod, options, values])


  @doc """
  Calculates the **Hilbert Transform - Dominant Cycle Phase** indicator.
  This function requires **at least** `64` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `HT_DCPHASE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `ht_dcphase`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.5, 4.5, 5.0]})
      iex> ExTalib.ht_dcphase(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.5, 4.5, 5.0]
          ht_dcphase f64 [NaN, NaN, NaN]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.5, 4.5, 5.0], dtype: {:f, 64})
      iex> ExTalib.ht_dcphase(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.5, 4.5, 5.0], type: :f64)
      iex> ExTalib.ht_dcphase(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :cycle_indicators
  @spec ht_dcphase(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec ht_dcphase(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def ht_dcphase(values_or_dataframe, options \\ [])
  def ht_dcphase(dataframe, options) when is_dataframe(dataframe), do: run_df([:ht_dcphase, options, dataframe])
  def ht_dcphase(values, options), do: run([:ht_dcphase, options, values])
  @doc """
  A bang! version of `ht_dcphase/2`. It does **not** perform any validations.

  Please refer to `ht_dcphase/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `ht_dcphase/2`.
  """
  @doc type: :cycle_indicators
  @spec ht_dcphase!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec ht_dcphase!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def ht_dcphase!(values_or_dataframe, options \\ [])
  def ht_dcphase!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:ht_dcphase, options, dataframe])
  def ht_dcphase!(values, options), do: run!([:ht_dcphase, options, values])


  @doc """
  Calculates the **Hilbert Transform - Phasor Components** indicator.
  This function requires **at least** `32` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `HT_PHASOR`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `inphase`, type: `[:f64]`
    - `quadrature`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.5, 4.5, 5.0]})
      iex> ExTalib.ht_phasor(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 3]
          values f64 [3.5, 4.5, 5.0]
          inphase f64 [NaN, NaN, NaN]
          quadrature f64 [NaN, NaN, NaN]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.5, 4.5, 5.0], dtype: {:f, 64})
      iex> ExTalib.ht_phasor(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >,
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.5, 4.5, 5.0], type: :f64)
      iex> ExTalib.ht_phasor(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >,
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :cycle_indicators
  @spec ht_phasor(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec ht_phasor(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def ht_phasor(values_or_dataframe, options \\ [])
  def ht_phasor(dataframe, options) when is_dataframe(dataframe), do: run_df([:ht_phasor, options, dataframe])
  def ht_phasor(values, options), do: run([:ht_phasor, options, values])
  @doc """
  A bang! version of `ht_phasor/2`. It does **not** perform any validations.

  Please refer to `ht_phasor/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `ht_phasor/2`.
  """
  @doc type: :cycle_indicators
  @spec ht_phasor!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec ht_phasor!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def ht_phasor!(values_or_dataframe, options \\ [])
  def ht_phasor!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:ht_phasor, options, dataframe])
  def ht_phasor!(values, options), do: run!([:ht_phasor, options, values])


  @doc """
  Calculates the **Hilbert Transform - SineWave** indicator.
  This function requires **at least** `64` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `HT_SINE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `sine`, type: `[:f64]`
    - `leadsine`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.5, 4.5, 5.0]})
      iex> ExTalib.ht_sine(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 3]
          values f64 [3.5, 4.5, 5.0]
          sine f64 [NaN, NaN, NaN]
          leadsine f64 [NaN, NaN, NaN]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.5, 4.5, 5.0], dtype: {:f, 64})
      iex> ExTalib.ht_sine(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >,
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.5, 4.5, 5.0], type: :f64)
      iex> ExTalib.ht_sine(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >,
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :cycle_indicators
  @spec ht_sine(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec ht_sine(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def ht_sine(values_or_dataframe, options \\ [])
  def ht_sine(dataframe, options) when is_dataframe(dataframe), do: run_df([:ht_sine, options, dataframe])
  def ht_sine(values, options), do: run([:ht_sine, options, values])
  @doc """
  A bang! version of `ht_sine/2`. It does **not** perform any validations.

  Please refer to `ht_sine/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `ht_sine/2`.
  """
  @doc type: :cycle_indicators
  @spec ht_sine!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec ht_sine!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def ht_sine!(values_or_dataframe, options \\ [])
  def ht_sine!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:ht_sine, options, dataframe])
  def ht_sine!(values, options), do: run!([:ht_sine, options, values])



  @doc """
  Calculates the **Hilbert Transform - Instantaneous Trendline** indicator.
  This function requires **at least** `64` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `HT_TRENDLINE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `ht_trendline`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.ht_trendline(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 6]
          values f64 [3.0, 4.0, 5.0]
          ht_trendline f64 [NaN, NaN, NaN]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.ht_trendline(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.ht_trendline(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :overlap_studies
  @spec ht_trendline(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec ht_trendline(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def ht_trendline(values_or_dataframe, options \\ [])
  def ht_trendline(dataframe, options) when is_dataframe(dataframe), do: run_df([:ht_trendline, options, dataframe])
  def ht_trendline(values, options), do: run([:ht_trendline, options, values])
  @doc """
  A bang! version of `ht_trendline/2`. It does **not** perform any validations.

  Please refer to `ht_trendline/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `ht_trendline/2`.
  """
  @doc type: :overlap_studies
  @spec ht_trendline!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec ht_trendline!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def ht_trendline!(values_or_dataframe, options \\ [])
  def ht_trendline!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:ht_trendline, options, dataframe])
  def ht_trendline!(values, options), do: run!([:ht_trendline, options, values])


  @doc """
  Calculates the **Hilbert Transform - Trend vs Cycle Mode** indicator.
  This function requires **at least** `64` values before it start outputing real numbers - results will be `NaN` before that.

  `TA-LIB` source name: `HT_TRENDMODE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `ht_trendmode`, type: `[:s32]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.ht_trendmode(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 6]
          values f64 [3.0, 4.0, 5.0]
          ht_trendmode f64 [NaN, NaN, NaN]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.ht_trendmode(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.ht_trendmode(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :cycle_indicators
  @spec ht_trendmode(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec ht_trendmode(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def ht_trendmode(values_or_dataframe, options \\ [])
  def ht_trendmode(dataframe, options) when is_dataframe(dataframe), do: run_df([:ht_trendmode, options, dataframe])
  def ht_trendmode(values, options), do: run([:ht_trendmode, options, values])
  @doc """
  A bang! version of `ht_trendmode/2`. It does **not** perform any validations.

  Please refer to `ht_trendmode/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `ht_trendmode/2`.
  """
  @doc type: :cycle_indicators
  @spec ht_trendmode!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec ht_trendmode!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def ht_trendmode!(values_or_dataframe, options \\ [])
  def ht_trendmode!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:ht_trendmode, options, dataframe])
  def ht_trendmode!(values, options), do: run!([:ht_trendmode, options, values])


  @doc """
  Calculates the **Intraday Momentum Index** indicator.

  `TA-LIB` source name: `IMI`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `open`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `imi`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{open: [5.0, 6.0, 7.0, 8.0, 9.0], close: [2.0, 3.0, 4.0, 5.0, 6.0]})
      iex> ExTalib.imi(df, nil, 2)
      #Explorer.DataFrame<
        Polars[5 x 3]
        open f64 [5.0, 6.0, 7.0, 8.0, 9.0]
        close f64 [2.0, 3.0, 4.0, 5.0, 6.0]
        imi_2 f64 [NaN, 0.0, 0.0, 0.0, 0.0]
      >}
  ## Example Using Series:
      iex> [open, close] = [Explorer.Series.from_list([5.0, 6.0, 7.0, 8.0, 9.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0, 5.0, 6.0])]
      iex> ExTalib.imi(open, close, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[5]
            f64 [NaN, 0.0, 0.0, 0.0, 0.0]
          >
        }}

  ## Example Using Tensors:
      iex> [open, close] = [Nx.tensor([5.0, 6.0, 7.0, 8.0, 9.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0, 5.0, 6.0], type: :f64)]
      iex> ExTalib.imi(open, close, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[5]
            [NaN, 0.0, 0.0, 0.0, 0.0]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec imi(dataframe :: Explorer.DataFrame.t(), nil, time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec imi(open :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def imi(open_or_dataframe, low \\ nil, time_period \\ 14, options \\ [])
  def imi(dataframe, nil, time_period, options) when is_dataframe(dataframe), do: run_df([:imi, options, dataframe, time_period])
  def imi(open, close, time_period, options), do: run([:imi, options, open, close, time_period])
  @doc """
  A bang! version of `imi/4`. It does **not** perform any validations.

  Please refer to `imi/4` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `imi/4`.
  """
  @doc type: :momentum_indicators
  @spec imi!(dataframe :: Explorer.DataFrame.t(), nil, time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec imi!(open :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def imi!(open_or_dataframe, low \\ nil, time_period \\ 14, options \\ [])
  def imi!(dataframe, nil, time_period, options) when is_dataframe(dataframe), do: run_df!([:imi, options, dataframe, time_period])
  def imi!(open, close, time_period, options), do: run!([:imi, options, open, close, time_period])


  @doc """
  Calculates the **Kaufman Adaptive Moving Average** indicator.

  `TA-LIB` source name: `KAMA`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `kama`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.kama(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          kama_2 f64 [NaN, NaN, 4.444444444444445]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.kama(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, 4.444444444444445]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.kama(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, 4.444444444444445]
          >
        }}

  """
  @doc type: :overlap_studies
  @spec kama(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec kama(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def kama(values_or_dataframe, time_period \\ 30, options \\ [])
  def kama(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:kama, options, dataframe, time_period])
  def kama(values, time_period, options), do: run([:kama, options, values, time_period])
  @doc """
  A bang! version of `kama/3`. It does **not** perform any validations.

  Please refer to `kama/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `kama/3`.
  """
  @doc type: :overlap_studies
  @spec kama!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec kama!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def kama!(values_or_dataframe, time_period \\ 30, options \\ [])
  def kama!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:kama, options, dataframe, time_period])
  def kama!(values, time_period, options), do: run!([:kama, options, values, time_period])


  @doc """
  Calculates the **Linear Regression** indicator.

  `TA-LIB` source name: `LINEARREG`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `linearreg`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.linearreg(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          linearreg_2 f64 [NaN, 4.0, 5.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.linearreg(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 4.0, 5.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.linearreg(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 4.0, 5.0]
          >
        }}

  """
  @doc type: :statistic_functions
  @spec linearreg(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec linearreg(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def linearreg(values_or_dataframe, time_period \\ 14, options \\ [])
  def linearreg(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:linearreg, options, dataframe, time_period])
  def linearreg(values, time_period, options), do: run([:linearreg, options, values, time_period])
  @doc """
  A bang! version of `linearreg/3`. It does **not** perform any validations.

  Please refer to `linearreg/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `linearreg/3`.
  """
  @doc type: :statistic_functions
  @spec linearreg!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec linearreg!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def linearreg!(values_or_dataframe, time_period \\ 14, options \\ [])
  def linearreg!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:linearreg, options, dataframe, time_period])
  def linearreg!(values, time_period, options), do: run!([:linearreg, options, values, time_period])


  @doc """
  Calculates the **Linear Regression Angle** indicator.

  `TA-LIB` source name: `LINEARREG_ANGLE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `linearreg_angle`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.linearreg_angle(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          linearreg_angle_2 f64 [NaN, 45.0, 45.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.linearreg_angle(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 45.0, 45.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.linearreg_angle(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 45.0, 45.0]
          >
        }}

  """
  @doc type: :statistic_functions
  @spec linearreg_angle(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec linearreg_angle(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def linearreg_angle(values_or_dataframe, time_period \\ 14, options \\ [])
  def linearreg_angle(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:linearreg_angle, options, dataframe, time_period])
  def linearreg_angle(values, time_period, options), do: run([:linearreg_angle, options, values, time_period])
  @doc """
  A bang! version of `linearreg_angle/3`. It does **not** perform any validations.

  Please refer to `linearreg_angle/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `linearreg_angle/3`.
  """
  @doc type: :statistic_functions
  @spec linearreg_angle!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec linearreg_angle!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def linearreg_angle!(values_or_dataframe, time_period \\ 14, options \\ [])
  def linearreg_angle!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:linearreg_angle, options, dataframe, time_period])
  def linearreg_angle!(values, time_period, options), do: run!([:linearreg_angle, options, values, time_period])


  @doc """
  Calculates the **Linear Regression Intercept** indicator.

  `TA-LIB` source name: `LINEARREG_INTERCEPT`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `linearreg_intercept`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.linearreg_intercept(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          linearreg_intercept_2 f64 [NaN, 3.0, 4.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.linearreg_intercept(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 3.0, 4.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.linearreg_intercept(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 3.0, 4.0]
          >
        }}

  """
  @doc type: :statistic_functions
  @spec linearreg_intercept(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec linearreg_intercept(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def linearreg_intercept(values_or_dataframe, time_period \\ 14, options \\ [])
  def linearreg_intercept(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:linearreg_intercept, options, dataframe, time_period])
  def linearreg_intercept(values, time_period, options), do: run([:linearreg_intercept, options, values, time_period])
  @doc """
  A bang! version of `linearreg_intercept/3`. It does **not** perform any validations.

  Please refer to `linearreg_intercept/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `linearreg_intercept/3`.
  """
  @doc type: :statistic_functions
  @spec linearreg_intercept!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec linearreg_intercept!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def linearreg_intercept!(values_or_dataframe, time_period \\ 14, options \\ [])
  def linearreg_intercept!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:linearreg_intercept, options, dataframe, time_period])
  def linearreg_intercept!(values, time_period, options), do: run!([:linearreg_intercept, options, values, time_period])


  @doc """
  Calculates the **Linear Regression Slope** indicator.

  `TA-LIB` source name: `LINEARREG_SLOPE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `linearreg_slope`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.linearreg_slope(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          linearreg_slope_2 f64 [NaN, 1.0, 1.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.linearreg_slope(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 1.0, 1.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.linearreg_slope(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 1.0, 1.0]
          >
        }}

  """
  @doc type: :statistic_functions
  @spec linearreg_slope(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec linearreg_slope(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def linearreg_slope(values_or_dataframe, time_period \\ 14, options \\ [])
  def linearreg_slope(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:linearreg_slope, options, dataframe, time_period])
  def linearreg_slope(values, time_period, options), do: run([:linearreg_slope, options, values, time_period])
  @doc """
  A bang! version of `linearreg_slope/3`. It does **not** perform any validations.

  Please refer to `linearreg_slope/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `linearreg_slope/3`.
  """
  @doc type: :statistic_functions
  @spec linearreg_slope!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec linearreg_slope!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def linearreg_slope!(values_or_dataframe, time_period \\ 14, options \\ [])
  def linearreg_slope!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:linearreg_slope, options, dataframe, time_period])
  def linearreg_slope!(values, time_period, options), do: run!([:linearreg_slope, options, values, time_period])



  @doc """
  Calculates the **Vector Log Natural** indicator.

  `TA-LIB` source name: `LN`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `ln`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.ln(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 6]
          values f64 [3.0, 4.0, 5.0]
          ln f64 [1.0986122886681098, 1.3862943611198906, 1.6094379124341003]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.ln(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [1.0986122886681098, 1.3862943611198906, 1.6094379124341003]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.ln(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [1.0986122886681098, 1.3862943611198906, 1.6094379124341003]
          >
        }}

  """
  @doc type: :math_transform
  @spec ln(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec ln(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def ln(values_or_dataframe, options \\ [])
  def ln(dataframe, options) when is_dataframe(dataframe), do: run_df([:ln, options, dataframe])
  def ln(values, options), do: run([:ln, options, values])
  @doc """
  A bang! version of `ln/2`. It does **not** perform any validations.

  Please refer to `ln/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `ln/2`.
  """
  @doc type: :math_transform
  @spec ln!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec ln!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def ln!(values_or_dataframe, options \\ [])
  def ln!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:ln, options, dataframe])
  def ln!(values, options), do: run!([:ln, options, values])


  @doc """
  Calculates the **Vector Log10** indicator.

  `TA-LIB` source name: `LOG10`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `log10`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.log10(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 6]
          values f64 [3.0, 4.0, 5.0]
          log10 f64 [0.47712125471966244, 0.6020599913279624, 0.6989700043360189]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.log10(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [0.47712125471966244, 0.6020599913279624, 0.6989700043360189]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.log10(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [0.47712125471966244, 0.6020599913279624, 0.6989700043360189]
          >
        }}

  """
  @doc type: :math_transform
  @spec log10(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec log10(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def log10(values_or_dataframe, options \\ [])
  def log10(dataframe, options) when is_dataframe(dataframe), do: run_df([:log10, options, dataframe])
  def log10(values, options), do: run([:log10, options, values])
  @doc """
  A bang! version of `log10/2`. It does **not** perform any validations.

  Please refer to `log10/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `log10/2`.
  """
  @doc type: :math_transform
  @spec log10!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec log10!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def log10!(values_or_dataframe, options \\ [])
  def log10!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:log10, options, dataframe])
  def log10!(values, options), do: run!([:log10, options, values])


  @doc """
  Calculates the **Moving average** indicator.

  `TA-LIB` source name: `MA`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `ma`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.ma(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          ma_2 f64 [NaN, 3.5, 4.5]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.ma(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 3.5, 4.5]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.ma(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 3.5, 4.5]
          >
        }}

  """
  @doc type: :overlap_studies
  @spec ma(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec ma(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def ma(values_or_dataframe, time_period \\ 30, ma_type \\ :sma, options \\ [])
  def ma(dataframe, time_period, ma_type, options) when is_dataframe(dataframe), do: run_df([:ma, options, dataframe, time_period, ma_type])
  def ma(values, time_period, ma_type, options), do: run([:ma, options, values, time_period, ma_type])
  @doc """
  A bang! version of `ma/4`. It does **not** perform any validations.

  Please refer to `ma/4` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `ma/4`.
  """
  @doc type: :overlap_studies
  @spec ma!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec ma!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def ma!(values_or_dataframe, time_period \\ 30, ma_type \\ :sma, options \\ [])
  def ma!(dataframe, time_period, ma_type, options) when is_dataframe(dataframe), do: run_df!([:ma, options, dataframe, time_period, ma_type])
  def ma!(values, time_period, ma_type, options), do: run!([:ma, options, values, time_period, ma_type])


  @doc """
  Calculates the **Moving Average Convergence/Divergence** indicator.

  `TA-LIB` source name: `MACD`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `macd`, type: `[:f64]`
    - `macdsignal`, type: `[:f64]`
    - `macdhist`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0, 6.0]})
      iex> ExTalib.macd(df, 3, 2, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[4 x 4]
          values f64 [3.0, 4.0, 5.0, 6.0]
          macd_3_2_2 f64 [NaN, NaN, NaN, 0.5]
          macdsignal_3_2_2 f64 [NaN, NaN, NaN, 0.5]
          macdhist_3_2_2 f64 [NaN, NaN, NaN, 0.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0, 6.0])
      iex> ExTalib.macd(series, 3, 2, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[4]
            f64 [NaN, NaN, NaN, 0.5]
          >,
          #Explorer.Series<
            Polars[4]
            f64 [NaN, NaN, NaN, 0.5]
          >,
          #Explorer.Series<
            Polars[4]
            f64 [NaN, NaN, NaN, 0.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0, 6.0], type: :f64)
      iex> ExTalib.macd(tensor, 3, 2, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[4]
            [NaN, NaN, NaN, 0.5]
          >,
          #Nx.Tensor<
            f64[4]
            [NaN, NaN, NaN, 0.5]
          >,
          #Nx.Tensor<
            f64[4]
            [NaN, NaN, NaN, 0.0]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec macd(dataframe :: Explorer.DataFrame.t(), fast_period :: integer(), slow_period :: integer(), signal_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec macd(values :: Explorer.Series.t() | Nx.Tensor.t(), fast_period :: integer(), slow_period :: integer(), signal_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def macd(values_or_dataframe, fast_period \\ 12, slow_period \\ 26, signal_period \\ 9, options \\ [])
  def macd(dataframe, fast_period, slow_period, signal_period, options) when is_dataframe(dataframe), do: run_df([:macd, options, dataframe, fast_period, slow_period, signal_period])
  def macd(values, fast_period, slow_period, signal_period, options), do: run([:macd, options, values, fast_period, slow_period, signal_period])
  @doc """
  A bang! version of `macd/5`. It does **not** perform any validations.

  Please refer to `macd/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `macd/5`.
  """
  @doc type: :momentum_indicators
  @spec macd!(dataframe :: Explorer.DataFrame.t(), fast_period :: integer(), slow_period :: integer(), signal_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec macd!(values :: Explorer.Series.t() | Nx.Tensor.t(), fast_period :: integer(), slow_period :: integer(), signal_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def macd!(values_or_dataframe, fast_period \\ 12, slow_period \\ 26, signal_period \\ 9, options \\ [])
  def macd!(dataframe, fast_period, slow_period, signal_period, options) when is_dataframe(dataframe), do: run_df!([:macd, options, dataframe, fast_period, slow_period, signal_period])
  def macd!(values, fast_period, slow_period, signal_period, options), do: run!([:macd, options, values, fast_period, slow_period, signal_period])


  @doc """
  Calculates the **MACD with controllable MA type** indicator.

  `TA-LIB` source name: `MACDEXT`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `macdext`, type: `[:f64]`
    - `macdextsignal`, type: `[:f64]`
    - `macdexthist`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0, 6.0]})
      iex> ExTalib.macdext(df, 3, :sma, 2, :sma, 2, :sma)
      {:ok,
        #Explorer.DataFrame<
          Polars[4 x 4]
          values f64 [3.0, 4.0, 5.0, 6.0]
          macdext_3_2_2 f64 [NaN, NaN, NaN, 0.5]
          macdextsignal_3_2_2 f64 [NaN, NaN, NaN, 0.5]
          macdexthist_3_2_2 f64 [NaN, NaN, NaN, 0.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0, 6.0])
      iex> ExTalib.macdext(series, 3, :sma, 2, :sma, 2, :sma)
      {:ok,
        {
          #Explorer.Series<
            Polars[4]
            f64 [NaN, NaN, NaN, 0.5]
          >,
          #Explorer.Series<
            Polars[4]
            f64 [NaN, NaN, NaN, 0.5]
          >,
          #Explorer.Series<
            Polars[4]
            f64 [NaN, NaN, NaN, 0.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0, 6.0], type: :f64)
      iex> ExTalib.macdext(tensor, 3, :sma, 2, :sma, 2, :sma)
      {:ok,
        {
          #Nx.Tensor<
            f64[4]
            [NaN, NaN, NaN, 0.5]
          >,
          #Nx.Tensor<
            f64[4]
            [NaN, NaN, NaN, 0.5]
          >,
          #Nx.Tensor<
            f64[4]
            [NaN, NaN, NaN, 0.0]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec macdext(dataframe :: Explorer.DataFrame.t(), fast_period :: integer(), fast_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, slow_period :: integer(), slow_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, signal_period :: integer(), signal_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec macdext(values :: Explorer.Series.t() | Nx.Tensor.t(), fast_period :: integer(), fast_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, slow_period :: integer(), slow_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, signal_period :: integer(), signal_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def macdext(values_or_dataframe, fast_period \\ 12, fast_ma \\ :sma, slow_period \\ 26, slow_ma \\ :sma, signal_period \\ 9, signal_ma \\ :sma, options \\ [])
  def macdext(dataframe, fast_period, fast_ma, slow_period, slow_ma, signal_period, signal_ma, options) when is_dataframe(dataframe), do: run_df([:macdext, options, dataframe, fast_period, fast_ma, slow_period, slow_ma, signal_period, signal_ma])
  def macdext(values, fast_period, fast_ma, slow_period, slow_ma, signal_period, signal_ma, options), do: run([:macdext, options, values, fast_period, fast_ma, slow_period, slow_ma, signal_period, signal_ma])
  @doc """
  A bang! version of `macdext/8`. It does **not** perform any validations.

  Please refer to `macdext/8` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `macdext/8`.
  """
  @doc type: :momentum_indicators
  @spec macdext!(dataframe :: Explorer.DataFrame.t(), fast_period :: integer(), fast_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, slow_period :: integer(), slow_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, signal_period :: integer(), signal_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec macdext!(values :: Explorer.Series.t() | Nx.Tensor.t(), fast_period :: integer(), fast_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, slow_period :: integer(), slow_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, signal_period :: integer(), signal_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def macdext!(values_or_dataframe, fast_period \\ 12, fast_ma \\ :sma, slow_period \\ 26, slow_ma \\ :sma, signal_period \\ 9, signal_ma \\ :sma, options \\ [])
  def macdext!(dataframe, fast_period, fast_ma, slow_period, slow_ma, signal_period, signal_ma, options) when is_dataframe(dataframe), do: run_df!([:macdext, options, dataframe, fast_period, fast_ma, slow_period, slow_ma, signal_period, signal_ma])
  def macdext!(values, fast_period, fast_ma, slow_period, slow_ma, signal_period, signal_ma, options), do: run!([:macdext, options, values, fast_period, fast_ma, slow_period, slow_ma, signal_period, signal_ma])


  @doc """
  Calculates the **Moving Average Convergence/Divergence Fix 12/26** indicator.

  `TA-LIB` source name: `MACDFIX`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `macdfix`, type: `[:f64]`
    - `macdfixsignal`, type: `[:f64]`
    - `macdfixhist`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0, 6.0]})
      iex> ExTalib.macdfix(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[4 x 4]
          values f64 [3.0, 4.0, 5.0, 6.0]
          macdfix_2 f64 [NaN, NaN, NaN, NaN]
          macdfixsignal_2 f64 [NaN, NaN, NaN, NaN]
          macdfixhist_2 f64 [NaN, NaN, NaN, NaN]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0, 6.0])
      iex> ExTalib.macdfix(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[4]
            f64 [NaN, NaN, NaN, NaN]
          >,
          #Explorer.Series<
            Polars[4]
            f64 [NaN, NaN, NaN, NaN]
          >,
          #Explorer.Series<
            Polars[4]
            f64 [NaN, NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0, 6.0], type: :f64)
      iex> ExTalib.macdfix(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[4]
            [NaN, NaN, NaN, NaN]
          >,
          #Nx.Tensor<
            f64[4]
            [NaN, NaN, NaN, NaN]
          >,
          #Nx.Tensor<
            f64[4]
            [NaN, NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec macdfix(dataframe :: Explorer.DataFrame.t(), signal_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec macdfix(values :: Explorer.Series.t() | Nx.Tensor.t(), signal_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def macdfix(values_or_dataframe, signal_period \\ 9, options \\ [])
  def macdfix(dataframe, signal_period, options) when is_dataframe(dataframe), do: run_df([:macdfix, options, dataframe, signal_period])
  def macdfix(values, signal_period, options), do: run([:macdfix, options, values, signal_period])
  @doc """
  A bang! version of `macdfix/3`. It does **not** perform any validations.

  Please refer to `macdfix/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `macdfix/3`.
  """
  @doc type: :momentum_indicators
  @spec macdfix!(dataframe :: Explorer.DataFrame.t(), signal_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec macdfix!(values :: Explorer.Series.t() | Nx.Tensor.t(), signal_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def macdfix!(values_or_dataframe, signal_period \\ 9, options \\ [])
  def macdfix!(dataframe, signal_period, options) when is_dataframe(dataframe), do: run_df!([:macdfix, options, dataframe, signal_period])
  def macdfix!(values, signal_period, options), do: run!([:macdfix, options, values, signal_period])


  @doc """
  Calculates the **MESA Adaptive Moving Average** indicator.

  `TA-LIB` source name: `MAMA`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `mama`, type: `[:f64]`
    - `fama`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0, 6.0]})
      iex> ExTalib.mama(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[4 x 3]
          values f64 [3.0, 4.0, 5.0, 6.0]
          mama_0.5_0.05 f64 [NaN, NaN, NaN, NaN]
          fama_0.5_0.05 f64 [NaN, NaN, NaN, NaN]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0, 6.0])
      iex> ExTalib.mama(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[4]
            f64 [NaN, NaN, NaN, NaN]
          >,
          #Explorer.Series<
            Polars[4]
            f64 [NaN, NaN, NaN, NaN]
          >,
          #Explorer.Series<
            Polars[4]
            f64 [NaN, NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0, 6.0], type: :f64)
      iex> ExTalib.mama(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[4]
            [NaN, NaN, NaN, NaN]
          >,
          #Nx.Tensor<
            f64[4]
            [NaN, NaN, NaN, NaN]
          >,
          #Nx.Tensor<
            f64[4]
            [NaN, NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :overlap_studies
  @spec mama(dataframe :: Explorer.DataFrame.t(), fast_limit :: float(), slow_limit :: float(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec mama(values :: Explorer.Series.t() | Nx.Tensor.t(), fast_limit :: float(), slow_limit :: float(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def mama(values_or_dataframe, fast_limit \\ 0.5, slow_limit \\ 0.05, options \\ [])
  def mama(dataframe, fast_limit, slow_limit, options) when is_dataframe(dataframe), do: run_df([:mama, options, dataframe, fast_limit, slow_limit])
  def mama(values, fast_limit, slow_limit, options), do: run([:mama, options, values, fast_limit, slow_limit])
  @doc """
  A bang! version of `mama/4`. It does **not** perform any validations.

  Please refer to `mama/4` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `mama/4`.
  """
  @doc type: :overlap_studies
  @spec mama!(dataframe :: Explorer.DataFrame.t(), fast_limit :: float(), slow_limit :: float(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec mama!(values :: Explorer.Series.t() | Nx.Tensor.t(), fast_limit :: float(), slow_limit :: float(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def mama!(values_or_dataframe, fast_limit \\ 0.5, slow_limit \\ 0.05, options \\ [])
  def mama!(dataframe, fast_limit, slow_limit, options) when is_dataframe(dataframe), do: run_df!([:mama, options, dataframe, fast_limit, slow_limit])
  def mama!(values, fast_limit, slow_limit, options), do: run!([:mama, options, values, fast_limit, slow_limit])


  @doc """
  Calculates the **Moving average with variable period** indicator.

  `TA-LIB` source name: `MAVP`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`, `periods`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `mavp`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [5.0, 6.0, 7.0], periods: [2.0, 2.0, 2.0]})
      iex> ExTalib.mavp(df, nil, 2, 2, :sma)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 3]
          values f64 [5.0, 6.0, 7.0]
          periods f64 [2.0, 2.0, 2.0]
          mavp_2_2 f64 [NaN, 5.5, 6.5]
        >}
  ## Example Using Series:
      iex> [values, periods] = [Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 2.0, 2.0])]
      iex> ExTalib.mavp(values, periods, 2, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 5.5, 6.5]
          >
        }}

  ## Example Using Tensors:
      iex> [values, periods] = [Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 2.0, 2.0], type: :f64)]
      iex> ExTalib.mavp(values, periods, 2, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 5.5, 6.5]
          >
        }}

  """
  @doc type: :overlap_studies
  @spec mavp(dataframe :: Explorer.DataFrame.t(), nil, minimum_period :: integer(), time_period :: integer(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec mavp(values :: Explorer.Series.t() | Nx.Tensor.t(), periods :: Explorer.Series.t() | Nx.Tensor.t(), minimum_period :: integer(), maximum_period :: integer(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def mavp(values_or_dataframe, periods \\ nil, minimum_period \\ 2, maximum_period \\ 30, ma_type \\ :sma, options \\ [])
  def mavp(dataframe, nil, minimum_period, maximum_period, ma_type, options) when is_dataframe(dataframe), do: run_df([:mavp, options, dataframe, minimum_period, maximum_period, ma_type])
  def mavp(values, periods, minimum_period, maximum_period, ma_type, options), do: run([:mavp, options, values, periods, minimum_period, maximum_period, ma_type])
  @doc """
  A bang! version of `mavp/6`. It does **not** perform any validations.

  Please refer to `mavp/6` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `mavp/6`.
  """
  @doc type: :overlap_studies
  @spec mavp!(dataframe :: Explorer.DataFrame.t(), nil, minimum_period :: integer(), maximum_period :: integer(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec mavp!(values :: Explorer.Series.t() | Nx.Tensor.t(), periods :: Explorer.Series.t() | Nx.Tensor.t(), minimum_period :: integer(), maximum_period :: integer(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def mavp!(values_or_dataframe, periods \\ nil, minimum_period \\ 2, maximum_period \\ 30, ma_type \\ :sma, options \\ [])
  def mavp!(dataframe, nil, minimum_period, maximum_period, ma_type, options) when is_dataframe(dataframe), do: run_df!([:mavp, options, dataframe, minimum_period, maximum_period, ma_type])
  def mavp!(values, periods, minimum_period, maximum_period, ma_type, options), do: run!([:mavp, options, values, periods, minimum_period, maximum_period, ma_type])


  @doc """
  Calculates the **Highest value over a specified period**.

  `TA-LIB` source name: `MAX`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `max`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 5.0, 4.0]})
      iex> ExTalib.max(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 5.0, 4.0]
          max_2 f64 [NaN, 5.0, 5.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 5.0, 4.0], dtype: {:f, 64})
      iex> ExTalib.max(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 5.0, 5.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 5.0, 4.0], type: :f64)
      iex> ExTalib.max(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 5.0, 5.0]
          >
        }}

  """
  @doc type: :math_operators
  @spec max(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec max(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def max(values_or_dataframe, time_period \\ 30, options \\ [])
  def max(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:max, options, dataframe, time_period])
  def max(values, time_period, options), do: run([:max, options, values, time_period])
  @doc """
  A bang! version of `max/3`. It does **not** perform any validations.

  Please refer to `max/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `max/3`.
  """
  @doc type: :math_operators
  @spec max!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec max!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def max!(values_or_dataframe, time_period \\ 30, options \\ [])
  def max!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:max, options, dataframe, time_period])
  def max!(values, time_period, options), do: run!([:max, options, values, time_period])


  @doc """
  Calculates the **Index of highest value over a specified period**.

  `TA-LIB` source name: `MAXINDEX`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `maxindex`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 5.0, 4.0]})
      iex> ExTalib.maxindex(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 5.0, 4.0]
          maxindex_2 f64 [NaN, 1.0, 1.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 5.0, 4.0], dtype: {:f, 64})
      iex> ExTalib.maxindex(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 1.0, 1.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 5.0, 4.0], type: :f64)
      iex> ExTalib.maxindex(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 1.0, 1.0]
          >
        }}

  """
  @doc type: :math_operators
  @spec maxindex(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec maxindex(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def maxindex(values_or_dataframe, time_period \\ 30, options \\ [])
  def maxindex(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:maxindex, options, dataframe, time_period])
  def maxindex(values, time_period, options), do: run([:maxindex, options, values, time_period])
  @doc """
  A bang! version of `maxindex/3`. It does **not** perform any validations.

  Please refer to `maxindex/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `maxindex/3`.
  """
  @doc type: :math_operators
  @spec maxindex!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec maxindex!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def maxindex!(values_or_dataframe, time_period \\ 30, options \\ [])
  def maxindex!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:maxindex, options, dataframe, time_period])
  def maxindex!(values, time_period, options), do: run!([:maxindex, options, values, time_period])


  @doc """
  Calculates the **Median Price**.

  `TA-LIB` source name: `MEDPRICE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `medprice`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0, 8.0, 9.0], low: [2.0, 3.0, 4.0, 5.0, 6.0]})
      iex> ExTalib.medprice(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[5 x 3]
          high f64 [5.0, 6.0, 7.0, 8.0, 9.0]
          low f64 [2.0, 3.0, 4.0, 5.0, 6.0]
          medprice f64 [3.5, 4.5, 5.5, 6.5, 7.5]
        >}
  ## Example Using Series:
      iex> [high, low] = [Explorer.Series.from_list([5.0, 6.0, 7.0, 8.0, 9.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0, 5.0, 6.0], dtype: {:f, 64})]
      iex> ExTalib.medprice(high, low)
      {:ok,
        {
          #Explorer.Series<
            Polars[5]
            f64 [3.5, 4.5, 5.5, 6.5, 7.5]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low] = [Nx.tensor([5.0, 6.0, 7.0, 8.0, 9.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0, 5.0, 6.0], type: :f64)]
      iex> ExTalib.medprice(high, low)
      {:ok,
        {
          #Nx.Tensor<
            f64[5]
            [3.5, 4.5, 5.5, 6.5, 7.5]
          >
        }}

  """
  @doc type: :price_transform
  @spec medprice(dataframe :: Explorer.DataFrame.t(), nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec medprice(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def medprice(high_or_dataframe, low \\ nil, options \\ [])
  def medprice(dataframe, nil, options) when is_dataframe(dataframe), do: run_df([:medprice, options, dataframe])
  def medprice(high, low, options), do: run([:medprice, options, high, low])
  @doc """
  A bang! version of `medprice/3`. It does **not** perform any validations.

  Please refer to `medprice/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `dmedpricex/3`.
  """
  @doc type: :price_transform
  @spec medprice!(dataframe :: Explorer.DataFrame.t(), nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec medprice!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def medprice!(high_or_dataframe, low \\ nil,  options \\ [])
  def medprice!(dataframe, nil, options) when is_dataframe(dataframe), do: run_df!([:medprice, options, dataframe])
  def medprice!(high, low, options), do: run!([:medprice, options, high, low])


  @doc """
  Calculates the **Money Flow Index** indicator.

  `TA-LIB` source name: `MFI`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`, `close`, `volume`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `mfi`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0], volume: [10.0, 11.0, 12.0]})
      iex> ExTalib.mfi(df, nil, nil, nil, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          volume f64 [10.0, 11.0, 12.0]
          mfi_2 f64 [NaN, NaN, 100.0]
        >}
  ## Example Using Series:
      iex> [high, low, close, volume] = [Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64}), Explorer.Series.from_list([10.0, 11.0, 12.0], dtype: {:f, 64})]
      iex> ExTalib.mfi(high, low, close, volume, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, 100.0]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low, close, volume] = [Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0], type: :f64), Nx.tensor([10.0, 11.0, 12.0], type: :f64)]
      iex> ExTalib.mfi(high, low, close, volume, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, 100.0]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec mfi(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec mfi(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), volume :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def mfi(high_or_dataframe, low \\ nil, close \\ nil, volume \\ nil, time_period \\ 14, options \\ [])
  def mfi(dataframe, nil, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df([:mfi, options, dataframe, time_period])
  def mfi(high, low, close, volume, time_period, options), do: run([:mfi, options, high, low, close, volume, time_period])
  @doc """
  A bang! version of `mfi/6`. It does **not** perform any validations.

  Please refer to `mfi/6` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `mfi/6`.
  """
  @doc type: :momentum_indicators
  @spec mfi!(dataframe :: Explorer.DataFrame.t(), nil, nil, nil, time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec mfi!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), volume :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def mfi!(high_or_dataframe, low \\ nil, close \\ nil, volume \\ nil, time_period \\ 14, options \\ [])
  def mfi!(dataframe, nil, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df!([:mfi, options, dataframe, time_period])
  def mfi!(high, low, close, volume, time_period, options), do: run!([:mfi, options, high, low, close, volume, time_period])


  @doc """
  Calculates the **MidPoint over period**.

  `TA-LIB` source name: `MIDPOINT`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `midpoint`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 5.0, 4.0]})
      iex> ExTalib.midpoint(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 5.0, 4.0]
          midpoint_2 f64 [NaN, 4.0, 4.5]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 5.0, 4.0], dtype: {:f, 64})
      iex> ExTalib.midpoint(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 4.0, 4.5]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 5.0, 4.0], type: :f64)
      iex> ExTalib.midpoint(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 4.0, 4.5]
          >
        }}

  """
  @doc type: :overlap_studies
  @spec midpoint(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec midpoint(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def midpoint(values_or_dataframe, time_period \\ 30, options \\ [])
  def midpoint(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:midpoint, options, dataframe, time_period])
  def midpoint(values, time_period, options), do: run([:midpoint, options, values, time_period])
  @doc """
  A bang! version of `midpoint/3`. It does **not** perform any validations.

  Please refer to `midpoint/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `midpoint/3`.
  """
  @doc type: :overlap_studies
  @spec midpoint!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec midpoint!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def midpoint!(values_or_dataframe, time_period \\ 30, options \\ [])
  def midpoint!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:midpoint, options, dataframe, time_period])
  def midpoint!(values, time_period, options), do: run!([:midpoint, options, values, time_period])


  @doc """
  Calculates the **Midpoint Price over period**.

  `TA-LIB` source name: `MIDPRICE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `midprice`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0, 8.0, 9.0], low: [2.0, 3.0, 4.0, 5.0, 6.0]})
      iex> ExTalib.midprice(df, nil, 2)
      #Explorer.DataFrame<
        Polars[5 x 3]
        high f64 [5.0, 6.0, 7.0, 8.0, 9.0]
        low f64 [2.0, 3.0, 4.0, 5.0, 6.0]
        midprice_2 f64 [NaN, 4.0, 5.0, 6.0, 7.0]
      >}
  ## Example Using Series:
      iex> [high, low] = [Explorer.Series.from_list([5.0, 6.0, 7.0, 8.0, 9.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0, 5.0, 6.0])]
      iex> ExTalib.midprice(high, low, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[5]
            f64 [NaN, 4.0, 5.0, 6.0, 7.0]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low] = [Nx.tensor([5.0, 6.0, 7.0, 8.0, 9.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0, 5.0, 6.0], type: :f64)]
      iex> ExTalib.midprice(high, low, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[5]
            [NaN, 4.0, 5.0, 6.0, 7.0]
          >
        }}

  """
  @doc type: :overlap_studies
  @spec midprice(dataframe :: Explorer.DataFrame.t(), nil, time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec midprice(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def midprice(high_or_dataframe, low \\ nil, time_period \\ 14, options \\ [])
  def midprice(dataframe, nil, time_period, options) when is_dataframe(dataframe), do: run_df([:midprice, options, dataframe, time_period])
  def midprice(high, low, time_period, options), do: run([:midprice, options, high, low, time_period])
  @doc """
  A bang! version of `midprice/4`. It does **not** perform any validations.

  Please refer to `midprice/4` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `midprice/4`.
  """
  @doc type: :overlap_studies
  @spec midprice!(dataframe :: Explorer.DataFrame.t(), nil, time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec midprice!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def midprice!(high_or_dataframe, low \\ nil, time_period \\ 14, options \\ [])
  def midprice!(dataframe, nil, time_period, options) when is_dataframe(dataframe), do: run_df!([:midprice, options, dataframe, time_period])
  def midprice!(high, low, time_period, options), do: run!([:midprice, options, high, low, time_period])


  @doc """
  Calculates the **Lowest value over a specified period**.

  `TA-LIB` source name: `MIN`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `min`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 5.0, 4.0]})
      iex> ExTalib.min(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 5.0, 4.0]
          min_2 f64 [NaN, 3.0, 4.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 5.0, 4.0], dtype: {:f, 64})
      iex> ExTalib.min(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 3.0, 4.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 5.0, 4.0], type: :f64)
      iex> ExTalib.min(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 3.0, 4.0]
          >
        }}

  """
  @doc type: :math_operators
  @spec min(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec min(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def min(values_or_dataframe, time_period \\ 30, options \\ [])
  def min(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:min, options, dataframe, time_period])
  def min(values, time_period, options), do: run([:min, options, values, time_period])
  @doc """
  A bang! version of `min/3`. It does **not** perform any validations.

  Please refer to `min/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `min/3`.
  """
  @doc type: :math_operators
  @spec min!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec min!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def min!(values_or_dataframe, time_period \\ 30, options \\ [])
  def min!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:min, options, dataframe, time_period])
  def min!(values, time_period, options), do: run!([:min, options, values, time_period])


  @doc """
  Calculates the **Index of lowest value over a specified period**.

  `TA-LIB` source name: `MININDEX`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `minindex`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 5.0, 4.0]})
      iex> ExTalib.minindex(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 5.0, 4.0]
          minindex_2 f64 [NaN, 0.0, 2.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 5.0, 4.0], dtype: {:f, 64})
      iex> ExTalib.minindex(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 0.0, 2.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 5.0, 4.0], type: :f64)
      iex> ExTalib.minindex(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 0.0, 2.0]
          >
        }}

  """
  @doc type: :math_operators
  @spec minindex(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec minindex(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def minindex(values_or_dataframe, time_period \\ 30, options \\ [])
  def minindex(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:minindex, options, dataframe, time_period])
  def minindex(values, time_period, options), do: run([:minindex, options, values, time_period])
  @doc """
  A bang! version of `minindex/3`. It does **not** perform any validations.

  Please refer to `minindex/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `minindex/3`.
  """
  @doc type: :math_operators
  @spec minindex!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec minindex!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def minindex!(values_or_dataframe, time_period \\ 30, options \\ [])
  def minindex!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:minindex, options, dataframe, time_period])
  def minindex!(values, time_period, options), do: run!([:minindex, options, values, time_period])


  @doc """
  Calculates the **Lowest and highest values over a specified period**.

  `TA-LIB` source name: `MINMAX`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `min`, type: `[:f64]`
    - `max`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 5.0, 4.0]})
      iex> ExTalib.minmax(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 3]
          values f64 [3.0, 5.0, 4.0]
          min_2 f64 [NaN, 3.0, 4.0]
          max_2 f64 [NaN, 5.0, 5.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 5.0, 4.0], dtype: {:f, 64})
      iex> ExTalib.minmax(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 3.0, 4.0]
          >,
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 5.0, 5.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 5.0, 4.0], type: :f64)
      iex> ExTalib.minmax(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 3.0, 4.0]
          >,
          #Nx.Tensor<
            f64[3]
            [NaN, 5.0, 5.0]
          >
        }}

  """
  @doc type: :math_operators
  @spec minmax(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec minmax(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def minmax(values_or_dataframe, time_period \\ 30, options \\ [])
  def minmax(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:minmax, options, dataframe, time_period])
  def minmax(values, time_period, options), do: run([:minmax, options, values, time_period])
  @doc """
  A bang! version of `minmax/3`. It does **not** perform any validations.

  Please refer to `minmax/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `minmax/3`.
  """
  @doc type: :math_operators
  @spec minmax!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec minmax!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def minmax!(values_or_dataframe, time_period \\ 30, options \\ [])
  def minmax!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:minmax, options, dataframe, time_period])
  def minmax!(values, time_period, options), do: run!([:minmax, options, values, time_period])


  @doc """
  Calculates the **Indexes of lowest and highest values over a specified period**.

  `TA-LIB` source name: `MINMAXINDEX`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `minidx`, type: `[:f64]`
    - `maxidx`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 5.0, 4.0]})
      iex> ExTalib.minmaxindex(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 3]
          values f64 [3.0, 5.0, 4.0]
          minidx_2 f64 [NaN, 0.0, 2.0]
          maxidx_2 f64 [NaN, 1.0, 1.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 5.0, 4.0], dtype: {:f, 64})
      iex> ExTalib.minmaxindex(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 0.0, 2.0]
          >,
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 1.0, 1.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 5.0, 4.0], type: :f64)
      iex> ExTalib.minmaxindex(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 0.0, 2.0]
          >,
          #Nx.Tensor<
            f64[3]
            [NaN, 1.0, 1.0]
          >
        }}

  """
  @doc type: :math_operators
  @spec minmaxindex(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec minmaxindex(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def minmaxindex(values_or_dataframe, time_period \\ 30, options \\ [])
  def minmaxindex(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:minmaxindex, options, dataframe, time_period])
  def minmaxindex(values, time_period, options), do: run([:minmaxindex, options, values, time_period])
  @doc """
  A bang! version of `minmaxindex/3`. It does **not** perform any validations.

  Please refer to `minmaxindex/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `minmaxindex/3`.
  """
  @doc type: :math_operators
  @spec minmaxindex!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec minmaxindex!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def minmaxindex!(values_or_dataframe, time_period \\ 30, options \\ [])
  def minmaxindex!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:minmaxindex, options, dataframe, time_period])
  def minmaxindex!(values, time_period, options), do: run!([:minmaxindex, options, values, time_period])


  @doc """
  Calculates the **Minus Directional Indicator**.

  `TA-LIB` source name: `MINUS_DI`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `minus_di`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0, 8.0, 9.0], low: [2.0, 3.0, 4.0, 5.0, 6.0], close: [3.0, 4.0, 5.0, 6.0, 7.0]})
      iex> ExTalib.minus_di(df, nil ,nil, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[5 x 4]
          close f64 [3.0, 4.0, 5.0, 6.0, 7.0]
          high f64 [5.0, 6.0, 7.0, 8.0, 9.0]
          low f64 [2.0, 3.0, 4.0, 5.0, 6.0]
          minus_di_2 f64 [NaN, NaN, 0.0, 0.0, 0.0]
        >}
  ## Example Using Series:
      iex> [high, low, close] = [Explorer.Series.from_list([5.0, 6.0, 7.0, 8.0, 9.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0, 6.0, 7.0], dtype: {:f, 64})]
      iex> ExTalib.minus_di(high, low, close, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[5]
            f64 [NaN, NaN, 0.0, 0.0, 0.0]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low, close] = [Nx.tensor([5.0, 6.0, 7.0, 8.0, 9.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0, 5.0, 6.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0, 6.0, 7.0], type: :f64)]
      iex> ExTalib.minus_di(high, low, close, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[5]
            [NaN, NaN, 0.0, 0.0, 0.0]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec minus_di(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec minus_di(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def minus_di(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 14, options \\ [])
  def minus_di(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df([:minus_di, options, dataframe, time_period])
  def minus_di(high, low, close, time_period, options), do: run([:minus_di, options, high, low, close, time_period])
  @doc """
  A bang! version of `minus_di/5`. It does **not** perform any validations.

  Please refer to `minus_di/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `minus_di/5`.
  """
  @doc type: :momentum_indicators
  @spec minus_di!(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec minus_di!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def minus_di!(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 14, options \\ [])
  def minus_di!(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df!([:minus_di, options, dataframe, time_period])
  def minus_di!(high, low, close, time_period, options), do: run!([:minus_di, options, high, low, close, time_period])


  @doc """
  Calculates the **Minus Directional Movement**.

  `TA-LIB` source name: `MINUS_DM`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `minus_dm`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0, 8.0, 9.0], low: [2.0, 3.0, 4.0, 5.0, 6.0]})
      iex> ExTalib.minus_dm(df, nil, 2)
      #Explorer.DataFrame<
        Polars[5 x 3]
        high f64 [5.0, 6.0, 7.0, 8.0, 9.0]
        low f64 [2.0, 3.0, 4.0, 5.0, 6.0]
        minus_dm_2 f64 [NaN, 0.0, 0.0, 0.0, 0.0]
      >}
  ## Example Using Series:
      iex> [high, low] = [Explorer.Series.from_list([5.0, 6.0, 7.0, 8.0, 9.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0, 5.0, 6.0])]
      iex> ExTalib.minus_dm(high, low, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[5]
            f64 [NaN, 0.0, 0.0, 0.0, 0.0]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low] = [Nx.tensor([5.0, 6.0, 7.0, 8.0, 9.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0, 5.0, 6.0], type: :f64)]
      iex> ExTalib.minus_dm(high, low, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[5]
            [NaN, 0.0, 0.0, 0.0, 0.0]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec minus_dm(dataframe :: Explorer.DataFrame.t(), nil, time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec minus_dm(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def minus_dm(high_or_dataframe, low \\ nil, time_period \\ 14, options \\ [])
  def minus_dm(dataframe, nil, time_period, options) when is_dataframe(dataframe), do: run_df([:minus_dm, options, dataframe, time_period])
  def minus_dm(high, low, time_period, options), do: run([:minus_dm, options, high, low, time_period])
  @doc """
  A bang! version of `minus_dm/4`. It does **not** perform any validations.

  Please refer to `minus_dm/4` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `minus_dm/4`.
  """
  @doc type: :momentum_indicators
  @spec minus_dm!(dataframe :: Explorer.DataFrame.t(), nil, time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec minus_dm!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def minus_dm!(high_or_dataframe, low \\ nil, time_period \\ 14, options \\ [])
  def minus_dm!(dataframe, nil, time_period, options) when is_dataframe(dataframe), do: run_df!([:minus_dm, options, dataframe, time_period])
  def minus_dm!(high, low, time_period, options), do: run!([:minus_dm, options, high, low, time_period])


  @doc """
  Calculates the **Momentum** indicator.

  `TA-LIB` source name: `MOM`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `mom`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.mom(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          mom_2 f64 [NaN, NaN, 2.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.mom(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, 2.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.mom(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, 2.0]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec mom(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec mom(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def mom(values_or_dataframe, time_period \\ 30, options \\ [])
  def mom(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:mom, options, dataframe, time_period])
  def mom(values, time_period, options), do: run([:mom, options, values, time_period])
  @doc """
  A bang! version of `mom/3`. It does **not** perform any validations.

  Please refer to `mom/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `mom/3`.
  """
  @doc type: :momentum_indicators
  @spec mom!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec mom!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def mom!(values_or_dataframe, time_period \\ 30, options \\ [])
  def mom!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:mom, options, dataframe, time_period])
  def mom!(values, time_period, options), do: run!([:mom, options, values, time_period])


  @doc """
  Calculates the **Vector Arithmetic Mult** indicator.

  `TA-LIB` source name: `MULT`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values_a`, `values_b`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `mult`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values_a: [5.0, 6.0, 7.0], values_b: [2.0, 3.0, 4.0]})
      iex> ExTalib.mult(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 3]
          values_a f64 [5.0, 6.0, 7.0]
          values_b f64 [2.0, 3.0, 4.0]
          mult f64 [10.0, 18.0, 28.0]
        >}
  ## Example Using Series:
      iex> [values_a, values_b] = [Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0])]
      iex> ExTalib.mult(values_a, values_b)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [10.0, 18.0, 28.0]
          >
        }}

  ## Example Using Tensors:
      iex> [values_a, values_b] = [Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64)]
      iex> ExTalib.mult(values_a, values_b)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [10.0, 18.0, 28.0]
          >
        }}

  """
  @doc type: :math_operators
  @spec mult(dataframe :: Explorer.DataFrame.t(), nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec mult(values_a :: Explorer.Series.t() | Nx.Tensor.t(), values_b :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def mult(values_a_or_dataframe, values_b \\ nil, options \\ [])
  def mult(dataframe, nil, options) when is_dataframe(dataframe), do: run_df([:mult, options, dataframe])
  def mult(values_a, values_b, options), do: run([:mult, options, values_a, values_b])
  @doc """
  A bang! version of `mult/3`. It does **not** perform any validations.

  Please refer to `mult/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `mult/3`.
  """
  @doc type: :math_operators
  @spec mult!(dataframe :: Explorer.DataFrame.t(), nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec mult!(values_a :: Explorer.Series.t() | Nx.Tensor.t(), values_b :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def mult!(values_a_or_dataframe, values_b \\ nil, options \\ [])
  def mult!(dataframe, nil, options) when is_dataframe(dataframe), do: run_df!([:mult, options, dataframe])
  def mult!(values_a, values_b, options), do: run!([:mult, options, values_a, values_b])


  @doc """
  Calculates the **Normalized Average True Range**.

  `TA-LIB` source name: `NATR`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `natr`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0, 8.0, 9.0], low: [2.0, 3.0, 4.0, 5.0, 6.0], close: [3.0, 4.0, 5.0, 6.0, 7.0]})
      iex> ExTalib.natr(df, nil ,nil, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[5 x 4]
          close f64 [3.0, 4.0, 5.0, 6.0, 7.0]
          high f64 [5.0, 6.0, 7.0, 8.0, 9.0]
          low f64 [2.0, 3.0, 4.0, 5.0, 6.0]
          natr_2 f64 [NaN, NaN, 60.0, 50.0, 42.857142857142854]
        >}
  ## Example Using Series:
      iex> [high, low, close] = [Explorer.Series.from_list([5.0, 6.0, 7.0, 8.0, 9.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0, 6.0, 7.0], dtype: {:f, 64})]
      iex> ExTalib.natr(high, low, close, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[5]
            f64 [NaN, NaN, 60.0, 50.0, 42.857142857142854]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low, close] = [Nx.tensor([5.0, 6.0, 7.0, 8.0, 9.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0, 5.0, 6.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0, 6.0, 7.0], type: :f64)]
      iex> ExTalib.natr(high, low, close, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[5]
            [NaN, NaN, 60.0, 50.0, 42.857142857142854]
          >
        }}

  """
  @doc type: :volatility_indicators
  @spec natr(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec natr(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def natr(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 14, options \\ [])
  def natr(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df([:natr, options, dataframe, time_period])
  def natr(high, low, close, time_period, options), do: run([:natr, options, high, low, close, time_period])
  @doc """
  A bang! version of `natr/5`. It does **not** perform any validations.

  Please refer to `natr/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `natr/5`.
  """
  @doc type: :volatility_indicators
  @spec natr!(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec natr!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def natr!(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 14, options \\ [])
  def natr!(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df!([:natr, options, dataframe, time_period])
  def natr!(high, low, close, time_period, options), do: run!([:natr, options, high, low, close, time_period])


  @doc """
  Calculates the **On Balance Volume** indicator.

  `TA-LIB` source name: `OBV`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`, `volume`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `obv`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0], volume: [100.0, 120.0, 150.0]})
      iex> ExTalib.obv(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 6]
          values f64 [3.0, 4.0, 5.0]
          obv f64 [100.0, 220.0, 370.0]
        >}

  ## Example Using Series:
      iex> [values, volume] = [Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64}), Explorer.Series.from_list([100.0, 120.0, 150.0], dtype: {:f, 64})]
      iex> ExTalib.obv(values, volume)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [100.0, 220.0, 370.0]
          >
        }}

  ## Example Using Tensors:
      iex> [values, volume] = [Nx.tensor([3.0, 4.0, 5.0], type: :f64), Nx.tensor([100.0, 120.0, 150.0], type: :f64)]
      iex> ExTalib.obv(values, volume)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [100.0, 220.0, 370.0]
          >
        }}

  """
  @doc type: :volume_indicators
  @spec obv(dataframe :: Explorer.DataFrame.t(), nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec obv(values :: Explorer.Series.t() | Nx.Tensor.t(), volume :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def obv(values_or_dataframe, volume \\ nil, options \\ [])
  def obv(dataframe, nil, options) when is_dataframe(dataframe), do: run_df([:obv, options, dataframe])
  def obv(values, volume, options), do: run([:obv, options, values, volume])
  @doc """
  A bang! version of `obv/3`. It does **not** perform any validations.

  Please refer to `obv/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `obv/3`.
  """
  @doc type: :volume_indicators
  @spec obv!(dataframe :: Explorer.DataFrame.t(), nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec obv!(values :: Explorer.Series.t() | Nx.Tensor.t(), volume :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def obv!(values_or_dataframe, volume \\ nil, options \\ [])
  def obv!(dataframe, nil, options) when is_dataframe(dataframe), do: run_df!([:obv, options, dataframe])
  def obv!(values, volume, options), do: run!([:obv, options, values, volume])


  @doc """
  Calculates the **Plus Directional Indicator**.

  `TA-LIB` source name: `PLUS_DI`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `plus_di`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0, 8.0, 9.0], low: [2.0, 3.0, 4.0, 5.0, 6.0], close: [3.0, 4.0, 5.0, 6.0, 7.0]})
      iex> ExTalib.plus_di(df, nil ,nil, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[5 x 4]
          close f64 [3.0, 4.0, 5.0, 6.0, 7.0]
          high f64 [5.0, 6.0, 7.0, 8.0, 9.0]
          low f64 [2.0, 3.0, 4.0, 5.0, 6.0]
          plus_di_2 f64 [NaN, NaN, 33.33333333333333, 33.33333333333333, 33.33333333333333]
        >}
  ## Example Using Series:
      iex> [high, low, close] = [Explorer.Series.from_list([5.0, 6.0, 7.0, 8.0, 9.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0, 6.0, 7.0], dtype: {:f, 64})]
      iex> ExTalib.plus_di(high, low, close, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[5]
            f64 [NaN, NaN, 33.33333333333333, 33.33333333333333, 33.33333333333333]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low, close] = [Nx.tensor([5.0, 6.0, 7.0, 8.0, 9.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0, 5.0, 6.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0, 6.0, 7.0], type: :f64)]
      iex> ExTalib.plus_di(high, low, close, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[5]
            [NaN, NaN, 33.33333333333333, 33.33333333333333, 33.33333333333333]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec plus_di(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec plus_di(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def plus_di(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 14, options \\ [])
  def plus_di(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df([:plus_di, options, dataframe, time_period])
  def plus_di(high, low, close, time_period, options), do: run([:plus_di, options, high, low, close, time_period])
  @doc """
  A bang! version of `plus_di/5`. It does **not** perform any validations.

  Please refer to `plus_di/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `plus_di/5`.
  """
  @doc type: :momentum_indicators
  @spec plus_di!(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec plus_di!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def plus_di!(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 14, options \\ [])
  def plus_di!(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df!([:plus_di, options, dataframe, time_period])
  def plus_di!(high, low, close, time_period, options), do: run!([:plus_di, options, high, low, close, time_period])


  @doc """
  Calculates the **Plus Directional Movement**.

  `TA-LIB` source name: `PLUS_DM`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `plus_dm`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0, 8.0, 9.0], low: [2.0, 3.0, 4.0, 5.0, 6.0]})
      iex> ExTalib.plus_dm(df, nil, 2)
      #Explorer.DataFrame<
        Polars[5 x 3]
        high f64 [5.0, 6.0, 7.0, 8.0, 9.0]
        low f64 [2.0, 3.0, 4.0, 5.0, 6.0]
        plus_dm_2 f64 [NaN, 1.0, 1.5, 1.75, 1.875]
      >}
  ## Example Using Series:
      iex> [high, low] = [Explorer.Series.from_list([5.0, 6.0, 7.0, 8.0, 9.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0, 5.0, 6.0])]
      iex> ExTalib.plus_dm(high, low, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[5]
            f64 [NaN, 1.0, 1.5, 1.75, 1.875]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low] = [Nx.tensor([5.0, 6.0, 7.0, 8.0, 9.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0, 5.0, 6.0], type: :f64)]
      iex> ExTalib.plus_dm(high, low, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[5]
            [NaN, 1.0, 1.5, 1.75, 1.875]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec plus_dm(dataframe :: Explorer.DataFrame.t(), nil, time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec plus_dm(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def plus_dm(high_or_dataframe, low \\ nil, time_period \\ 14, options \\ [])
  def plus_dm(dataframe, nil, time_period, options) when is_dataframe(dataframe), do: run_df([:plus_dm, options, dataframe, time_period])
  def plus_dm(high, low, time_period, options), do: run([:plus_dm, options, high, low, time_period])
  @doc """
  A bang! version of `plus_dm/4`. It does **not** perform any validations.

  Please refer to `plus_dm/4` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `plus_dm/4`.
  """
  @doc type: :momentum_indicators
  @spec plus_dm!(dataframe :: Explorer.DataFrame.t(), nil, time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec plus_dm!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def plus_dm!(high_or_dataframe, low \\ nil, time_period \\ 14, options \\ [])
  def plus_dm!(dataframe, nil, time_period, options) when is_dataframe(dataframe), do: run_df!([:plus_dm, options, dataframe, time_period])
  def plus_dm!(high, low, time_period, options), do: run!([:plus_dm, options, high, low, time_period])


  @doc """
  Calculates the **Percentage Price Oscillator** indicator.

  `TA-LIB` source name: `PPO`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `ppo`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.ppo(df, 2, 3)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          ppo_2_3 f64 [NaN, NaN, 12.5]
        >}
  ## Example Using Series:
      iex> values = Explorer.Series.from_list([3.0, 4.0, 5.0])
      iex> ExTalib.ppo(values, 2, 3)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, 12.5]
          >
        }}

  ## Example Using Tensors:
      iex> values = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.ppo(values, 2, 3)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, 12.5]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec ppo(dataframe :: Explorer.DataFrame.t(), fast_period :: integer(), slow_period :: integer(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec ppo(values :: Explorer.Series.t() | Nx.Tensor.t(), fast_period :: integer(), slow_period :: integer(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def ppo(values_or_dataframe, fast_period \\ 12, slow_period \\ 26, ma_type \\ :sma, options \\ [])
  def ppo(dataframe, fast_period, slow_period, ma_type, options) when is_dataframe(dataframe), do: run_df([:ppo, options, dataframe, fast_period, slow_period, ma_type])
  def ppo(values, fast_period, slow_period, ma_type, options), do: run([:ppo, options, values, fast_period, slow_period, ma_type])
  @doc """
  A bang! version of `ppo/5`. It does **not** perform any validations.

  Please refer to `ppo/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `ppo/5`.
  """
  @doc type: :momentum_indicators
  @spec ppo!(dataframe :: Explorer.DataFrame.t(), fast_period :: integer(), slow_period :: integer(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec ppo!(values :: Explorer.Series.t() | Nx.Tensor.t(), fast_period :: integer(), slow_period :: integer(), ma_type :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def ppo!(values_or_dataframe, fast_period \\ 12, slow_period \\ 26, ma_type \\ :sma, options \\ [])
  def ppo!(dataframe, fast_period, slow_period, ma_type, options) when is_dataframe(dataframe), do: run_df!([:ppo, options, dataframe, fast_period, slow_period, ma_type])
  def ppo!(values, fast_period, slow_period, ma_type, options), do: run!([:ppo, options, values, fast_period, slow_period, ma_type])


  @doc """
  Calculates the **Rate of change : ((price/prevPrice)-1)*100** indicator.

  `TA-LIB` source name: `ROC`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `roc`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.roc(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          roc_2 f64 [NaN, NaN, 66.66666666666667]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.roc(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, 66.66666666666667]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.roc(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, 66.66666666666667]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec roc(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec roc(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def roc(values_or_dataframe, time_period \\ 10, options \\ [])
  def roc(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:roc, options, dataframe, time_period])
  def roc(values, time_period, options), do: run([:roc, options, values, time_period])
  @doc """
  A bang! version of `roc/3`. It does **not** perform any validations.

  Please refer to `roc/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `roc/3`.
  """
  @doc type: :momentum_indicators
  @spec roc!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec roc!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def roc!(values_or_dataframe, time_period \\ 10, options \\ [])
  def roc!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:roc, options, dataframe, time_period])
  def roc!(values, time_period, options), do: run!([:roc, options, values, time_period])


  @doc """
  Calculates the **Rate of change Percentage: (price-prevPrice)/prevPrice** indicator.

  `TA-LIB` source name: `ROCP`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `rocp`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.rocp(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          rocp_2 f64 [NaN, NaN, 0.6666666666666666]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.rocp(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, 0.6666666666666666]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.rocp(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, 0.6666666666666666]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec rocp(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec rocp(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def rocp(values_or_dataframe, time_period \\ 10, options \\ [])
  def rocp(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:rocp, options, dataframe, time_period])
  def rocp(values, time_period, options), do: run([:rocp, options, values, time_period])
  @doc """
  A bang! version of `rocp/3`. It does **not** perform any validations.

  Please refer to `rocp/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `rocp/3`.
  """
  @doc type: :momentum_indicators
  @spec rocp!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec rocp!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def rocp!(values_or_dataframe, time_period \\ 10, options \\ [])
  def rocp!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:rocp, options, dataframe, time_period])
  def rocp!(values, time_period, options), do: run!([:rocp, options, values, time_period])



  @doc """
  Calculates the **Rate of change ratio: (price/prevPrice)** indicator.

  `TA-LIB` source name: `ROCR`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `rocr`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.rocr(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          rocr_2 f64 [NaN, NaN, 1.6666666666666667]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.rocr(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, 1.6666666666666667]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.rocr(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, 1.6666666666666667]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec rocr(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec rocr(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def rocr(values_or_dataframe, time_period \\ 10, options \\ [])
  def rocr(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:rocr, options, dataframe, time_period])
  def rocr(values, time_period, options), do: run([:rocr, options, values, time_period])
  @doc """
  A bang! version of `rocr/3`. It does **not** perform any validations.

  Please refer to `rocr/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `rocr/3`.
  """
  @doc type: :momentum_indicators
  @spec rocr!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec rocr!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def rocr!(values_or_dataframe, time_period \\ 10, options \\ [])
  def rocr!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:rocr, options, dataframe, time_period])
  def rocr!(values, time_period, options), do: run!([:rocr, options, values, time_period])


  @doc """
  Calculates the **Rate of change ratio 100 scale: (price/prevPrice)*100** indicator.

  `TA-LIB` source name: `ROCR100`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `rocr100`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.rocr100(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          rocr100_2 f64 [NaN, NaN, 166.66666666666669]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.rocr100(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, 166.66666666666669]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.rocr100(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, 166.66666666666669]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec rocr100(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec rocr100(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def rocr100(values_or_dataframe, time_period \\ 10, options \\ [])
  def rocr100(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:rocr100, options, dataframe, time_period])
  def rocr100(values, time_period, options), do: run([:rocr100, options, values, time_period])
  @doc """
  A bang! version of `rocr100/3`. It does **not** perform any validations.

  Please refer to `rocr100/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `rocr100/3`.
  """
  @doc type: :momentum_indicators
  @spec rocr100!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec rocr100!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def rocr100!(values_or_dataframe, time_period \\ 10, options \\ [])
  def rocr100!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:rocr100, options, dataframe, time_period])
  def rocr100!(values, time_period, options), do: run!([:rocr100, options, values, time_period])


  @doc """
  Calculates the **Relative Strength Index** indicator.

  `TA-LIB` source name: `RSI`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `rsi`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.rsi(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          rsi_2 f64 [NaN, NaN, 100.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.rsi(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, 100.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.rsi(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, 100.0]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec rsi(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec rsi(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def rsi(values_or_dataframe, time_period \\ 14, options \\ [])
  def rsi(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:rsi, options, dataframe, time_period])
  def rsi(values, time_period, options), do: run([:rsi, options, values, time_period])
  @doc """
  A bang! version of `rsi/3`. It does **not** perform any validations.

  Please refer to `rsi/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `rsi/3`.
  """
  @doc type: :momentum_indicators
  @spec rsi!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec rsi!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def rsi!(values_or_dataframe, time_period \\ 14, options \\ [])
  def rsi!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:rsi, options, dataframe, time_period])
  def rsi!(values, time_period, options), do: run!([:rsi, options, values, time_period])


  @doc """
  Calculates the **Parabolic SAR (stop and reverse)** Indicator.
  `acceleration_factor`: Acceleration Factor used up to the Maximum value
  `af_maximum`: Acceleration Factor Maximum value

  `TA-LIB` source name: `SAR`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `sar`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0, 8.0, 9.0], low: [2.0, 3.0, 4.0, 5.0, 6.0]})
      iex> ExTalib.sar(df)
      #Explorer.DataFrame<
        Polars[5 x 3]
        high f64 [5.0, 6.0, 7.0, 8.0, 9.0]
        low f64 [2.0, 3.0, 4.0, 5.0, 6.0]
        sar_0.02_0.2 f64 [NaN, 2.0, 2.08, 2.1784, 2.294832]
      >}
  ## Example Using Series:
      iex> [high, low] = [Explorer.Series.from_list([5.0, 6.0, 7.0, 8.0, 9.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0, 5.0, 6.0])]
      iex> ExTalib.sar(high, low)
      {:ok,
        {
          #Explorer.Series<
            Polars[5]
            f64 [NaN, 2.0, 2.08, 2.1784, 2.294832]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low] = [Nx.tensor([5.0, 6.0, 7.0, 8.0, 9.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0, 5.0, 6.0], type: :f64)]
      iex> ExTalib.sar(high, low)
      {:ok,
        {
          #Nx.Tensor<
            f64[5]
            [NaN, 2.0, 2.08, 2.1784, 2.294832]
          >
        }}

  """
  @doc type: :overlap_studies
  @spec sar(dataframe :: Explorer.DataFrame.t(), nil, acceleration_factor :: float(), af_maximum :: float(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec sar(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), acceleration_factor :: float(), af_maximum :: float(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def sar(high_or_dataframe, low \\ nil, acceleration_factor \\ 0.02, af_maximum \\ 0.2, options \\ [])
  def sar(dataframe, nil, acceleration_factor, af_maximum, options) when is_dataframe(dataframe), do: run_df([:sar, options, dataframe, acceleration_factor, af_maximum])
  def sar(high, low, acceleration_factor, af_maximum, options), do: run([:sar, options, high, low, acceleration_factor, af_maximum])
  @doc """
  A bang! version of `sar/5`. It does **not** perform any validations.

  Please refer to `sar/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `sar/5`.
  """
  @doc type: :overlap_studies
  @spec sar!(dataframe :: Explorer.DataFrame.t(), nil, acceleration_factor :: float(), af_maximum :: float(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec sar!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), acceleration_factor :: float(), af_maximum :: float(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def sar!(high_or_dataframe, low \\ nil, acceleration_factor \\ 0.02, af_maximum \\ 0.2, options \\ [])
  def sar!(dataframe, nil, acceleration_factor, af_maximum, options) when is_dataframe(dataframe), do: run_df!([:sar, options, dataframe, acceleration_factor, af_maximum])
  def sar!(high, low, acceleration_factor, af_maximum, options), do: run!([:sar, options, high, low, acceleration_factor, af_maximum])


  @doc """
  Calculates the **Parabolic SAR (stop and reverse) - Extended** Indicator.
  `start_value`: Start value and direction. 0 for Auto, >0 for Long, <0 for Short
  `offset_on_reverse`: Percent offset added/removed to initial stop on short/long reversal
  `af_init_long`: Acceleration Factor initial value for the Long direction
  `af_long`: Acceleration Factor for the Long direction
  `af_max_long`: Acceleration Factor maximum value for the Long direction
  `af_init_short`: Acceleration Factor initial value for the Short direction
  `af_short`: Acceleration Factor for the Short direction
  `af_max_short`: Acceleration Factor maximum value for the Short direction

  `TA-LIB` source name: `SAREXT`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `sarext`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0, 8.0, 9.0], low: [2.0, 3.0, 4.0, 5.0, 6.0]})
      iex> ExTalib.sarext(df)
      #Explorer.DataFrame<
        Polars[5 x 3]
        high f64 [5.0, 6.0, 7.0, 8.0, 9.0]
        low f64 [2.0, 3.0, 4.0, 5.0, 6.0]
        sarext_0.0_0.0_0.02_0.02_0.2_0.02_0.02_0.2 f64 [NaN, 0.2, 0.316, 0.44967999999999997, 0.6006864]
      >}
  ## Example Using Series:
      iex> [high, low] = [Explorer.Series.from_list([5.0, 6.0, 7.0, 8.0, 9.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0, 5.0, 6.0])]
      iex> ExTalib.sarext(high, low)
      {:ok,
        {
          #Explorer.Series<
            Polars[5]
            f64 [NaN, 0.2, 0.316, 0.44967999999999997, 0.6006864]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low] = [Nx.tensor([5.0, 6.0, 7.0, 8.0, 9.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0, 5.0, 6.0], type: :f64)]
      iex> ExTalib.sarext(high, low)
      {:ok,
        {
          #Nx.Tensor<
            f64[5]
            [NaN, 0.2, 0.316, 0.44967999999999997, 0.6006864]
          >
        }}

  """
  @doc type: :overlap_studies
  @spec sarext(dataframe :: Explorer.DataFrame.t(), nil, start_value :: float(), offset_on_reverse :: float(), af_init_long :: float(), af_long :: float(), af_max_long :: float(), af_init_short :: float(), af_short :: float(), af_max_short :: float(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec sarext(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), start_value :: float(), offset_on_reverse :: float(), af_init_long :: float(), af_long :: float(), af_max_long :: float(), af_init_short :: float(), af_short :: float(), af_max_short :: float(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def sarext(high_or_dataframe, low \\ nil, start_value \\ 0.0, offset_on_reverse \\ 0.0, af_init_long \\ 0.02, af_long \\ 0.02, af_max_long \\ 0.2, af_init_short \\ 0.02, af_short \\ 0.02, af_max_short \\ 0.2, options \\ [])
  def sarext(dataframe, nil, start_value, offset_on_reverse, af_init_long, af_long, af_max_long, af_init_short, af_short, af_max_short, options) when is_dataframe(dataframe), do: run_df([:sarext, options, dataframe, start_value, offset_on_reverse, af_init_long, af_long, af_max_long, af_init_short, af_short, af_max_short])
  def sarext(high, low, start_value, offset_on_reverse, af_init_long, af_long, af_max_long, af_init_short, af_short, af_max_short, options), do: run([:sarext, options, high, low, start_value, offset_on_reverse, af_init_long, af_long, af_max_long, af_init_short, af_short, af_max_short])
  @doc """
  A bang! version of `sarext/11`. It does **not** perform any validations.

  Please refer to `sarext/11` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `sarext/11`.
  """
  @doc type: :overlap_studies
  @spec sarext!(dataframe :: Explorer.DataFrame.t(), nil, start_value :: float(), offset_on_reverse :: float(), af_init_long :: float(), af_long :: float(), af_max_long :: float(), af_init_short :: float(), af_short :: float(), af_max_short :: float(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec sarext!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), start_value :: float(), offset_on_reverse :: float(), af_init_long :: float(), af_long :: float(), af_max_long :: float(), af_init_short :: float(), af_short :: float(), af_max_short :: float(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def sarext!(high_or_dataframe, low \\ nil, start_value \\ 0.0, offset_on_reverse \\ 0.0, af_init_long \\ 0.02, af_long \\ 0.02, af_max_long \\ 0.2, af_init_short \\ 0.02, af_short \\ 0.02, af_max_short \\ 0.2, options \\ [])
  def sarext!(dataframe, nil, start_value, offset_on_reverse, af_init_long, af_long, af_max_long, af_init_short, af_short, af_max_short, options) when is_dataframe(dataframe), do: run_df!([:sarext, options, dataframe, start_value, offset_on_reverse, af_init_long, af_long, af_max_long, af_init_short, af_short, af_max_short])
  def sarext!(high, low, start_value, offset_on_reverse, af_init_long, af_long, af_max_long, af_init_short, af_short, af_max_short, options), do: run!([:sarext, options, high, low, start_value, offset_on_reverse, af_init_long, af_long, af_max_long, af_init_short, af_short, af_max_short])


  @doc """
  Calculates the **Vector Trigonometric Sin** indicator.

  `TA-LIB` source name: `SIN`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `sin`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.5, 4.5, 5.0]})
      iex> ExTalib.sin(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.5, 4.5, 5.0]
          sin f64 [-0.35078322768961984, -0.977530117665097, -0.9589242746631385]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.5, 4.5, 5.0], dtype: {:f, 64})
      iex> ExTalib.sin(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [-0.35078322768961984, -0.977530117665097, -0.9589242746631385]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.5, 4.5, 5.0], type: :f64)
      iex> ExTalib.sin(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [-0.35078322768961984, -0.977530117665097, -0.9589242746631385]
          >
        }}

  """
  @doc type: :math_transform
  @spec sin(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec sin(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def sin(values_or_dataframe, options \\ [])
  def sin(dataframe, options) when is_dataframe(dataframe), do: run_df([:sin, options, dataframe])
  def sin(values, options), do: run([:sin, options, values])
  @doc """
  A bang! version of `sin/2`. It does **not** perform any validations.

  Please refer to `sin/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `sin/2`.
  """
  @doc type: :math_transform
  @spec sin!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec sin!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def sin!(values_or_dataframe, options \\ [])
  def sin!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:sin, options, dataframe])
  def sin!(values, options), do: run!([:sin, options, values])


  @doc """
  Calculates the **Vector Trigonometric Sinh** indicator.

  `TA-LIB` source name: `SINH`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `sinh`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.5, 4.5, 5.0]})
      iex> ExTalib.sinh(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.5, 4.5, 5.0]
          sinh f64 [16.542627287634996, 45.003011151991785, 74.20321057778875]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.5, 4.5, 5.0], dtype: {:f, 64})
      iex> ExTalib.sinh(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [16.542627287634996, 45.003011151991785, 74.20321057778875]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.5, 4.5, 5.0], type: :f64)
      iex> ExTalib.sinh(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [16.542627287634996, 45.003011151991785, 74.20321057778875]
          >
        }}

  """
  @doc type: :math_transform
  @spec sinh(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec sinh(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def sinh(values_or_dataframe, options \\ [])
  def sinh(dataframe, options) when is_dataframe(dataframe), do: run_df([:sinh, options, dataframe])
  def sinh(values, options), do: run([:sinh, options, values])
  @doc """
  A bang! version of `sinh/2`. It does **not** perform any validations.

  Please refer to `sinh/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `sinh/2`.
  """
  @doc type: :math_transform
  @spec sinh!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec sinh!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def sinh!(values_or_dataframe, options \\ [])
  def sinh!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:sinh, options, dataframe])
  def sinh!(values, options), do: run!([:sinh, options, values])


  @doc """
  Calculates the **Simple Moving Average** indicator.

  `TA-LIB` source name: `SMA`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `sma`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.sma(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          sma_2 f64 [NaN, 3.5, 4.5]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.sma(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 3.5, 4.5]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.sma(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 3.5, 4.5]
          >
        }}

  """
  @doc type: :overlap_studies
  @spec sma(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec sma(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def sma(values_or_dataframe, time_period \\ 30, options \\ [])
  def sma(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:sma, options, dataframe, time_period])
  def sma(values, time_period, options), do: run([:sma, options, values, time_period])
  @doc """
  A bang! version of `sma/3`. It does **not** perform any validations.

  Please refer to `sma/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `avgdev/3`.
  """
  @doc type: :overlap_studies
  @spec sma!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec sma!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def sma!(values_or_dataframe, time_period \\ 30, options \\ [])
  def sma!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:sma, options, dataframe, time_period])
  def sma!(values, time_period, options), do: run!([:sma, options, values, time_period])


  @doc """
  Calculates the **Vector Square Root** indicator.

  `TA-LIB` source name: `SQRT`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `sqrt`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.5, 4.5, 5.0]})
      iex> ExTalib.sqrt(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.5, 4.5, 5.0]
          sqrt f64 [1.8708286933869707, 2.1213203435596424, 2.23606797749979]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.5, 4.5, 5.0], dtype: {:f, 64})
      iex> ExTalib.sqrt(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [1.8708286933869707, 2.1213203435596424, 2.23606797749979]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.5, 4.5, 5.0], type: :f64)
      iex> ExTalib.sqrt(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [1.8708286933869707, 2.1213203435596424, 2.23606797749979]
          >
        }}

  """
  @doc type: :math_transform
  @spec sqrt(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec sqrt(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def sqrt(values_or_dataframe, options \\ [])
  def sqrt(dataframe, options) when is_dataframe(dataframe), do: run_df([:sqrt, options, dataframe])
  def sqrt(values, options), do: run([:sqrt, options, values])
  @doc """
  A bang! version of `sqrt/2`. It does **not** perform any validations.

  Please refer to `sqrt/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `sqrt/2`.
  """
  @doc type: :math_transform
  @spec sqrt!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec sqrt!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def sqrt!(values_or_dataframe, options \\ [])
  def sqrt!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:sqrt, options, dataframe])
  def sqrt!(values, options), do: run!([:sqrt, options, values])


  @doc """
  Calculates the **Standard Deviation** indicator.

  `TA-LIB` source name: `STDDEV`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      *Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      *Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `stddev`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.stddev(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          stddev_2_1.0 f64 [NaN, 0.5, 0.5]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.stddev(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 0.5, 0.5]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.stddev(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 0.5, 0.5]
          >
        }}

  """
  @doc type: :overlap_studies
  @spec stddev(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), deviations :: float(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec stddev(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), deviations :: float(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def stddev(values_or_dataframe, time_period \\ 5, deviations \\ 1.0, options \\ [])
  def stddev(dataframe, time_period, deviations, options) when is_dataframe(dataframe), do: run_df([:stddev, options, dataframe, time_period, deviations])
  def stddev(values, time_period, deviations, options), do: run([:stddev, options, values, time_period, deviations])
  @doc """
  A bang! version of `stddev/4`. It does **not** perform any validations.

  Please refer to `stddev/4` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `stddev/4`.
  """
  @doc type: :overlap_studies
  @spec stddev!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), deviations :: float(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec stddev!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), deviations :: float(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def stddev!(values_or_dataframe, time_period \\ 5, deviations \\ 1.0, options \\ [])
  def stddev!(dataframe, time_period, deviations, options) when is_dataframe(dataframe), do: run_df!([:stddev, options, dataframe, time_period, deviations])
  def stddev!(values, time_period, deviations, options), do: run!([:stddev, options, values, time_period, deviations])


  @doc """
  Calculates the **Stochastic** indicator.

  `TA-LIB` source name: `STOCH`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `slowk`, type: `[:f64]`
    - `slowd`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.stoch(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          slowk_5_3_3 f64 [NaN, NaN, NaN]
          slowd_5_3_3 f64 [NaN, NaN, NaN]
        >}

  ## Example Using Series:
      iex> [high, low, close] = [Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.stoch(high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >,
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low, close] = [Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0], type: :f64)]
      iex> ExTalib.stoch(high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >,
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec stoch(dataframe :: Explorer.DataFrame.t(), nil, nil, fast_k_period :: integer(), slow_k_period :: integer(), slow_k_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, slow_d_period :: integer(), slow_d_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec stoch(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), fast_k_period :: integer(), slow_k_period :: integer(), slow_k_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, slow_d_period :: integer(), slow_d_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def stoch(high_or_dataframe, low \\ nil, close \\ nil, fast_k_period \\ 5, slow_k_period \\ 3, slow_k_ma \\ :sma, slow_d_period \\ 3, slow_d_ma \\ :sma, options \\ [])
  def stoch(dataframe, nil, nil, fast_k_period, slow_k_period, slow_k_ma, slow_d_period, slow_d_ma, options) when is_dataframe(dataframe), do: run_df([:stoch, options, dataframe, fast_k_period, slow_k_period, slow_k_ma, slow_d_period, slow_d_ma])
  def stoch(high, low, close, fast_k_period, slow_k_period, slow_k_ma, slow_d_period, slow_d_ma, options), do: run([:stoch, options, high, low, close, fast_k_period, slow_k_period, slow_k_ma, slow_d_period, slow_d_ma])
  @doc """
  A bang! version of `stoch/9`. It does **not** perform any validations.

  Please refer to `stoch/9` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `stoch/9`.
  """
  @doc type: :momentum_indicators
  @spec stoch!(dataframe :: Explorer.DataFrame.t(), nil, nil, fast_k_period :: integer(), slow_k_period :: integer(), slow_k_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, slow_d_period :: integer(), slow_d_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec stoch!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), fast_k_period :: integer(), slow_k_period :: integer(), slow_k_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, slow_d_period :: integer(), slow_d_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def stoch!(high_or_dataframe, low \\ nil, close \\ nil, fast_k_period \\ 5, slow_k_period \\ 3, slow_k_ma \\ :sma, slow_d_period \\ 3, slow_d_ma \\ :sma, options \\ [])
  def stoch!(dataframe, nil, nil, fast_k_period, slow_k_period, slow_k_ma, slow_d_period, slow_d_ma, options) when is_dataframe(dataframe), do: run_df!([:stoch, options, dataframe, fast_k_period, slow_k_period, slow_k_ma, slow_d_period, slow_d_ma])
  def stoch!(high, low, close, fast_k_period, slow_k_period, slow_k_ma, slow_d_period, slow_d_ma, options), do: run!([:stoch, options, high, low, close, fast_k_period, slow_k_period, slow_k_ma, slow_d_period, slow_d_ma])


  @doc """
  Calculates the **Stochastic Fast** indicator.

  `TA-LIB` source name: `STOCHF`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `fastk`, type: `[:f64]`
    - `fastd`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.stochf(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 5]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          fastk_5_3 f64 [NaN, NaN, NaN]
          fastd_5_3 f64 [NaN, NaN, NaN]
        >}

  ## Example Using Series:
      iex> [high, low, close] = [Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.stochf(high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >,
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low, close] = [Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0], type: :f64)]
      iex> ExTalib.stochf(high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >,
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec stochf(dataframe :: Explorer.DataFrame.t(), nil, nil, fast_k_period :: integer(), fast_d_period :: integer(), fast_d_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec stochf(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), fast_k_period :: integer(), fast_d_period :: integer(), fast_d_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def stochf(high_or_dataframe, low \\ nil, close \\ nil, fast_k_period \\ 5, fast_d_period \\ 3, fast_d_ma \\ :sma, options \\ [])
  def stochf(dataframe, nil, nil, fast_k_period, fast_d_period, fast_d_ma, options) when is_dataframe(dataframe), do: run_df([:stochf, options, dataframe, fast_k_period, fast_d_period, fast_d_ma])
  def stochf(high, low, close, fast_k_period, fast_d_period, fast_d_ma, options), do: run([:stochf, options, high, low, close, fast_k_period, fast_d_period, fast_d_ma])
  @doc """
  A bang! version of `stochf/7`. It does **not** perform any validations.

  Please refer to `stochf/7` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `stochf/7`.
  """
  @doc type: :momentum_indicators
  @spec stochf!(dataframe :: Explorer.DataFrame.t(), nil, nil, fast_k_period :: integer(), fast_d_period :: integer(), fast_d_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec stochf!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), fast_k_period :: integer(), fast_d_period :: integer(), fast_d_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def stochf!(high_or_dataframe, low \\ nil, close \\ nil, fast_k_period \\ 5, fast_d_period \\ 3, fast_d_ma \\ :sma, options \\ [])
  def stochf!(dataframe, nil, nil, fast_k_period, fast_d_period, fast_d_ma, options) when is_dataframe(dataframe), do: run_df!([:stochf, options, dataframe, fast_k_period, fast_d_period, fast_d_ma])
  def stochf!(high, low, close, fast_k_period, fast_d_period, fast_d_ma, options), do: run!([:stochf, options, high, low, close, fast_k_period, fast_d_period, fast_d_ma])


  @doc """
  Calculates the **Stochastic Relative Strength Index** indicator.

  `TA-LIB` source name: `STOCHRSI`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `fastk`, type: `[:f64]`
    - `fastd`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [5.0, 6.0, 7.0]})
      iex> ExTalib.stochrsi(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 3]
          values f64 [5.0, 6.0, 7.0]
          fastk_2_5_3 f64 [NaN, NaN, NaN]
          fastd_2_5_3 f64 [NaN, NaN, NaN]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([5.0, 6.0, 7.0])
      iex> ExTalib.stochrsi(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >,
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([5.0, 6.0, 7.0], type: :f64)
      iex> ExTalib.stochrsi(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >,
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec stochrsi(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), fast_k_period :: integer(), fast_d_period :: integer(), fast_d_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec stochrsi(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), fast_k_period :: integer(), fast_d_period :: integer(), fast_d_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def stochrsi(values_or_dataframe, time_period \\ 14, fast_k_period \\ 5, fast_d_period \\ 3, fast_d_ma \\ :sma, options \\ [])
  def stochrsi(dataframe, time_period, fast_k_period, fast_d_period, fast_d_ma, options) when is_dataframe(dataframe), do: run_df([:stochrsi, options, dataframe, time_period, fast_k_period, fast_d_period, fast_d_ma])
  def stochrsi(values, time_period, fast_k_period, fast_d_period, fast_d_ma, options), do: run([:stochrsi, options, values, time_period, fast_k_period, fast_d_period, fast_d_ma])
  @doc """
  A bang! version of `stochrsi/6`. It does **not** perform any validations.

  Please refer to `stochrsi/6` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `stochrsi/6`.
  """
  @doc type: :momentum_indicators
  @spec stochrsi!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), fast_k_period :: integer(), fast_d_period :: integer(), fast_d_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec stochrsi!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), fast_k_period :: integer(), fast_d_period :: integer(), fast_d_ma :: :sma | :ema | :wma | :dema | :tema | :trima | :kama | :mama | :t3, options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def stochrsi!(values_or_dataframe, time_period \\ 14, fast_k_period \\ 5, fast_d_period \\ 3, fast_d_ma \\ :sma, options \\ [])
  def stochrsi!(dataframe, time_period, fast_k_period, fast_d_period, fast_d_ma, options) when is_dataframe(dataframe), do: run_df!([:stochrsi, options, dataframe, time_period, fast_k_period, fast_d_period, fast_d_ma])
  def stochrsi!(values, time_period, fast_k_period, fast_d_period, fast_d_ma, options), do: run!([:stochrsi, options, values, time_period, fast_k_period, fast_d_period, fast_d_ma])


  @doc """
  Calculates the **Vector Arithmetic Subtraction** indicator.

  `TA-LIB` source name: `SUB`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values_a`, `values_b`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `sub`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values_a: [5.0, 6.0, 7.0], values_b: [2.0, 3.0, 4.0]})
      iex> ExTalib.sub(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 3]
          values_a f64 [5.0, 6.0, 7.0]
          values_b f64 [2.0, 3.0, 4.0]
          sub f64 [3.0, 3.0, 3.0]
        >}
  ## Example Using Series:
      iex> [values_a, values_b] = [Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0])]
      iex> ExTalib.sub(values_a, values_b)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [3.0, 3.0, 3.0]
          >
        }}

  ## Example Using Tensors:
      iex> [values_a, values_b] = [Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64)]
      iex> ExTalib.sub(values_a, values_b)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [3.0, 3.0, 3.0]
          >
        }}

  """
  @doc type: :math_operators
  @spec sub(dataframe :: Explorer.DataFrame.t(), nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec sub(values_a :: Explorer.Series.t() | Nx.Tensor.t(), values_b :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def sub(values_a_or_dataframe, values_b \\ nil, options \\ [])
  def sub(dataframe, nil, options) when is_dataframe(dataframe), do: run_df([:sub, options, dataframe])
  def sub(values_a, values_b, options), do: run([:sub, options, values_a, values_b])
  @doc """
  A bang! version of `sub/3`. It does **not** perform any validations.

  Please refer to `sub/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `sub/3`.
  """
  @doc type: :math_operators
  @spec sub!(dataframe :: Explorer.DataFrame.t(), nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec sub!(values_a :: Explorer.Series.t() | Nx.Tensor.t(), values_b :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def sub!(values_a_or_dataframe, values_b \\ nil, options \\ [])
  def sub!(dataframe, nil, options) when is_dataframe(dataframe), do: run_df!([:sub, options, dataframe])
  def sub!(values_a, values_b, options), do: run!([:sub, options, values_a, values_b])


  @doc """
  Calculates the **Summation Over Number of Periods**.

  `TA-LIB` source name: `SUM`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `sum`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.sum(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          sum_2 f64 [NaN, 7.0, 9.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.sum(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 7.0, 9.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.sum(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 7.0, 9.0]
          >
        }}

  """
  @doc type: :price_transform
  @spec sum(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec sum(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def sum(values_or_dataframe, time_period \\ 30, options \\ [])
  def sum(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:sum, options, dataframe, time_period])
  def sum(values, time_period, options), do: run([:sum, options, values, time_period])
  @doc """
  A bang! version of `sum/3`. It does **not** perform any validations.

  Please refer to `sum/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `sum/3`.
  """
  @doc type: :price_transform
  @spec sum!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec sum!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def sum!(values_or_dataframe, time_period \\ 30, options \\ [])
  def sum!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:sum, options, dataframe, time_period])
  def sum!(values, time_period, options), do: run!([:sum, options, values, time_period])


  @doc """
  Calculates the **Triple Exponential Moving Average (T3)** indicator.

  `TA-LIB` source name: `T3`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `t3`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.t3(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          t3_2_0.7 f64 [NaN, NaN, NaN]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.t3(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.t3(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN]
          >
        }}

  """
  @doc type: :overlap_studies
  @spec t3(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), volume_factor :: float(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec t3(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), volume_factor :: float(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def t3(values_or_dataframe, time_period \\ 5, volume_factor \\ 0.7, options \\ [])
  def t3(dataframe, time_period, volume_factor, options) when is_dataframe(dataframe), do: run_df([:t3, options, dataframe, time_period, volume_factor])
  def t3(values, time_period, volume_factor, options), do: run([:t3, options, values, time_period, volume_factor])
  @doc """
  A bang! version of `t3/4`. It does **not** perform any validations.

  Please refer to `t3/4` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `t3/4`.
  """
  @doc type: :overlap_studies
  @spec t3!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), volume_factor :: float(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec t3!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), volume_factor :: float(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def t3!(values_or_dataframe, time_period \\ 5, volume_factor \\ 0.7, options \\ [])
  def t3!(dataframe, time_period, volume_factor, options) when is_dataframe(dataframe), do: run_df!([:t3, options, dataframe, time_period, volume_factor])
  def t3!(values, time_period, volume_factor, options), do: run!([:t3, options, values, time_period, volume_factor])


  @doc """
  Calculates the **Vector Trigonometric Tan** indicator.

  `TA-LIB` source name: `TAN`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `tan`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.5, 4.5, 5.0]})
      iex> ExTalib.tan(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.5, 4.5, 5.0]
          tan f64 [0.3745856401585947, 4.637332054551185, -3.380515006246586]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.5, 4.5, 5.0], dtype: {:f, 64})
      iex> ExTalib.tan(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [0.3745856401585947, 4.637332054551185, -3.380515006246586]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.5, 4.5, 5.0], type: :f64)
      iex> ExTalib.tan(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [0.3745856401585947, 4.637332054551185, -3.380515006246586]
          >
        }}

  """
  @doc type: :math_transform
  @spec tan(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec tan(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def tan(values_or_dataframe, options \\ [])
  def tan(dataframe, options) when is_dataframe(dataframe), do: run_df([:tan, options, dataframe])
  def tan(values, options), do: run([:tan, options, values])
  @doc """
  A bang! version of `tan/2`. It does **not** perform any validations.

  Please refer to `tan/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `tan/2`.
  """
  @doc type: :math_transform
  @spec tan!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec tan!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def tan!(values_or_dataframe, options \\ [])
  def tan!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:tan, options, dataframe])
  def tan!(values, options), do: run!([:tan, options, values])


  @doc """
  Calculates the **Vector Trigonometric Tanh** indicator.

  `TA-LIB` source name: `TANH`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `tanh`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.5, 4.5, 5.0]})
      iex> ExTalib.tanh(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.5, 4.5, 5.0]
          tanh f64 [0.9981778976111987, 0.9997532108480275, 0.9999092042625951]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.5, 4.5, 5.0], dtype: {:f, 64})
      iex> ExTalib.tanh(series)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [0.9981778976111987, 0.9997532108480275, 0.9999092042625951]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.5, 4.5, 5.0], type: :f64)
      iex> ExTalib.tanh(tensor)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [0.9981778976111987, 0.9997532108480275, 0.9999092042625951]
          >
        }}

  """
  @doc type: :math_transform
  @spec tanh(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec tanh(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def tanh(values_or_dataframe, options \\ [])
  def tanh(dataframe, options) when is_dataframe(dataframe), do: run_df([:tanh, options, dataframe])
  def tanh(values, options), do: run([:tanh, options, values])
  @doc """
  A bang! version of `tanh/2`. It does **not** perform any validations.

  Please refer to `tanh/2` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `tanh/2`.
  """
  @doc type: :math_transform
  @spec tanh!(dataframe :: Explorer.DataFrame.t(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec tanh!(values :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def tanh!(values_or_dataframe, options \\ [])
  def tanh!(dataframe, options) when is_dataframe(dataframe), do: run_df!([:tanh, options, dataframe])
  def tanh!(values, options), do: run!([:tanh, options, values])


  @doc """
  Calculates the **Triple Exponential Moving Average** indicator.

  `TA-LIB` source name: `TEMA`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `tema`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0, 6.0]})
      iex> ExTalib.tema(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[4 x 2]
          values f64 [3.0, 4.0, 5.0, 6.0]
          tema_2 f64 [NaN, NaN, NaN, 6.0]]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0, 6.0], dtype: {:f, 64})
      iex> ExTalib.tema(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN, 6.0]]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0, 6.0], type: :f64)
      iex> ExTalib.tema(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN, 6.0]]
          >
        }}

  """
  @doc type: :overlap_studies
  @spec tema(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec tema(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def tema(values_or_dataframe, time_period \\ 30, options \\ [])
  def tema(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:tema, options, dataframe, time_period])
  def tema(values, time_period, options), do: run([:tema, options, values, time_period])
  @doc """
  A bang! version of `tema/3`. It does **not** perform any validations.

  Please refer to `tema/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `tema/3`.
  """
  @doc type: :overlap_studies
  @spec tema!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec tema!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def tema!(values_or_dataframe, time_period \\ 30, options \\ [])
  def tema!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:tema, options, dataframe, time_period])
  def tema!(values, time_period, options), do: run!([:tema, options, values, time_period])


  @doc """
  Calculates the **True Range** indicator.

  `TA-LIB` source name: `TRANGE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
     `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `trange`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.trange(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 4]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          trange f64 [NaN, 3.0, 3.0]
        >}
  ## Example Using Series:
      iex> [high, low, close] = [Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.trange(high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 3.0, 3.0]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low, close] = [Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.trange(high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 3.0, 3.0]
          >
        }}

  """
  @doc type: :volatility_indicators
  @spec trange(dataframe :: Explorer.DataFrame.t(), nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec trange(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def trange(high_or_dataframe, low \\ nil, close \\ nil, options \\ [])
  def trange(dataframe, nil, nil, options) when is_dataframe(dataframe), do: run_df([:trange, options, dataframe])
  def trange(high, low, close,  options), do: run([:trange, options, high, low, close])
  @doc """
  A bang! version of `trange/4`. It does **not** perform any validations.

  Please refer to `trange/4` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `trange/4`.
  """
  @doc type: :volatility_indicators
  @spec trange!(dataframe :: Explorer.DataFrame.t(), nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec trange!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def trange!(high_or_dataframe, low \\ nil, close \\ nil, options \\ [])
  def trange!(dataframe, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:trange, options, dataframe])
  def trange!(high, low, close, options), do: run!([:trange, options, high, low, close])


  @doc """
  Calculates the **Triangular Moving Average** indicator.

  `TA-LIB` source name: `TRIMA`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `trima`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.trima(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          trima_2 f64 [NaN, 3.5, 4.5]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.trima(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 3.5, 4.5]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.trima(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 3.5, 4.5]
          >
        }}

  """
  @doc type: :overlap_studies
  @spec trima(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec trima(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def trima(values_or_dataframe, time_period \\ 30, options \\ [])
  def trima(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:trima, options, dataframe, time_period])
  def trima(values, time_period, options), do: run([:trima, options, values, time_period])
  @doc """
  A bang! version of `trima/3`. It does **not** perform any validations.

  Please refer to `trima/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `trima/3`.
  """
  @doc type: :overlap_studies
  @spec trima!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec trima!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def trima!(values_or_dataframe, time_period \\ 30, options \\ [])
  def trima!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:trima, options, dataframe, time_period])
  def trima!(values, time_period, options), do: run!([:trima, options, values, time_period])


  @doc """
  Calculates the **1-day Rate-Of-Change (ROC) of a Triple Smooth EMA** indicator.

  `TA-LIB` source name: `TRIX`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `trix`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0, 6.0, 7.0]})
      iex> ExTalib.trix(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[5 x 2]
          values f64 [3.0, 4.0, 5.0, 6.0, 7.0]
          trix_2 f64 [NaN, NaN, NaN, NaN, 22.222222222222232]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0, 6.0, 7.0], dtype: {:f, 64})
      iex> ExTalib.trix(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, NaN, NaN, 22.222222222222232]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0, 6.0, 7.0], type: :f64)
      iex> ExTalib.trix(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, NaN, NaN, 22.222222222222232]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec trix(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec trix(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def trix(values_or_dataframe, time_period \\ 30, options \\ [])
  def trix(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:trix, options, dataframe, time_period])
  def trix(values, time_period, options), do: run([:trix, options, values, time_period])
  @doc """
  A bang! version of `trix/3`. It does **not** perform any validations.

  Please refer to `trix/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `trix/3`.
  """
  @doc type: :momentum_indicators
  @spec trix!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec trix!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def trix!(values_or_dataframe, time_period \\ 30, options \\ [])
  def trix!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:trix, options, dataframe, time_period])
  def trix!(values, time_period, options), do: run!([:trix, options, values, time_period])


  @doc """
  Calculates the **Time Series Forecast** indicator.

  `TA-LIB` source name: `TSF`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `tsf`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.tsf(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          tsf_2 f64 [NaN, 5.0, 6.0]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.tsf(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 5.0, 6.0]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.tsf(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 5.0, 6.0]
          >
        }}

  """
  @doc type: :statistic_functions
  @spec tsf(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec tsf(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def tsf(values_or_dataframe, time_period \\ 30, options \\ [])
  def tsf(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:tsf, options, dataframe, time_period])
  def tsf(values, time_period, options), do: run([:tsf, options, values, time_period])
  @doc """
  A bang! version of `tsf/3`. It does **not** perform any validations.

  Please refer to `tsf/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `tsf/3`.
  """
  @doc type: :statistic_functions
  @spec tsf!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec tsf!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def tsf!(values_or_dataframe, time_period \\ 30, options \\ [])
  def tsf!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:tsf, options, dataframe, time_period])
  def tsf!(values, time_period, options), do: run!([:tsf, options, values, time_period])


  @doc """
  Calculates the **Typical Price** indicator.

  `TA-LIB` source name: `TYPPRICE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `typprice`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.typprice(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 4]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          typprice f64 [3.3333333333333335, 4.333333333333333, 5.333333333333333]
        >}
  ## Example Using Series:
      iex> [high, low, close] = [Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.typprice(high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [3.3333333333333335, 4.333333333333333, 5.333333333333333]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low, close] = [Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.typprice(high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [3.3333333333333335, 4.333333333333333, 5.333333333333333]
          >
        }}

  """
  @doc type: :price_transform
  @spec typprice(dataframe :: Explorer.DataFrame.t(), nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec typprice(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def typprice(high_or_dataframe, low \\ nil, close \\ nil, options \\ [])
  def typprice(dataframe, nil, nil, options) when is_dataframe(dataframe), do: run_df([:typprice, options, dataframe])
  def typprice(high, low, close,  options), do: run([:typprice, options, high, low, close])
  @doc """
  A bang! version of `typprice/4`. It does **not** perform any validations.

  Please refer to `typprice/4` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `typprice/4`.
  """
  @doc type: :price_transform
  @spec typprice!(dataframe :: Explorer.DataFrame.t(), nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec typprice!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def typprice!(high_or_dataframe, low \\ nil, close \\ nil, options \\ [])
  def typprice!(dataframe, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:typprice, options, dataframe])
  def typprice!(high, low, close, options), do: run!([:typprice, options, high, low, close])


  @doc """
  Calculates the **Ultimate Oscillator** indicator.

  `TA-LIB` source name: `ULTOSC`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `ultosc`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.ultosc(df, nil, nil, 2, 2, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 4]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          ultosc_2_2_2 f64 [NaN, NaN, 33.333333333333336]
        >}
  ## Example Using Series:
      iex> [high, low, close] = [Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.ultosc(high, low, close, 2, 2, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, NaN, 33.333333333333336]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low, close] = [Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.ultosc(high, low, close, 2, 2, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, NaN, 33.333333333333336]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec ultosc(dataframe :: Explorer.DataFrame.t(), nil, nil, first_period :: integer(), second_period :: integer(), third_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec ultosc(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), first_period :: integer(), second_period :: integer(), third_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def ultosc(high_or_dataframe, low \\ nil, close \\ nil, first_period \\ 7, second_period \\ 14, third_period \\ 28, options \\ [])
  def ultosc(dataframe, nil, nil, first_period, second_period, third_period, options) when is_dataframe(dataframe), do: run_df([:ultosc, options, dataframe, first_period, second_period, third_period])
  def ultosc(high, low, close, first_period, second_period, third_period, options), do: run([:ultosc, options, high, low, close, first_period, second_period, third_period])
  @doc """
  A bang! version of `ultosc/7`. It does **not** perform any validations.

  Please refer to `ultosc/7` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `ultosc/7`.
  """
  @doc type: :momentum_indicators
  @spec ultosc!(dataframe :: Explorer.DataFrame.t(), nil, nil, first_period :: integer(), second_period :: integer(), third_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec ultosc!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), first_period :: integer(), second_period :: integer(), third_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def ultosc!(high_or_dataframe, low \\ nil, close \\ nil, first_period \\ 7, second_period \\ 14, third_period \\ 28, options \\ [])
  def ultosc!(dataframe, nil, nil, first_period, second_period, third_period, options) when is_dataframe(dataframe), do: run_df!([:ultosc, options, dataframe, first_period, second_period, third_period])
  def ultosc!(high, low, close, first_period, second_period, third_period, options), do: run!([:ultosc, options, high, low, close, first_period, second_period, third_period])


  @doc """
  Calculates the **Variance** indicator.

  `TA-LIB` source name: `VAR`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      *Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      *Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `var`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.var(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          var_2_1.0 f64 [NaN, 0.25, 0.25]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.var(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 0.25, 0.25]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.var(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 0.25, 0.25]
          >
        }}

  """
  @doc type: :statistic_functions
  @spec var(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), deviations :: float(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec var(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), deviations :: float(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def var(values_or_dataframe, time_period \\ 5, deviations \\ 1.0, options \\ [])
  def var(dataframe, time_period, deviations, options) when is_dataframe(dataframe), do: run_df([:var, options, dataframe, time_period, deviations])
  def var(values, time_period, deviations, options), do: run([:var, options, values, time_period, deviations])
  @doc """
  A bang! version of `var/4`. It does **not** perform any validations.

  Please refer to `var/4` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `var/4`.
  """
  @doc type: :statistic_functions
  @spec var!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), deviations :: float(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec var!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), deviations :: float(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def var!(values_or_dataframe, time_period \\ 5, deviations \\ 1.0, options \\ [])
  def var!(dataframe, time_period, deviations, options) when is_dataframe(dataframe), do: run_df!([:var, options, dataframe, time_period, deviations])
  def var!(values, time_period, deviations, options), do: run!([:var, options, values, time_period, deviations])


  @doc """
  Calculates the **Weighted Close Price** indicator.

  `TA-LIB` source name: `WCLPRICE`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `wclprice`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0], low: [2.0, 3.0, 4.0], close: [3.0, 4.0, 5.0]})
      iex> ExTalib.wclprice(df)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 4]
          close f64 [3.0, 4.0, 5.0]
          high f64 [5.0, 6.0, 7.0]
          low f64 [2.0, 3.0, 4.0]
          wclprice f64 [3.25, 4.25, 5.25]
        >}
  ## Example Using Series:
      iex> [high, low, close] = [Explorer.Series.from_list([5.0, 6.0, 7.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})]
      iex> ExTalib.wclprice(high, low, close)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [3.25, 4.25, 5.25]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low, close] = [Nx.tensor([5.0, 6.0, 7.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0])]
      iex> ExTalib.wclprice(high, low, close)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [3.25, 4.25, 5.25]
          >
        }}

  """
  @doc type: :price_transform
  @spec wclprice(dataframe :: Explorer.DataFrame.t(), nil, nil, options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec wclprice(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def wclprice(high_or_dataframe, low \\ nil, close \\ nil, options \\ [])
  def wclprice(dataframe, nil, nil, options) when is_dataframe(dataframe), do: run_df([:wclprice, options, dataframe])
  def wclprice(high, low, close,  options), do: run([:wclprice, options, high, low, close])
  @doc """
  A bang! version of `wclprice/4`. It does **not** perform any validations.

  Please refer to `wclprice/4` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `wclprice/4`.
  """
  @doc type: :price_transform
  @spec wclprice!(dataframe :: Explorer.DataFrame.t(), nil, nil, options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec wclprice!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def wclprice!(high_or_dataframe, low \\ nil, close \\ nil, options \\ [])
  def wclprice!(dataframe, nil, nil, options) when is_dataframe(dataframe), do: run_df!([:wclprice, options, dataframe])
  def wclprice!(high, low, close, options), do: run!([:wclprice, options, high, low, close])


  @doc """
  Calculates the **Williams' %R**.

  `TA-LIB` source name: `WILLR`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `high`, `low`, `close`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `willr`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{high: [5.0, 6.0, 7.0, 8.0, 9.0], low: [2.0, 3.0, 4.0, 5.0, 6.0], close: [3.0, 4.0, 5.0, 6.0, 7.0]})
      iex> ExTalib.willr(df, nil ,nil, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[5 x 4]
          close f64 [3.0, 4.0, 5.0, 6.0, 7.0]
          high f64 [5.0, 6.0, 7.0, 8.0, 9.0]
          low f64 [2.0, 3.0, 4.0, 5.0, 6.0]
          willr_2 f64 [NaN, -50.0, -50.0, -50.0, -50.0]
        >}
  ## Example Using Series:
      iex> [high, low, close] = [Explorer.Series.from_list([5.0, 6.0, 7.0, 8.0, 9.0], dtype: {:f, 64}), Explorer.Series.from_list([2.0, 3.0, 4.0, 5.0, 6.0], dtype: {:f, 64}), Explorer.Series.from_list([3.0, 4.0, 5.0, 6.0, 7.0], dtype: {:f, 64})]
      iex> ExTalib.willr(high, low, close, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[5]
            f64 [NaN, -50.0, -50.0, -50.0, -50.0]
          >
        }}

  ## Example Using Tensors:
      iex> [high, low, close] = [Nx.tensor([5.0, 6.0, 7.0, 8.0, 9.0], type: :f64), Nx.tensor([2.0, 3.0, 4.0, 5.0, 6.0], type: :f64), Nx.tensor([3.0, 4.0, 5.0, 6.0, 7.0], type: :f64)]
      iex> ExTalib.willr(high, low, close, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[5]
            [NaN, -50.0, -50.0, -50.0, -50.0]
          >
        }}

  """
  @doc type: :momentum_indicators
  @spec willr(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec willr(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def willr(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 14, options \\ [])
  def willr(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df([:willr, options, dataframe, time_period])
  def willr(high, low, close, time_period, options), do: run([:willr, options, high, low, close, time_period])
  @doc """
  A bang! version of `willr/5`. It does **not** perform any validations.

  Please refer to `willr/5` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `willr/5`.
  """
  @doc type: :momentum_indicators
  @spec willr!(dataframe :: Explorer.DataFrame.t(), nil, nil, time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec willr!(high :: Explorer.Series.t() | Nx.Tensor.t(), low :: Explorer.Series.t() | Nx.Tensor.t(), close :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def willr!(high_or_dataframe, low \\ nil, close \\ nil, time_period \\ 14, options \\ [])
  def willr!(dataframe, nil, nil, time_period, options) when is_dataframe(dataframe), do: run_df!([:willr, options, dataframe, time_period])
  def willr!(high, low, close, time_period, options), do: run!([:willr, options, high, low, close, time_period])


  @doc """
  Calculates the **Weighted Moving Average** indicator.

  `TA-LIB` source name: `WMA`

  ## Expected Columns
    If input type is `Explorer.DataFrame`, it is expected to have the columns:
      `values`

  ## Options
    * `:in_columns` - [String.t()].
      A list of column names to use on the input DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

    * `:out_columns` - [String.t()].
      A list of column names to use on the output DataFrame instead of defaults.
      Only applies when input is `Explorer.DataFrame`.

  ## Output
    - `wma`, type: `[:f64]`

  ## Example Using a DataFrame:
      iex> df = Explorer.DataFrame.new(%{values: [3.0, 4.0, 5.0]})
      iex> ExTalib.wma(df, 2)
      {:ok,
        #Explorer.DataFrame<
          Polars[3 x 2]
          values f64 [3.0, 4.0, 5.0]
          wma_2 f64 [NaN, 3.6666666666666665, 4.666666666666667]
        >}

  ## Example Using Series:
      iex> series = Explorer.Series.from_list([3.0, 4.0, 5.0], dtype: {:f, 64})
      iex> ExTalib.wma(series, 2)
      {:ok,
        {
          #Explorer.Series<
            Polars[3]
            f64 [NaN, 3.6666666666666665, 4.666666666666667]
          >
        }}

  ## Example Using Tensors:
      iex> tensor = Nx.tensor([3.0, 4.0, 5.0], type: :f64)
      iex> ExTalib.wma(tensor, 2)
      {:ok,
        {
          #Nx.Tensor<
            f64[3]
            [NaN, 3.6666666666666665, 4.666666666666667]
          >
        }}

  """
  @doc type: :overlap_studies
  @spec wma(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, Explorer.DataFrame.t()} | {:error, [String.t()]}
  @spec wma(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {:ok, {Explorer.Series.t() | Nx.Tensor.t()}} | {:error, [String.t()]}
  def wma(values_or_dataframe, time_period \\ 30, options \\ [])
  def wma(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df([:wma, options, dataframe, time_period])
  def wma(values, time_period, options), do: run([:wma, options, values, time_period])
  @doc """
  A bang! version of `wma/3`. It does **not** perform any validations.

  Please refer to `wma/3` documentation for more information.

  ## Notes
  - **No validations are performed.** It may raise errors or produce incorrect results if provided with invalid inputs.
  - For a version that includes input / output validations and error handling, use `wma/3`.
  """
  @doc type: :overlap_studies
  @spec wma!(dataframe :: Explorer.DataFrame.t(), time_period :: integer(), options :: Keyword.t()) :: Explorer.DataFrame.t()
  @spec wma!(values :: Explorer.Series.t() | Nx.Tensor.t(), time_period :: integer(), options :: Keyword.t()) :: {Explorer.Series.t() | Nx.Tensor.t()}
  def wma!(values_or_dataframe, time_period \\ 30, options \\ [])
  def wma!(dataframe, time_period, options) when is_dataframe(dataframe), do: run_df!([:wma, options, dataframe, time_period])
  def wma!(values, time_period, options), do: run!([:wma, options, values, time_period])

end
