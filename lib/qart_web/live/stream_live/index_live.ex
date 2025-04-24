defmodule QartWeb.StreamLive do
  use QartWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    {:ok, socket}
  end

end
