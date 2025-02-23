defmodule QartWeb.TipComponent do
  use Phoenix.LiveComponent

  @impl true
  def update(assigns, socket) do
    IO.puts("------TIP_OPEN-------------------->")
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("follow", %{"value" => followed_user_id}, socket) do

    if socket.assigns.is_following do
      # {:noreply, assign(socket, is_following: false)}
      assign(socket, is_following: false)
      {:noreply, socket}
    else
      {:noreply, assign(socket, is_following: true)}
    end

  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>

    <%= if @open do %>
      <div class="flex flex-col items-center space-y-4">
        <div
          class="flex items-center space-x-2 bg-white p-2 rounded-full shadow-md">
          <div
            class="flex items-center space-x-2 bg-gray-100 p-2 rounded-full shadow-md">
            <button
              type="button"
              id="decrement"
              class="rounded-full bg-indigo-600 p-1.5 text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">
              <span class="sr-only">Previous</span>
              <svg xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5"
              aria-hidden="true" data-slot="icon">
                <path stroke-linecap="round" stroke-linejoin="round" d="M5 12h14" />
              </svg>
            </button>
            <!-- Displayed Value -->
            <span id="valueDisplay" class="text-2xl font-bold w-20 text-center">$1.00</span>
            <button
              type="button"
              id="increment"
              class="rounded-full bg-indigo-600 p-1.5 text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">
              <span class="sr-only">Next</span>
              <svg class="size-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true" data-slot="icon">
                <path d="M10.75 4.75a.75.75 0 0 0-1.5 0v4.5h-4.5a.75.75 0 0 0 0 1.5h4.5v4.5a.75.75 0 0 0 1.5 0v-4.5h4.5a.75.75 0 0 0 0-1.5h-4.5v-4.5Z" />
              </svg>
            </button>
          </div>
          <button
            type="button"
            id="submit"
            class="px-6 py-3 bg-blue-500 font-semibold rounded-full shadow-md text-white hover:bg-blue-600">
            Pay
            <%= @target_user.display_name %>
          </button>
        </div>
      </div>

    <script>
      // document.addEventListener("DOMContentLoaded", function () {
        let value = 1.00;
        const valueDisplay = document.getElementById("valueDisplay");
        const incrementBtn = document.getElementById("increment");
        const decrementBtn = document.getElementById("decrement");

        incrementBtn.addEventListener("click", function () {
          value = parseFloat((value + 0.10).toFixed(2));
          valueDisplay.textContent = `$${value.toFixed(2)}`;
        });

        decrementBtn.addEventListener("click", function () {
          value = Math.max(0.10, parseFloat((value - 0.10).toFixed(2)));
          valueDisplay.textContent = `$${value.toFixed(2)}`;
        });
      // });
    </script>
    <% end %>
    </div>
    """
  end
end
