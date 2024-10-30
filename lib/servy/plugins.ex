defmodule Servy.Plugins do
  require Logger
  @wildthings_regex ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}

  def track(%{status: 404, path: path} = conv) do
    Logger.warning("#{path} is on the loose")
    conv
  end

  def track(conv), do: conv

  def emojojify(%{status: 200} = conv) do
    emojies = String.duplicate("🎉", 5)
    %{conv | resp_body: emojies <> "\n" <> conv.resp_body <> "\n" <> emojies}
  end

  def emojojify(conv), do: conv

  def rewrite_path(%{path: "/wildthings"} = conv) do
    %{conv | path: "/wildlife"}
  end

  def rewrite_path(%{path: "/bears?id=" <> id} = conv) do
    %{conv | path: "/bears/" <> id}
  end

  def rewrite_path(%{path: path} = conv) do
    captures = Regex.named_captures(@wildthings_regex, path)
    rewrite_path_captures(conv, captures)
  end

  defp rewrite_path_captures(conv, %{"things" => things, "id" => id}) do
    %{conv | path: "#{things}/#{id}"}
  end

  defp rewrite_path_captures(conv, nil), do: conv
end
