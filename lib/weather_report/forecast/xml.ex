defmodule WeatherReport.Forecast.XML do
  @moduledoc """
  Forecast parsed from a NOAA station XML feed.  
  Contains more detailed information than a forecast from a station RSS feed.
  """
  
  import SweetXml    
  @xmapper [
    suggested_pickup: ~x"//current_observation/suggested_pickup/text()"s,
    suggested_pickup_period: ~x"//current_observation/suggested_pickup_period/text()"s,
    location: ~x"//current_observation/location/text()"s,
    station_id: ~x"//current_observation/station_id/text()"s,
    latitude: ~x"//current_observation/latitude/text()"s,
    longitude: ~x"//current_observation/longitude/text()"s,
    observation_time: ~x"//current_observation/observation_time/text()"s,
    observation_time_rfc822: ~x"//current_observation/observation_time_rfc822/text()"s,
    weather: ~x"//current_observation/weather/text()"s,
    temperature_string: ~x"//current_observation/temperature_string/text()"s,
    temp_f: ~x"//current_observation/temp_f/text()"s,
    temp_c: ~x"//current_observation/temp_c/text()"s,
    relative_humidity: ~x"//current_observation/relative_humidity/text()"s,
    wind_string: ~x"//current_observation/wind_string/text()"s,
    wind_dir: ~x"//current_observation/wind_dir/text()"s,
    wind_degrees: ~x"//current_observation/wind_degrees/text()"s,
    wind_mph: ~x"//current_observation/wind_mph/text()"s,
    wind_kt: ~x"//current_observation/wind_kt/text()"s,
    pressure_in: ~x"//current_observation/pressure_in/text()"s,
    dewpoint_string: ~x"//current_observation/dewpoint_string/text()"s,
    dewpoint_f: ~x"//current_observation/dewpoint_f/text()"s,
    dewpoint_c: ~x"//current_observation/dewpoint_c/text()"s,
    visibility_mi: ~x"//current_observation/visibility_mi/text()"s,
    icon_url_base: ~x"//current_observation/icon_url_base/text()"s,
    icon_url_name: ~x"//current_observation/icon_url_name/text()"s
  ]

  defstruct [
    suggested_pickup: nil,
    suggested_pickup_period: nil,
    location: nil,
    station_id: nil,
    latitude: nil,
    longitude: nil,
    observation_time: nil,
    observation_time_rfc822: nil,
    weather: nil,
    temperature_string: nil,
    temp_f: nil,
    temp_c: nil,
    relative_humidity: nil,
    wind_string: nil,
    wind_dir: nil,
    wind_degrees: nil,
    wind_mph: nil,
    wind_kt: nil,
    pressure_in: nil,
    dewpoint_string: nil,
    dewpoint_f: nil,
    dewpoint_c: nil,
    visibility_mi: nil,
    icon_url: nil    
  ]
    
  @type t :: %__MODULE__{
    suggested_pickup: String.t,
    suggested_pickup_period: integer,
    location: String.t,
    station_id: String.t,
    latitude: float,
    longitude: float,
    observation_time: String.t,
    observation_time_rfc822: String.t,
    weather: String.t,
    temperature_string: String.t,
    temp_f: float,
    temp_c: float,
    relative_humidity: integer,
    wind_string: String.t,
    wind_dir: String.t,
    wind_degrees: integer,
    wind_mph: float,
    wind_kt: integer,
    pressure_in: float,
    dewpoint_string: String.t,
    dewpoint_f: float,
    dewpoint_c: float,
    visibility_mi: float,
    icon_url: String.t
  }
  
  @doc """
  Parses an xml document into a forecast.
  """
  @spec parse(String.t) :: t
  def parse(doc) do
    map = 
      SweetXml.xmap(doc, @xmapper)
      |> fix_types()
      |> combine_icon()
    struct(__MODULE__, map)
  end
  
  defp fix_types(map) do
    %{map |
      suggested_pickup_period: parse_num(Integer, map.suggested_pickup_period),
      latitude: parse_num(Float, map.latitude),
      longitude: parse_num(Float, map.longitude),
      temp_f: parse_num(Float, map.temp_f),
      temp_c: parse_num(Float, map.temp_c),
      relative_humidity: parse_num(Integer, map.relative_humidity),
      wind_degrees: parse_num(Integer, map.wind_degrees),
      wind_mph: parse_num(Float, map.wind_mph),
      wind_kt: parse_num(Integer, map.wind_kt),
      pressure_in: parse_num(Float, map.pressure_in),
      dewpoint_f: parse_num(Float, map.dewpoint_f),
      dewpoint_c: parse_num(Float, map.dewpoint_c),
      visibility_mi: parse_num(Float, map.visibility_mi)}
  end
  
  defp combine_icon(map) do
    map
    |> Map.put(:icon_url, map.icon_url_base <> map.icon_url_name)
    |> Map.drop([:icon_url_base, :icon_url_name])
  end
  
  defp parse_num(module, string_num) do
    case module.parse(string_num) do
      {num, _} -> num
      :error -> nil
    end
  end
end