defmodule WeatherReport.Station do
  @moduledoc """
  NOAA observation station.
  """
  
  import SweetXml
  @xmap [
    station_id: ~x"//station/station_id/text()"s,
    state: ~x"//station/state/text()"s,
    station_name: ~x"//station/station_name/text()"s,
    latitude: ~x"//station/latitude/text()"s,
    longitude: ~x"//station/longitude/text()"s,
    html_url: ~x"//station/html_url/text()"s,
    rss_url: ~x"//station/rss_url/text()"s,
    xml_url: ~x"//station/xml_url/text()"s
  ]
  
  defstruct [
    station_id: nil, 
    state: nil, 
    station_name: nil, 
    latitude: nil, 
    longitude: nil, 
    html_url: nil, 
    rss_url: nil, 
    xml_url: nil
  ]
    
  @type t :: %__MODULE__{
    station_id: String.t, 
    state: String.t, 
    station_name: String.t, 
    latitude: float, 
    longitude: float, 
    html_url: String.t, 
    rss_url: String.t, 
    xml_url: String.t
  }
  
  @doc """
  Parses an xml document into a station.
  """
  @spec parse(String.t) :: t
  def parse(doc) do
    doc
    |> SweetXml.stream_tags(:station)
    |> Stream.map(&station_xmapper/1)
    |> Stream.map(&update_coordinate(&1, :latitude))
    |> Stream.map(&update_coordinate(&1, :longitude))
    |> Stream.map(&struct(__MODULE__, &1))
    |> Enum.to_list()
  end
  
  defp station_xmapper({:station, doc}), do: SweetXml.xmap(doc, @xmap)
  
  defp update_coordinate(station, key), do: Map.update!(station, key, &parse_coordinate/1)
  
  defp parse_coordinate(coordinate) do
    {float, _} = Float.parse(coordinate)
    float
  end
end