defmodule WeatherReport.StationRegistry do

  @moduledoc false
  use GenServer
  alias WeatherReport.{Station, Distance}

  @doc """
  Starts the station registry.
  """
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc """
  Initializes the station registry ets table then sends a message 
  to itself to signal to retrieve the station list.  This is so the application
  can continue to start without waiting for the list to be downloaded.
  """
  def init([]) do
    tab = :ets.new(:station_registry, [:private])
    {:ok, tab, {:continue, :get_list}}
  end

  @doc """
  Looks up a station by id in ets
  {by, what}
  where by can be:
  :by_station_id
  :by_state
  :nearest
    Calculates the distance between a point and all of the stations, and returns the nearest one.

  or :all for full list
  """
  def handle_call({:by_station_id, station_id}, _from, tab) do
    case :ets.match(tab, {station_id, :_, :_, :"$1"}) do
      [[match]] -> {:reply, {:ok, match}, tab}
      [] -> {:reply, {:error, :not_found}, tab}
    end
  end

  def handle_call({:by_state, state}, _from, tab) do
    results =
      :ets.match(tab, {:_, state, :_, :"$1"})
      |> List.flatten()

    {:reply, results, tab}
  end

  def handle_call({:nearest, coords1}, _from, tab) do
    station_id =
      :ets.match(tab, {:"$1", :_, :"$2", :_})
      |> List.flatten()
      |> Stream.chunk_every(2)
      |> Stream.map(fn [id, coords2] -> {id, Distance.calc(coords1, coords2)} end)
      |> Enum.sort(fn {_, d1}, {_, d2} -> d1 < d2 end)
      |> hd()
      |> elem(0)

    [[station]] = :ets.match(tab, {station_id, :_, :_, :"$1"})

    {:reply, station, tab}
  end

  def handle_call(:all, _from, tab) do
    results =
      :ets.match(tab, {:_, :_, :_, :"$1"})
      |> List.flatten()

    {:reply, results, tab}
  end



  @doc """
  Wipes the station list from ets and re-retrieves it.
  """
  def handle_cast(:refresh_list, tab) do
  true = :ets.delete_all_objects(tab)
  {:noreply, tab, {:continue, :get_list}}
  end

    @doc """
  Retrieves the station list and inserts it into ets.
  """
  def handle_continue(:get_list, tab) do
    entries =
      Station.station_list()
      |> Enum.map(fn station ->
        {station.station_id, station.state, {station.latitude, station.longitude}, station}
      end)

    true = :ets.insert(tab, entries)
    {:noreply, tab}
  end
end
