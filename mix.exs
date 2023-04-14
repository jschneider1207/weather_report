defmodule WeatherReport.Mixfile do
  use Mix.Project

  def project do
    [
      app: :weather_report,
      version: "0.3.0",
      elixir: "~> 1.12",
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {WeatherReport.Application, []}
    ]
  end

  defp deps do
    [
      {:feeder, "~> 2.3"},
      {:sweet_xml, "~> 0.7"},
      {:httpoison, "~> 2.1"},
      {:earmark, "~> 1.4", only: :dev},
      {:ex_doc, "~> 0.29", only: :dev}
    ]
  end

  defp description do
    """
    Get weather forecasts from the National Oceanic and Atmospheric Administration!

    As the NOAA is a United States government agency, only forecasts in the US are supported.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Jess Schneider"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jschneider1207/weather_report"}
    ]
  end
end
