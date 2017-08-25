defmodule VideoChat.Template do
  require EEx

  def render(template_name) do
    EEx.eval_file("web/views/#{template_name}.html")
  end
end
