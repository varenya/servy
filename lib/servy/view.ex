defmodule Servy.BearView do
  require EEx
  alias Servy.Conv

  @templates_path Path.expand("../../templates", __DIR__)

  EEx.function_from_file(:def, :index, Path.join(@templates_path, "index.eex"), [:bears])
  EEx.function_from_file(:def, :show, Path.join(@templates_path, "show.eex"), [:bear])

  EEx.function_from_file(:def, :new_pledge, Path.join(@templates_path, "new_pledge.eex"))

  EEx.function_from_file(
    :def,
    :recent_pledges,
    Path.join(@templates_path, "recent_pledges.eex"),
    [:pledges]
  )

  EEx.function_from_file(:def, :show_snapshots, Path.join(@templates_path, "snapshots.eex"), [
    :snapshots,
    :bigfoot
  ])

  def render(conv, content) do
    %Conv{
      conv
      | resp_body: content,
        status: 200
    }
  end
end
