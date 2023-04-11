defmodule WeatherReport.RSSParser do
  @moduledoc false
  # https://github.com/manukall/feeder_ex/blob/master/lib/feeder_ex/parser.ex

  @doc false
  def event(
        {:feed, {:feed, author, id, image, language, link, subtitle, summary, title, updated}},
        {_, entries}
      ) do
    feed = %{
      author: undefined_to_nil(author),
      id: undefined_to_nil(id),
      image: undefined_to_nil(image),
      language: undefined_to_nil(language),
      link: undefined_to_nil(link),
      subtitle: undefined_to_nil(subtitle),
      summary: undefined_to_nil(summary),
      title: undefined_to_nil(title),
      updated: undefined_to_nil(updated)
    }

    {feed, entries}
  end

  def event(
        {:entry,
         {:entry, author, duration, enclosure, id, image, link, subtitle, summary, title, updated}},
        {feed, entries}
      ) do
    entry = %{
      author: undefined_to_nil(author),
      duration: undefined_to_nil(duration),
      enclosure: parse_enclosure(enclosure),
      id: undefined_to_nil(id),
      image: undefined_to_nil(image),
      link: undefined_to_nil(link),
      subtitle: undefined_to_nil(subtitle),
      summary: undefined_to_nil(summary),
      title: undefined_to_nil(title),
      updated: undefined_to_nil(updated)
    }

    {feed, [entry | entries]}
  end

  def event(:endFeed, {feed, entries}) do
    Map.put(feed, :entries, Enum.reverse(entries))
  end

  @doc false
  def opts do
    [event_state: {nil, []}, event_fun: &__MODULE__.event/2]
  end

  defp undefined_to_nil(:undefined), do: nil
  defp undefined_to_nil(value), do: value

  defp parse_enclosure(:undefined), do: nil

  defp parse_enclosure({:enclosure, url, size, type}) do
    %{
      url: undefined_to_nil(url),
      size: undefined_to_nil(size),
      type: undefined_to_nil(type)
    }
  end
end
