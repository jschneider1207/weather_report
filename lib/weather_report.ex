defmodule WeatherReport do
  @moduledoc """
  Retrieve weather reports from NOAA!
  """

  alias WeatherReport.{Station, StationRegistry, Forecast}
  alias HTTPoison.Response

  @type forecast_format :: :rss | :xml | {:raw, :rss} | {:raw, :xml}
  @doc """
  Retrieves a list of all available observation stations.
  """
  @spec station_list :: [Station.t()]
  def station_list do
    GenServer.call(StationRegistry, :all)
  end

  @doc """
  Searches for a station by id.
  """
  @spec get_station(String.t()) :: {:ok, Station.t()} | {:error, :not_found}
  def get_station(station_id) do
    GenServer.call(StationRegistry, {:by_station_id, station_id})
  end

  @doc """
  Searches for stations by state.
  """
  @spec get_stations(String.t()) :: [Station.t()]
  def get_stations(state) do
    GenServer.call(StationRegistry, {:by_state, state})
  end

  @doc """
  Gets the nearest station to a coordinate pair.
  """
  @spec nearest_station(float, float) :: Station.t()
  def nearest_station(lat, long) do
    GenServer.call(StationRegistry, {:nearest, {lat, long}})
  end

  @doc """
  Gets the most recent forecast for a given station id.
  """
  @spec get_forecast(String.t() | WeatherReport.Station.t(), forecast_format) :: Forecast.t()
  def get_forecast(station_or_id, type \\ :rss)

  def get_forecast(station_id, type)
      when is_binary(station_id) do
    with {:ok, station} <- get_station(station_id),
         do: get_forecast(station, type)
  end

  def get_forecast(station, type) do
    url =
      case type do
        {:raw, subtype} when subtype in [:rss, :xml] ->
          get_url(station, subtype)

        ntype when ntype in [:rss, :xml] ->
          get_url(station, ntype)
      end

    with {:ok, %Response{body: body} = resp} <-
           HTTPoison.get(url, %{}, follow_redirect: true),
         do:
           (case type do
              {:raw, _} ->
                body

              _ ->
                Forecast.parse(body, type)
            end)
  end

@doc """
Refresh cached stations.
"""
@spec refresh_stations() :: :ok
  def refresh_stations() do
    :ok = GenServer.cast(StationRegistry, :refresh_list)
  end

  defp get_url(%Station{rss_url: url}, :rss), do: url
  defp get_url(%Station{xml_url: url}, :xml), do: url
end
