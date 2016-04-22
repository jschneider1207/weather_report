defmodule WeatherReport.Mixfile do
  use Mix.Project

  def project do
    [app: :weather_report,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.2",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end
  
  def application do
    [applications: [:logger, :feeder, :sweet_xml, :httpoison],
     mod: {WeatherReport, []}]
  end
  
  defp deps do
    [{:feeder, "~> 2.0.0", compile: false},
     {:sweet_xml, "~> 0.6.1"},
     {:httpoison, "~> 0.8.3"},
     {:earmark, "~> 0.2.1", only: :dev},
     {:ex_doc, "~> 0.11.4", only: :dev}]
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
      maintainers: ["Sam Schneider"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/sschneider1207/weather_report"}]
  end
end
