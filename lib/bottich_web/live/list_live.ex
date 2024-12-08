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
        empty = if length(list.links) > 0, do: false, else: true

        {:ok,
         socket
         |> stream(:links, list.links)
         |> assign(
           list_id: integer,
           list: Map.drop(list, [:links]),
           form: to_form(changeset),
           link_id: nil,
           empty: empty
         )}

      {:error} ->
        Logger.error("someone tried passing a invalid integer to /list/:list_id")
        {:ok, socket |> push_navigate(to: "/") |> put_flash(:error, "Invalid url parameter")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="bg-white p-1 sm:p-10">
      <.header class="text-center">
        {@list.name}
        <:subtitle>{@list.description}</:subtitle>
      </.header>
      <div class="h-6" />
      <div :if={@empty == false} phx-update="stream" id="links" class="flex flex-col gap-y-2">
        <div
          :for={{link_id, link} <- @streams.links}
          class="grid grid-cols-2 sm:grid-cols-5 border border-2 border-black p-1 [box-shadow:6px_6px_black] hover:[box-shadow:6px_6px_gray]"
          id={link_id}
        >
          <div class="col-span-1 sm:col-span-4">
            <a href={link.url} class="underline line-clamp-2">{link.url}</a>
            <p>{link.description}</p>
          </div>
          <div class="flex flex-col items-start gap-y-1">
            <button
              type="button"
              phx-click="edit_link"
              phx-value-id={link.id}
              class="text-sm border border-black px-1 [box-shadow:2px_2px_black] hover:bg-zinc-200 w-full"
            >
              edit
            </button>
            <button
              type="button"
              phx-click="delete_link"
              phx-value-id={link.id}
              class="text-sm border border-black px-1 [box-shadow:2px_2px_black] hover:bg-zinc-200 w-full"
            >
              delete
            </button>
          </div>
        </div>
      </div>
      <div :if={@empty == true} class="flex flex-col gap-y-2">
        <div class="border border-2 border-black p-1 [box-shadow:6px_6px_black]">
          no entries yet
        </div>
      </div>
      <div class="h-6" />
      <div class="border border-2 border-black p-1 [box-shadow:6px_6px_black]">
        <h2 :if={@link_id != nil} class="font-semibold leading-6">edit link</h2>
        <h2 :if={@link_id == nil} class="font-semibold leading-6">new link</h2>
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
            <div :if={@link_id == nil} class="flex justify-center">
              <.button disabled={!@form.source.valid?} phx-disabled-with="saving..." class="w-2/3">
                save
              </.button>
            </div>
            <div :if={@link_id != nil} class="grid grid-cols-2 gap-x-1">
              <.button disabled={!@form.source.valid?} phx-disabled-with="saving...">
                save
              </.button>
              <.button type="button" phx-click="abort_edit">
                abort
              </.button>
            </div>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  def handle_event("save", link_params, socket) do
    if socket.assigns.link_id != nil do
      link = BottichLink.get_link!(socket.assigns.link_id)

      case BottichLink.update_link(link, link_params) do
        {:ok, link} ->
          changeset = BottichLink.change_link(%Link{})

          {:noreply,
           socket
           |> stream_insert(:links, link)
           |> assign(link_id: nil, form: to_form(changeset), empty: false)}

        {:error, _changeset} ->
          Logger.error("an error occurred updating link")

          {:noreply,
           socket
           |> put_flash(:error, "an error occurred updating the link #{socket.assigns.link_id}")}
      end
    else
      # Ecto.build_assoc wants atoms
      attrs = Map.new(link_params, fn {key, val} -> {String.to_existing_atom(key), val} end)

      case BottichLink.create_link(attrs, socket.assigns.list) do
        {:ok, link} ->
          changeset = BottichLink.change_link(%Link{})

          {:noreply,
           socket
           |> stream_insert(:links, link, at: -1)
           |> assign(form: to_form(changeset), empty: false)}

        {:error, _changeset} ->
          Logger.error("an error occurred saving link")

          {:noreply,
           socket
           |> put_flash(:error, "an error occurred saving the link")}
      end
    end
  end

  def handle_event("validate", link_params, socket) do
    form = %Link{} |> BottichLink.change_link(link_params) |> to_form(action: :validate)
    {:noreply, socket |> assign(form: form)}
  end

  def handle_event("abort_edit", _params, socket) do
    changeset = BottichLink.change_link(%Link{})
    {:noreply, socket |> assign(link_id: nil, form: to_form(changeset))}
  end

  def handle_event("edit_link", %{"id" => link_id}, socket) do
    link = BottichLink.get_link!(link_id)
    changeset = BottichLink.change_link(link)
    {:noreply, socket |> assign(form: to_form(changeset), link_id: link_id)}
  end

  def handle_event("delete_link", %{"id" => link_id}, socket) do
    link = BottichLink.get_link!(link_id)

    case BottichLink.delete_link(link) do
      {:ok, link} ->
        list = BottichLists.get_list!(link.list_id)
        # TODO optimize
        empty = if length(list.links) > 0, do: false, else: true
        {:noreply, socket |> assign(empty: empty) |> stream_delete(:links, link)}

      {:error, _} ->
        Logger.error("an error occurred deleting link #{link_id}")
        {:noreply, socket |> put_flash(:error, "an error occurred deleting the link")}
    end
  end
end
