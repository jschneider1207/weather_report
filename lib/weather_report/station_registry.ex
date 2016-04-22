defmodule WeatherReport.StationRegistry do
  @moduledoc false
  use GenServer
  alias WeatherReport.{Station, Distance}
  alias HTTPoison.{AsyncResponse, AsyncStatus, AsyncHeaders, AsyncChunk, AsyncEnd}
  @station_list "http://w1.weather.gov/xml/current_obs/index.xml"
  
  @doc """
  Starts the station registry.
  """
  def start_link do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end
  
  @doc """
  Initializes the station registry ets table then sends a message 
  to itself to signal to retrieve the station list.  This is so the application
  can continue to start without waiting for the list to be downloaded.
  """
  def init([]) do
    tab = :ets.new(:station_registry, [:private])
    send(self, :get_list)
    {:ok, tab}
  end
  
  @doc """
  Looks up a station by id in ets
  """
  def handle_call({:by_station_id, station_id}, _from, tab) do
    case :ets.match(tab, {station_id, :"_", :"_", :"$1"}) do
      [[match]] -> {:reply, {:ok, match}, tab}
      [] -> {:reply, {:error, :not_found}, tab}
    end
  end
  @doc """
  Looks up stations by state in ets
  """
  def handle_call({:by_state, state}, _from, tab) do
    results = 
      :ets.match(tab, {:"_", state, :"_", :"$1"})
      |> List.flatten()
    {:reply, results, tab}
  end
  @doc """
  Calculates the distance between a point and all of the stations, and returns the nearest one.
  """
  def handle_call({:nearest, coords1}, _from, tab) do
    station_id = 
      :ets.match(tab, {:"$1", :"_", :"$2", :"_"})
      |> List.flatten()
      |> Stream.chunk(2)
      |> Stream.map(fn [id, coords2] -> {id, Distance.calc(coords1, coords2)} end)
      |> Enum.sort(fn {_, d1}, {_, d2} -> d1 < d2 end)
      |> hd()
      |> elem(0)
    
    [[station]] = :ets.match(tab, {station_id, :"_", :"_", :"$1"})
    
    {:reply, station, tab}
  end
  @doc """
  Gets the full station list.
  """
  def handle_call(:all, _from, tab) do
    results = 
      :ets.match(tab, {:"_", :"_", :"_", :"$1"})
      |> List.flatten()
    {:reply, results, tab}
  end
  
  @doc """
  Retrieves the station list and inserts it into ets.
  """
  def handle_info(:get_list, tab) do
    entries =
      station_list()
      |> Enum.map(fn station -> {station.station_id, station.state, {station.latitude, station.longitude}, station} end)
    true = :ets.insert(tab, entries)
    {:noreply, tab}
  end
  
  defp station_list do
    with {:ok, %AsyncResponse{id: ref}} <- HTTPoison.get(@station_list, %{}, stream_to: self),
      {:ok, doc} <- receive_async(ref, ""),
      do: Station.parse(doc)
  end
  
  defp receive_async(ref, doc) do
    receive do
      %AsyncStatus{code: code, id: ^ref} when code in 200..399 ->
        receive_async(ref, doc)
      %AsyncStatus{code: code, id: ^ref} ->
        {:error, "Unable to fetch station list, http #{code}"}
      %AsyncHeaders{id: ^ref} ->
        receive_async(ref, doc)
      %AsyncChunk{chunk: chunk, id: ^ref} ->
        receive_async(ref, doc <> chunk)
      %AsyncEnd{id: ^ref} ->
        {:ok, doc}
    end    
  end
end