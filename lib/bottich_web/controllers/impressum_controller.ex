defmodule BottichWeb.ImpressumController do
  use BottichWeb, :controller

  def impressum(conn, _params) do
    render(conn, :impressum)
  end
end
