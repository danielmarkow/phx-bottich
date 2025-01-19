defmodule BottichWeb.PublicListLive do
  alias Bottich.BottichLists
  alias Bottich.Validators
  alias BottichWeb.ListComponent
  require Logger
  use BottichWeb, :live_view

  def mount(%{"list_id" => list_id}, _session, socket) do
    case Validators.validate_int_id(list_id) do
      {:ok, integer_list_id} ->
        list = BottichLists.get_public_list!(integer_list_id)

        if list == nil do
          {:ok,
           socket
           |> push_navigate(to: "/")
           |> put_flash(:error, "list does not exist or is not public")}
        else
          empty = if length(list.links) > 0, do: false, else: true
          {:ok,
           socket
           |> stream(:links, list.links)
           |> assign(list_id: integer_list_id, list: Map.drop(list, [:links]), empty: empty)}
        end

      {:error} ->
        Logger.error("someone tried passing a invalid integer to /public/list/:list_id")
        {:ok, socket |> push_navigate(to: "/") |> put_flash(:error, "Invalid url parameter")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="bg-gray-50 p-1 sm:p-10">
      <.header class="text-center">
        {@list.name}
        <:subtitle>{@list.description}</:subtitle>
      </.header>
      <div class="h-6" />
      <div :if={@empty == false} phx-update="stream" id="links" class="flex flex-col gap-y-2">
        <ListComponent.public_list_entry :for={{link_id, link} <- @streams.links} link_id={link_id} link={link} />
      </div>
      <div :if={@empty == true} class="flex flex-col gap-y-2">
        <div class="border border-2 border-black p-1 [box-shadow:6px_6px_black]">
          no entries yet
        </div>
      </div>
      <div class="h-6" />
    </div>
    """
  end
end
