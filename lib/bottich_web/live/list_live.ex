defmodule BottichWeb.ListLive do
  alias Bottich.BottichLists.List
  alias Bottich.BottichLink.Link
  alias Bottich.BottichLink
  alias Bottich.BottichLists
  alias Bottich.Validators
  alias BottichWeb.ListComponent
  require Logger
  use BottichWeb, :live_view

  def mount(%{"list_id" => list_id}, _session, socket) do
    case Validators.validate_int_id(list_id) do
      {:ok, integer_list_id} ->
        list = BottichLists.get_list(socket.assigns.current_user.id, integer_list_id)
        changeset = BottichLink.change_link(%Link{})
        empty = if length(list.links) > 0, do: false, else: true

        {:ok,
         socket
         |> stream(:links, list.links)
         |> assign(
           list_id: integer_list_id,
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
    <.modal id="visibility-modal">
      <h2 class="text-xl font-semibold">change privacy settings</h2>
      <div class="h-6" />
      <div :if={@list.public == false}>
        <p>this list is private</p>
        <div class="h-2" />
        <.button type="button" phx-click={JS.push("toggle_public") |> hide_modal("visibility-modal")}>
          set public
        </.button>
      </div>
      <div :if={@list.public}>
        <p>
          list publicly available at:
          <.link href={~p"/public/list/#{@list_id}"} class="underline">
            {url(~p"/")}public/list/{@list_id}
          </.link>
          <button type="button" phx-click={JS.dispatch("phx:clipcopy", to: "#public-link")}>
            <.icon name="hero-clipboard-document" class="h-8 w-8 sm:h-5 sm:w-5 cursor-pointer" />
          </button>
        </p>
        <div class="h-6" />
        <.button type="button" phx-click={JS.push("toggle_public") |> hide_modal("visibility-modal")}>
          set private
        </.button>
      </div>
    </.modal>
    <div class="bg-gray-50 p-1 sm:p-10">
      <.header class="text-center">
        {@list.name}
        <:subtitle>{@list.description}</:subtitle>
      </.header>
      <div class="h-1" />
      <div class="text-center">
        <p>
          <%= if @list.public do %>
            <div class="flex gap-x-1 justify-center text-sm text-zinc-600">
              <div class="flex items-center gap-x-1">
                this list is <span class="font-semibold">public</span>
                at
                <.link
                  class="underline cursor-pointer text-sm text-zinc-800"
                  href={~p"/public/list/#{@list_id}"}
                  id="public-link"
                >
                  {url(~p"/")}public/list/{@list_id}
                </.link>
              </div>
              <button type="button" phx-click={JS.dispatch("phx:clipcopy", to: "#public-link")}>
                <.icon name="hero-clipboard-document" class="h-8 w-8 sm:h-5 sm:w-5 cursor-pointer" />
              </button>
            </div>
            <div class="h-1" />
            <p
              class="underline cursor-pointer text-sm text-zinc-800"
              phx-click={show_modal("visibility-modal")}
            >
              click to change
            </p>
          <% else %>
            <div class="text-sm text-zinc-600">
              this list is <span class="font-semibold">private</span>
              <span class="underline cursor-pointer" phx-click={show_modal("visibility-modal")}>
                click to change
              </span>
            </div>
          <% end %>
        </p>
      </div>
      <div class="h-6" />
      <div :if={@empty == false} phx-update="stream" id="links" class="flex flex-col gap-y-2">
        <ListComponent.list_entry
          :for={{link_id, link} <- @streams.links}
          link_id={link_id}
          link={link}
        />
      </div>
      <div :if={@empty == true} class="flex flex-col gap-y-2">
        <div class="border border-2 border-black p-1 [box-shadow:6px_6px_black]">
          no entries yet
        </div>
      </div>
      <div class="h-6" />
      <div id="link-editor" class="border border-2 border-black p-1 [box-shadow:6px_6px_black]">
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
              <.secondary_button type="button" phx-click="abort_edit">
                abort
              </.secondary_button>
            </div>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  def handle_event("save", link_params, socket) do
    case BottichLists.get_list(socket.assigns.current_user.id, socket.assigns.list_id) do
      %List{} = list ->
        if socket.assigns.link_id != nil do
          link = Enum.find(list.links, fn link -> link.id == socket.assigns.link_id end)

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
               |> put_flash(
                 :error,
                 "an error occurred updating the link #{socket.assigns.link_id}"
               )}
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

      nil ->
        Logger.error("list fetch returned empty list")
        {:noreply, socket |> put_flash(:error, "list not found or you don't have access")}
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

    {:noreply,
     socket
     |> assign(form: to_form(changeset), link_id: String.to_integer(link_id))
     |> push_event("scroll_to", %{selector: "#link-editor"})}
  end

  def handle_event("delete_link", %{"id" => link_id}, socket) do
    case BottichLists.get_list(socket.assigns.current_user.id, socket.assigns.list_id) do
      %List{} = list ->
        link = Enum.find(list.links, fn link -> link.id == String.to_integer(link_id) end)

        case BottichLink.delete_link(link) do
          {:ok, link} ->
            empty = if length(list.links) - 1 > 0, do: false, else: true
            {:noreply, socket |> assign(empty: empty) |> stream_delete(:links, link)}

          {:error, _} ->
            Logger.error("an error occurred deleting link #{link_id}")
            {:noreply, socket |> put_flash(:error, "an error occurred deleting the link")}
        end

      nil ->
        Logger.error("list fetch returned empty list")
        {:noreply, socket |> put_flash(:error, "list not found or you don't have access")}
    end
  end

  def handle_event("toggle_public", _unsigned_params, socket) do
    case BottichLists.get_list(socket.assigns.current_user.id, socket.assigns.list_id) do
      %List{} = list ->
        case BottichLists.update_list(list, %{public: not list.public}) do
          {:ok, new_list} ->
            {:noreply, socket |> assign(list: new_list)}

          {:error, reason} ->
            Logger.error("failed to toggle public setting", error: inspect(reason))
            {:noreply, socket |> put_flash(:error, "operation failed")}

          nil ->
            Logger.error("list fetch returned empty list")
            {:noreply, socket |> put_flash(:error, "list not found or you don't have access")}
        end
    end
  end
end
