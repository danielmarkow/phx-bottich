defmodule BottichWeb.ListOverviewLive do
  alias Bottich.BottichLists
  use BottichWeb, :live_view

  def mount(_params, _session, socket) do
    lists = BottichLists.list_lists()
    {:ok, socket |> stream(:lists, lists)}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-white p-1 sm:p-10">
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
      <div class="grid sm:grid-cols-2 grid-cols-1 gap-x-2" phx-update="stream" id="lists">
        <div
          :for={{list_id, list} <- @streams.lists}
          id={list_id}
          class="border border-2 border-black p-1 [box-shadow:6px_6px_black] hover:[box-shadow:6px_6px_gray]"
        >
          <.link navigate={~p"/list/#{list.id}"}>
            <p>{list.name}</p>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("new_list", _unsigned_params, socket) do
    {:noreply, socket |> push_navigate(to: ~p"/newlist")}
  end
end
