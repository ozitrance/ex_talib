# ExTalib

Nif Wrapper Implementation for TA-LIB.

It will use system installed TA-LIB

## Install TA-LIB (Ubunut)

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

## Installation

You must have either Nx or Explorer to use this library. It must be installed before or together with this library.
If you installed this library first and later Nx or Explorer you might get errors. In this case clean up your dependencies library and just get them all again:
```sh
mix deps.clean --all
mix deps.get
```

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_talib` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    <!-- {:ex_talib, "~> 0.1.0"} -->
    {:ex_talib,, git: "https://github.com/ozitrance/ex_talib"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_talib>.
