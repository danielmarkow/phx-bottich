defmodule BottichWeb.AboutController do
  use BottichWeb, :controller

  def about(conn, _params) do
    render(conn, :about)
  end
end
