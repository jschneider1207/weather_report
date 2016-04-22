defmodule WeatherReport.Forecast.RSS do
  @moduledoc """
  Forecast parsed from a NOAA station RSS feed.
  """
  alias WeatherReport.RSSParser
  
  defstruct [
    timestamp: nil,
    link: nil,
    html_summary: nil,
    text: nil
  ]
    
  @type t :: %__MODULE__{
    timestamp: String.t,
    link: String.t,
    html_summary: String.t,
    text: String.t
  }
  
  @doc """
  Parses an rss feed into a forecast.
  """
  @spec parse(String.t) :: t
  def parse(feed) do
    case :feeder.stream(feed, RSSParser.opts) do
      {:ok, %{entries: [entry]}, ""} -> 
        %__MODULE__{
          timestamp: entry.id,
          link: entry.link,
          html_summary: entry.summary,
          text: entry.title
        }
      _ ->
        %__MODULE__{}
    end
  end
end