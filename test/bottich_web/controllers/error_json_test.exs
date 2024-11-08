defmodule BottichWeb.ErrorJSONTest do
  use BottichWeb.ConnCase, async: true

  test "renders 404" do
    assert BottichWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert BottichWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
