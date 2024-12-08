defmodule BottichWeb.ListNewLive do
  alias Bottich.BottichLists.List
  alias Bottich.BottichLists
  require Logger
  use BottichWeb, :live_view

  def mount(_params, _session, socket) do
    changeset = BottichLists.change_list(%List{})
    {:ok, socket |> assign(form: to_form(changeset))}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-white p-1 sm:p-10">
      <.header>new list</.header>
      <div class="h-6" />
      <div class="border border-2 border-black p-1 [box-shadow:6px_6px_black]">
        <.form for={@form} phx-submit="save_list" phx-change="validate">
          <div class="flex flex-col gap-y-2">
            <.input
              type="text"
              label="name"
              id="name"
              name="name"
              autocomplete="off"
              field={@form[:name]}
            />
            <.input
              type="textarea"
              label="description"
              id="description"
              name="description"
              autocomplete="off"
              field={@form[:description]}
            />
          </div>
          <div class="h-6" />
          <div class="flex justify-center">
            <.button phx-disable-with="saving..." disabled={!@form.source.valid?} class="w-2/3">
              save
            </.button>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  def handle_event("save_list", list_params, socket) do
    case BottichLists.create_list(list_params) do
      {:ok, list} ->
        {:noreply, socket |> push_navigate(to: "/list/#{list.id}")}

      {:error, _} ->
        Logger.error("an error occurred creating a new list /newlist")
        {:noreply, socket |> put_flash(:error, "an error occurred creating the new list")}
    end
  end

  def handle_event("validate", list_params, socket) do
    form = %List{} |> BottichLists.change_list(list_params) |> to_form(action: :validate)
    {:noreply, socket |> assign(form: form)}
  end
end
