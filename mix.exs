defmodule Qart.MixProject do
  use Mix.Project

  def project do
    [
      app: :qart,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),

      # Added for Wallaby
      test_coverage: [tool: ExCoveralls],
      # preferred_cli_env: [
      #   :test,
      #   "test.watch": :test
      # ],
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Qart.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bandit, "~> 1.6.10"},
      {:bcrypt_elixir, "~> 3.3.0"},
      {:bsv, "~> 2.1"},
      {:cloak_ecto, "~> 1.1"},
      {:commanded, "~> 1.4"},
      {:commanded_eventstore_adapter, "~> 1.4"},
      {:eventstore, "~> 1.4.8"},

      {:ecto_sql, "~> 3.10"},
      {:esbuild, "~> 0.9", runtime: Mix.env() == :dev},
      {:floki, ">= 0.37.1", only: :test},
      {:phoenix, "~> 1.7.20"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 4.2.1"},
      {:phoenix_live_reload, "~> 1.6.0", only: :dev},
      {:phoenix_live_view, "~> 1.0.10"},
      {:postgrex, ">= 0.20.0"},
      {:phoenix_live_dashboard, "~> 0.8.7"},
      {:phoenix_view, ">= 2.0.4"},
      {:phoenix_html_helpers, "~> 1.0"},
      {:tailwind, "~> 0.3.1", runtime: Mix.env() == :dev},
      {:heroicons,
        github: "tailwindlabs/heroicons",
        tag: "v2.1.1",
        sparse: "optimized",
        app: false,
        compile: false,
        depth: 1
      },
      {:mogrify, "~> 0.9.1"}, # to process images
      {:swoosh, "~> 1.18.3"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.1.0"},
      {:telemetry_poller, "~> 1.2.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2.0"},
      {:handkit, "~> 0.2", git: "https://github.com/afomi/handkit.git", branch: "wip"},
      {:uuid, "~> 1.1"},
      # For tests
      {:faker, "~> 0.17", only: [:dev, :test]},
      {:tesla, "~> 1.14.1"},

      {:dotenv, "~> 3.1.0", only: [:dev, :test]},
      {:ex_machina, "~> 2.8.0", only: :test},
      {:wallaby, "~> 0.30.0", only: :test},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind qart", "esbuild qart"],
      "assets.deploy": [
        "tailwind qart --minify",
        "esbuild qart --minify",
        "phx.digest"
      ]
    ]
  end
end
