defmodule BottichWeb.ListComponent do
  use Phoenix.Component

  def list_entry(assigns) do
    ~H"""
    <div
      class="grid grid-cols-2 sm:grid-cols-5 border border-2 border-black p-1 [box-shadow:6px_6px_black] hover:[box-shadow:6px_6px_gray]"
      id={@link_id}
    >
      <div class="col-span-1 sm:col-span-4">
        <a href={@link.url} class="underline line-clamp-2">{@link.url}</a>
        <p>{@link.description}</p>
      </div>
      <div class="flex flex-col items-start gap-y-1">
        <button
          type="button"
          phx-click="edit_link"
          phx-value-id={@link.id}
          class="text-sm border border-black px-1 [box-shadow:2px_2px_black] hover:bg-zinc-200 w-full"
        >
          edit
        </button>
        <button
          type="button"
          phx-click="delete_link"
          phx-value-id={@link.id}
          class="text-sm border border-black px-1 [box-shadow:2px_2px_black] hover:bg-zinc-200 w-full"
        >
          delete
        </button>
      </div>
    </div>
    """
  end
end
