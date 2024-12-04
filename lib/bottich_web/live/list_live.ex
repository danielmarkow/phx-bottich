defmodule BottichWeb.ListLive do
  alias Bottich.BottichLink.Link
  alias Bottich.BottichLink
  alias Bottich.BottichLists
  alias Bottich.Validators
  require Logger
  use BottichWeb, :live_view

  def mount(%{"list_id" => list_id}, _session, socket) do
    case Validators.validate_int_id(list_id) do
      {:ok, integer} ->
        list = BottichLists.get_list!(list_id)
        changeset = BottichLink.change_link(%Link{})

        {:ok,
         socket
         |> stream(:links, list.links)
         |> assign(list_id: integer, list: Map.drop(list, [:links]), form: to_form(changeset))}

      {:error} ->
        Logger.error("someone tried passing a invalid integer to /list/:list_id")
        {:ok, socket |> put_flash(:error, "Invalid url parameter") |> push_navigate(to: "/")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="bg-white p-1 sm:p-10">
      <.header class="text-center">
        <%= @list.name %>
        <:subtitle><%= @list.description %></:subtitle>
      </.header>
      <div class="h-6" />
      <div phx-update="stream" id="links" class="flex flex-col gap-y-2">
        <div
          :for={{link_id, link} <- @streams.links}
          class="grid grid-cols-4 border border-2 border-black p-1 [box-shadow:6px_6px_black] hover:[box-shadow:6px_6px_gray]"
          id={link_id}
        >
          <div class="col-span-3">
            <a href={link.url} class="underline"><%= link.url %></a>
            <p><%= link.description %></p>
          </div>
          <div class="flex flex-col justify-end gap-y-1">
            <button
              type="button"
              phx-click="edit_link"
              phx-value-id={link.id}
              class="text-sm border border-black px-1 [box-shadow:2px_2px_black] hover:bg-zinc-200"
            >
              edit
            </button>
            <button
              type="button"
              phx-click="delete_link"
              phx-value-id={link.id}
              class="text-sm border border-black px-1 [box-shadow:2px_2px_black] hover:bg-zinc-200"
            >
              delete
            </button>
          </div>
        </div>
      </div>
      <div class="h-6" />
      <div class="border border-2 border-black p-1 [box-shadow:6px_6px_black]">
        <h2 class="font-semibold leading-6 ">new link</h2>
        <.form for={@form} phx-submit="save" phx-change="validate">
          <div class="flex flex-col gap-y-2">
            <.input
              type="text"
              label="url"
              id="url"
              name="url"
              autocomplete="off"
              field={@form[:url]}
            />
            <.input
              type="textarea"
              label="description"
              id="description"
              name="description"
              autocomplete="off"
              field={@form[:description]}
            />
            <div />
            <div class="flex justify-center">
              <.button disabled={!@form.source.valid?} phx-disabled-with="saving..." class="w-2/3">
                save
              </.button>
            </div>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  def handle_event("save", link_params, socket) do
    # Ecto.build_assoc wants atoms
    attrs = Map.new(link_params, fn {key, val} -> {String.to_existing_atom(key), val} end)

    case BottichLink.create_link(attrs, socket.assigns.list) do
      {:ok, link} ->
        {:noreply, socket |> stream_insert(:links, link, at: -1)}

      {:error, changeset} ->
        Logger.error("an error occurred saving link", error: inspect(changeset))
        {:noreply, socket |> put_flash(:error, "an error occurred saving the link")}
    end
  end

  def handle_event("validate", link_params, socket) do
    form = %Link{} |> BottichLink.change_link(link_params) |> to_form(action: :validate)
    {:noreply, socket |> assign(form: form)}
  end

  def handle_event("edit_link", %{"id" => link_id}, socket) do
    {:noreply, socket}
  end

  def handle_event("delete_link", %{"id" => link_id}, socket) do
    link = BottichLink.get_link!(link_id)
    case BottichLink.delete_link(link) do
      {:ok, link} ->
        {:noreply, socket |> stream_delete(:links, link)}
      {:error, _} ->
        Logger.error("an error occurred deleting link #{link_id}")
        {:noreply, socket |> put_flash(:error, "an error occurred deleting the link")}
    end
  end
end
