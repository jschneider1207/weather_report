defmodule WeatherReport.Forecast.RSS do
  @moduledoc """
  Forecast parsed from a NOAA station RSS feed.
  """
  alias WeatherReport.RSSParser

  defstruct timestamp: nil,
            link: nil,
            html_summary: nil,
            title: nil

  @type t :: %__MODULE__{
          timestamp: String.t(),
          link: String.t(),
          html_summary: String.t(),
          title: String.t()
        }

  @doc """
  Parses an rss feed into a forecast.
  """
  @spec parse(String.t()) :: t
  def parse(feed) do
    case :feeder.stream(feed, RSSParser.opts()) do
      {:ok, [entry], ""} ->
        entry
      _ ->
        %__MODULE__{}
    end
  end
end
