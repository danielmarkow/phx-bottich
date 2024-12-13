defmodule BottichWeb.PageController do
  use BottichWeb, :controller

  def home(conn, _params) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: ~p"/list")
    else
      conn
    end
    render(conn, :home, layout: false)
  end
end
