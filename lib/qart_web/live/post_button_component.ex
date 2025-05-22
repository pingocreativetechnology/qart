defmodule QartWeb.PostButtonComponent do
  use Phoenix.LiveComponent

  @impl true
  def update(assigns, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <button
      type="button"
      phx-click="submit_post"
      class="inline-flex justify-center rounded-md px-3 py-2 text-sm font-semibold  shadow-sm ring-1 ring-inset text-gray-900 bg-white  hover:bg-gray-50 ring-gray-300">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="-ml-0.5 mr-1.5 size-5 text-slate-400">
        <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125" />
      </svg>
      <span>Post</span>
    </button>
    """
  end
end
