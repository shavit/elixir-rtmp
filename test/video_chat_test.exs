defmodule VideoChatTest do
  use ExUnit.Case
  doctest VideoChat

  test "render template" do
    VideoChat.Template.render("live")
    |> String.length
    |> assert > 200
  end
end
