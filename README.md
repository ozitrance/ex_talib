# ExTalib

Nif Implementation for TA-LIB.

It will use system installed TA-LIB

## Install TA-LIB (Ubunut)

```sh
apt-get update
apt-get install gcc build-essential wget
wget https://github.com/TA-Lib/ta-lib/raw/refs/heads/main/dist/ta-lib-0.6.0-src.tar.gz
tar -zxvf ta-lib-0.6.0-src.tar.gz
rm ta-lib-0.6.0-src.tar.gz
cd ta-lib
./configure --prefix=/usr
make
make install
cd ../
rm -rf ta-lib
```

## Install TA-LIB (Mac OS)

```sh
brew install ta-lib
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `talib_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:talib_ex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/talib_ex>.
