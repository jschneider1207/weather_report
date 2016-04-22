defmodule WeatherReport.Forecast do 
  alias WeatherReport.Forecast.{RSS, XML}
  @rss_identifier ~s(<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\r\n\r\n<rss version='2.0' xmlns:dc='http://purl.org/dc/elements/1.1/'>)
  @xml_identifier ~s(<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?> \r\n<?xml-stylesheet href=\"latest_ob.xsl\" type=\"text/xsl\"?>)
  
  @type t :: RSS.t | XML.t
  
  @doc """
  Parses an rss or xml document into a forecast.
  """
  @spec parse(String.t) :: {:ok, t} | {:error, String.t}
  def parse(@rss_identifier <> _ = feed) do
    {:ok, RSS.parse(feed)}
  end
  def parse(@xml_identifier <> doc) do
    {:ok, XML.parse(doc)}
  end
  def parse(_) do
    {:error, "Unable to determine document type"}
  end
end