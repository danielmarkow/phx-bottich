defmodule BottichWeb.PublicListLive do
  alias Bottich.Validators
  require Logger
  use BottichWeb, :live_view

  def mount(%{"list_id" => list_id}, _session, socket) do
    case Validators.validate_int_id(list_id) do
      {:ok, integer} ->
        {:ok, socket |> assign(list_id: integer)}

      {:error} ->
        Logger.error("someone tried passing a invalid integer to /public/list/:list_id")
        {:ok, socket |> push_navigate(to: "/") |> put_flash(:error, "Invalid url parameter")}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      hello public
      <p>{@list_id}</p>
    </div>
    """
  end
end
