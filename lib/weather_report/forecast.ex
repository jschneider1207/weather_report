defmodule WeatherReport.Forecast do
  @moduledoc """
  Parse a document into a forecast.
  """
  require Logger

  alias WeatherReport.Forecast.{RSS, XML}

  @type t :: RSS.t() | XML.t()

  @doc """
  Parses an rss or xml document into a forecast.
  """
  @spec parse(String.t(), :xml | :rss) :: {:ok, t} | {:error, String.t()}
  def parse(~s(<?xml version="1.0" encoding="ISO-8859-1"?>) <> feed, :rss) do
    Logger.info(feed)
    parse(feed, :rss)
  end

  def parse(feed, :rss) do
    {:ok, RSS.parse(feed)}
  end

  def parse(doc, :xml) do
    {:ok, XML.parse(doc)}
  end

  def parse(_) do
    {:error, "Unable to determine document type"}
  end
end
