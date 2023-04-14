defmodule WeatherReport.Distance do
  @moduledoc """
  Distance related functions.
  """

  # earth's radius
  @r 6_371_000

  @type coordinate :: {float, float}

  @doc """
  Calculates the distance (in meters) between two lat long coordinates by using the `haversine` forumla:

      a = sin²(Δφ/2) + cos φ1 * cos φ2 * sin²(Δλ/2)
      c = 2 * atan2( √a, √(1−a) )
      d = R * c

  where	φ is latitude, λ is longitude, R is earth’s radius (mean radius = 6,371km)  
  """
  @spec calc(coordinate, coordinate) :: float
  def calc({lat1, long1}, {lat2, long2}) do
    phi1 = to_radians(lat1)
    phi2 = to_radians(lat2)
    delta_phi = to_radians(lat2 - lat1)
    delta_gamma = to_radians(long2 - long1)

    a =
      :math.sin(delta_phi / 2) * :math.sin(delta_phi / 2) +
        :math.cos(phi1) * :math.cos(phi2) *
          :math.sin(delta_gamma / 2) * :math.sin(delta_gamma / 2)

    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))
    @r * c
  end

  defp to_radians(degree), do: degree * :math.pi() / 180
end
