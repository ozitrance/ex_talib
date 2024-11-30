defmodule ExTalib.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_talib,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:elixir_make | Mix.compilers()],
      make_makefile: "Makefile",
      description: description(),
      package: package()
]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      ############# REQUIRED ###############
      {:ex_const, "~> 0.3.0"},
      {:ex_doc, "~> 0.35.1", only: :dev, runtime: false},
      {:elixir_make, "~> 0.9.0", runtime: false},





      ############# OPTIONAL ###############
      # {:explorer, "~> 0.10.0"},
      # {:nx, "~> 0.9.2"},



      # ############## DEV/TEMP ###############
      # {:jason, "~> 1.4.4"},

      ############# USE UNTIL PUBLISHED ###############
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp package do
    # Docs
    [
      name: "ex_talib",
      source_url: "https://github.com/MortadaAK/talib_ex",
      homepage_url: "https://github.com/MortadaAK/talib_ex",
      links: %{
        "GitHub" => "https://github.com/MortadaAK/talib_ex"
      },
      licenses: ["Apache-2.0"],
      docs: [
        main: "ExTALib",
        extras: ["README.md"]
      ],
      files: ["lib", "LICENSE", "mix.exs", "README.md", "c_src/ex_talib.c", "Makefile"]
    ]
  end

  defp description do
    "A NIF wrapper for TA-LIB for usage with Explorer and Nx libraries."
  end


end
