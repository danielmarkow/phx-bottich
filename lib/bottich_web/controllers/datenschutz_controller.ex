defmodule BottichWeb.DatenschutzController do
  use BottichWeb, :controller

  def datenschutz(conn, _params) do
    render(conn, :datenschutz)
  end
end
