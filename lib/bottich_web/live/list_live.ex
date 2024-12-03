defmodule BottichWeb.ListLive do
  alias Bottich.BottichLists
  alias Bottich.Validators
  require Logger
  use BottichWeb, :live_view

  def mount(%{"list_id" => list_id}, _session, socket) do
    case Validators.validate_int_id(list_id) do
      {:ok, integer} ->
        list = BottichLists.get_list!(list_id)

        {:ok,
         socket
         |> stream(:links, list.links)
         |> assign(list_id: integer, list: Map.drop(list, [:links]))}

      {:error} ->
        Logger.error("someone tried passing a invalid integer to /list/:list_id")
        {:ok, socket |> put_flash(:error, "Invalid url parameter") |> push_navigate(to: "/")}
    end
  end

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      <%= @list.name %>
      <:subtitle><%= @list.description %></:subtitle>
    </.header>
    <p><%= @list_id %></p>
    """
  end
end
