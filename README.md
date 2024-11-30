# ExTalib
Nif Wrapper Implementation for TA-LIB.

It will use system installed TA-LIB so you must install that first.

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

<!-- If [available in Hex](https://hex.pm/docs/publish), the package can be installed -->
The package can be installed by adding `ex_talib` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    <!-- {:ex_talib, "~> 0.1.0"} -->
    {:ex_talib,, git: "https://github.com/ozitrance/ex_talib"}
  ]
end
```

<!-- Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_talib>. -->


## Functions List
This package includes all the available functions from the official TALib library. For the full list check out [their website](https://ta-lib.org/functions/).

## Usage
Each function can be used with either an `Explorer.DataFrame`, `Explorer.Series` or `Nx.Tensor`. If using a dataframe, the function expects come columns to exist (check the function documntation to find which ones or use `options` to use others).

The output will be the same as the input (input of a dataframe will return a dataframe, series will return a series...)

The function will validate the inputs and will return either `{:ok, result}` on success or `{:error, errors}` in case of failure.

`errors` is a list of `String` errors.
`result` is either an `Explorer.DataFrame` (in case the input was a dataframe) or a `list` of [`Explorer.Series`] or [`Nx.Tensor`]s


## Options
All functions has an `options` list as their last argument.
Currently the only valid options are: `in_columns` and `out_columns` and they are only relevant when the input is a DataFrame. With those options you can control which columns will be used as the inputs and which names will be used for the outputs. This is useful when the function expect columns you don't have, or you want more control on the output names.

For example, many functions accept your dataframe to have the `values`. If you want to use the `close` value instead, and don't want to duplicate or rename your columns, you can do things like this:
```elixir
ExTalib.rsi(df, 14, [in_columns: ["close"]])

ExTalib.correl(df, nil, 30, [in_columns: ["btc_close", "eth_close"], out_columns: ["btc_eth_correl"]])

ExTalib.bbands(df, nil, 30, [in_columns: ["close"], out_columns: ["bbands_up", "bbands_mid", "bbands_low"]])

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
