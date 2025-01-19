defmodule BottichWeb.ListOverviewLive do
  alias Bottich.BottichLists.List
  alias Bottich.BottichLists
  alias Bottich.Validators
  require Logger
  use BottichWeb, :live_view

  def mount(_params, _session, socket) do
    lists = BottichLists.list_lists(socket.assigns.current_user.id)
    {:ok, socket |> stream(:lists, lists) |> assign(list_loading: true, list_to_delete: nil)}
  end

  def render(assigns) do
    ~H"""
    <.modal id="list-deletion-modal" on_cancel={JS.push("unset_list")}>
      <div :if={@list_loading == false}>
        <h2 class="text-xl font-semibold">
          delete list <span class="underline">{@list_to_delete.name}</span>?
        </h2>
        <p class="text-sm">all links will be lost!</p>
        <.button type="button" phx-click={JS.push("delete_list") |> hide_modal("list-deletion-modal")}>
          delete
        </.button>
      </div>
      <div :if={@list_loading}>
        <p>loading...</p>
      </div>
    </.modal>
    <div class="bg-gray-50 p-1 sm:p-10">
      <div class="flex flex-cols-2 justify-between items-center">
        <div>
          <.header>Your lists</.header>
        </div>
        <div>
          <button
            type="button"
            phx-click="new_list"
            class="text-sm border border-black px-1 [box-shadow:2px_2px_black] hover:bg-zinc-200"
          >
            new list
          </button>
        </div>
      </div>
      <div class="h-6" />
      <div class="grid sm:grid-cols-2 grid-cols-1 gap-x-2 gap-y-3" phx-update="stream" id="lists">
        <div
          :for={{list_id, list} <- @streams.lists}
          id={list_id}
          class="grid grid-cols-3 border border-2 border-black p-1 [box-shadow:6px_6px_black] hover:[box-shadow:6px_6px_gray]"
        >
          <div class="col-span-2">
            <.link navigate={~p"/list/#{list.id}"}>
              <p>{list.name}</p>
            </.link>
          </div>
          <div class="flex justify-end">
            <%!-- <button type="button" phx-click="delete_list" phx-value-id={list.id}>
              <.icon name="hero-trash" class="hover:opacity-70" />
            </button> --%>
            <button
              type="button"
              phx-click={JS.push("set_list") |> show_modal("list-deletion-modal")}
              phx-value-id={list.id}
            >
              <.icon name="hero-trash" class="hover:opacity-70" />
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("new_list", _unsigned_params, socket) do
    {:noreply, socket |> push_navigate(to: ~p"/newlist")}
  end

  def handle_event("set_list", %{"id" => list_id}, socket) do
    case Validators.validate_int_id(list_id) do
      {:ok, integer_list_id} ->
        case BottichLists.get_list(
               socket.assigns.current_user.id,
               integer_list_id
             ) do
          %List{} = list ->
            {:noreply, socket |> assign(list_loading: false, list_to_delete: list)}

          nil ->
            Logger.error("list fetch returned empty list")
            {:noreply, socket |> put_flash(:error, "list not found our you don't have access")}
        end

      {:error} ->
        Logger.error("someone tried passing a invalid integer to set_list handler")
        {:ok, socket |> push_navigate(to: "/") |> put_flash(:error, "Invalid parameter")}
    end
  end

  def handle_event("unset_list", _unsigned_params, socket) do
    {:noreply, socket |> assign(list_loading: true, list_to_delete: nil)}
  end

  def handle_event("delete_list", _unsigned_params, socket) do
    case BottichLists.delete_list(socket.assigns.list_to_delete) do
      {:ok, list} ->
        handle_event("unset_list", %{}, socket)
        {:noreply, socket |> stream_delete(:lists, list)}

      {:error, _} ->
        Logger.error("an error occurred deleting list #{socket.assigns.list_to_delete.id}")
        handle_event("unset_list", %{}, socket)
        {:noreply, socket |> put_flash(:error, "an error occurred deleting the list")}
    end
  end
end
