defmodule Servy.Bear do
  defstruct type: "", name: "", hibernating: false, id: nil

  def is_grizzly(bear) do
    bear.type == "Grizzly"
  end

  def order_by_asc_name(b1, b2) do
    b1.name <= b2.name
  end
end
