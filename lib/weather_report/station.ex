defmodule WeatherReport.Station do
  @moduledoc """
  NOAA observation station.
  """

  import SweetXml, only: [sigil_x: 2]

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

  defstruct station_id: nil,
            state: nil,
            station_name: nil,
            latitude: nil,
            longitude: nil,
            html_url: nil,
            rss_url: nil,
            xml_url: nil

  @type t :: %__MODULE__{
          station_id: String.t(),
          state: String.t(),
          station_name: String.t(),
          latitude: float,
          longitude: float,
          html_url: String.t(),
          rss_url: String.t(),
          xml_url: String.t()
        }

  @doc """
  Parses an xml document into a station.
  """
  @spec parse_station(String.t()) :: t
  def parse_station(doc) do
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

  @station_list "https://w1.weather.gov/xml/current_obs/index.xml"

  def station_list do
    with {:ok, %HTTPoison.AsyncResponse{id: ref}} <-
           HTTPoison.get(@station_list, %{}, stream_to: self()),
         {:ok, doc} <- receive_async(ref, ""),
         do: parse_station(doc)
  end

  defp receive_async(ref, doc) do
    alias HTTPoison, as: HP

    receive do
      %HP.AsyncStatus{code: code, id: ^ref} when code in 200..399 ->
        receive_async(ref, doc)

      %HP.AsyncStatus{code: code, id: ^ref} ->
        {:error, "Unable to fetch station list, http #{code}"}

      %HP.AsyncHeaders{id: ^ref} ->
        receive_async(ref, doc)

      %HP.AsyncChunk{chunk: chunk, id: ^ref} ->
        receive_async(ref, doc <> chunk)

      %HP.AsyncEnd{id: ^ref} ->
        {:ok, doc}
    end
  end
end
