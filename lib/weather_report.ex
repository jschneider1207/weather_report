defmodule WeatherReport do
  @moduledoc """
  Retrieve weather reports from NOAA!
  """
  use Application
  
  @doc false
  def start(_, _) do
    WeatherReport.Supervisor.start_link
  end
  
  alias WeatherReport.{Station, StationRegistry, Forecast}
  alias HTTPoison.Response
  
  @type forecast_format :: :rss | :xml
  @doc """
  Retrieves a list of all available observation stations.
  """
  @spec station_list :: [Station.t]
  def station_list do
    GenServer.call(StationRegistry, :all)
  end
  
  @doc """
  Searches for a station by id.
  """
  @spec get_station(String.t) :: {:ok, Station.t} | {:error, :not_found}
  def get_station(station_id) do
    GenServer.call(StationRegistry, {:by_station_id, station_id})
  end
  
  @doc """
  Searches for stations by state.
  """
  @spec get_stations(String.t) :: [Station.t]
  def get_stations(state) do
    GenServer.call(StationRegistry, {:by_state, state})
  end
  
  @doc """
  Gets the nearest station to a coordinate pair.
  """
  @spec nearest_station(float, float) :: Station.t
  def nearest_station(lat, long) do
    GenServer.call(StationRegistry, {:nearest, {lat, long}})
  end
  
  @doc """
  Gets the most recent forecast for a given station id.
  """
  @spec get_forecast(String.t, forecast_format) :: Forecast.t
  def get_forecast(station_id, type \\ :rss) when type in [:rss, :xml] do
    with {:ok, station} <- get_station(station_id),
      url = get_url(station, type),
      {:ok, %Response{body: body}} <- HTTPoison.get(url, %{}, [follow_redirect: true]),
      do: Forecast.parse(body)
  end
  
  defp get_url(%Station{rss_url: url}, :rss), do: url
  defp get_url(%Station{xml_url: url}, :xml), do: url
end
