defmodule VideoChatTest do
  use ExUnit.Case
  doctest VideoChat

  test "render template" do
    assert((VideoChat.Template.render("live") |> String.length)
      > 200)
  end
end
