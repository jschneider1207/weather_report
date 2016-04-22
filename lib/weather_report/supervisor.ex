defmodule WeatherReport.Supervisor do
  @moduledoc false
  use Supervisor
  
  @doc """
  Starts a supervised StationRegistry
  """
  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  @doc false
  def init([]) do
    children = [
      worker(WeatherReport.StationRegistry, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end