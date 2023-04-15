defmodule WeatherReport.RSSParser do
  @moduledoc false

alias WeatherReport.Forecast.RSS

  @doc false
  def event(
        {:feed, _ },
        {_, entries}
      ) do
    # Don't care about feed.
    {nil, entries}
  end

  def event(
        {:entry,
         {:entry, author, categories, duration, enclosure, id, image, link, subtitle, summary, title, updated}=e},
        {_, entries}
      ) do
    {nil, [%RSS{
      timestamp: undefined_to_nil(id),
      link: undefined_to_nil(link),
      html_summary: undefined_to_nil(summary),
      title: undefined_to_nil(title),
    }|entries]}
  end

  def event(:endFeed, {_, entries}) do
    Enum.reverse(entries)
  end

  @doc false
  def opts do
    [event_state: {nil, []}, event_fun: &__MODULE__.event/2]
  end

  defp undefined_to_nil(:undefined), do: nil
  defp undefined_to_nil(value), do: value
end
