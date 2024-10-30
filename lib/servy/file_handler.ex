defmodule Servy.FileHandler do
  @pages_path Path.expand("../../pages", __DIR__)
  def get_page(file_name) do
    Path.join(@pages_path, file_name)
  end

  def handle_file({:ok, content}, conv) do
    %{conv | status: 200, resp_body: content}
  end

  def handle_file({:error, :enoent}, conv) do
    %{conv | status: 404, resp_body: "File not found!"}
  end

  def handle_file({:error, reason}, conv) do
    %{conv | status: 500, resp_body: "File error #{reason}"}
  end
end
