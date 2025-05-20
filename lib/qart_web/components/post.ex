defmodule QartWeb.Post do
  use Phoenix.Component
  import QartWeb.UserAvatar

  attr :current_user, Qart.Accounts.User, required: true
  attr :payment_amount, :float, default: 0.0

  def new_post(assigns) do
    ~H"""
    <div class="flex items-start space-x-4">
      <div class="shrink-0">
        <.user_avatar user={@current_user} />
      </div>
      <div class="min-w-0 flex-1">
        <form
          phx-submit="create_post"
          action="#" class="relative">

          <div class="rounded-lg bg-white outline outline-1 -outline-offset-1 outline-gray-300 focus-within:outline focus-within:outline-2 focus-within:-outline-offset-2 focus-within:outline-indigo-600">
            <label for="content" class="sr-only">Add your comment</label>
            <textarea rows="3" name="content" id="content"
              class="block w-full resize-none bg-transparent px-3 py-1.5 text-base text-gray-900 placeholder:text-gray-400 focus:outline focus:outline-0 sm:text-sm/6 border"
              placeholder="Add your comment..."></textarea>

            <!-- Spacer element to match the height of the toolbar -->
            <div class="py-2" aria-hidden="true">
              <!-- Matches height of button in toolbar (1px border + 36px content height) -->
              <div class="py-px">
                <div class="h-9"></div>
              </div>
            </div>
          </div>

          <div class="absolute inset-x-0 bottom-0 flex justify-between py-2 pl-3 pr-2">
            <div class="flex items-center space-x-5">
              <div class="flex items-center">
                <button type="button" class="-m-2.5 flex size-10 items-center justify-center rounded-full text-gray-400 hover:text-gray-500">
                  <svg class="size-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true" data-slot="icon">
                    <path fill-rule="evenodd" d="M15.621 4.379a3 3 0 0 0-4.242 0l-7 7a3 3 0 0 0 4.241 4.243h.001l.497-.5a.75.75 0 0 1 1.064 1.057l-.498.501-.002.002a4.5 4.5 0 0 1-6.364-6.364l7-7a4.5 4.5 0 0 1 6.368 6.36l-3.455 3.553A2.625 2.625 0 1 1 9.52 9.52l3.45-3.451a.75.75 0 1 1 1.061 1.06l-3.45 3.451a1.125 1.125 0 0 0 1.587 1.595l3.454-3.553a3 3 0 0 0 0-4.242Z" clip-rule="evenodd" />
                  </svg>
                  <span class="sr-only">Attach a file</span>
                </button>

                <input type="number"
                  name="payment_amount"
                  step="0.01"
                  value={@payment_amount}
                  class="w-24 ml-2 border rounded"
                  style="padding: 0 0 0 1rem;" />

                <input
                  type="file"
                  name="attachments"
                  multiple
                  class="hidden block border rounded w-36" />
              </div>
              <div class="flex items-center hidden">
                <div>
                  <label id="listbox-label" class="sr-only">Your mood</label>
                  <div class="relative">
                    <button type="button" class="relative -m-2.5 flex size-10 items-center justify-center rounded-full text-gray-400 hover:text-gray-500" aria-haspopup="listbox" aria-expanded="true" aria-labelledby="listbox-label">
                      <span class="flex items-center justify-center">
                        <!-- Placeholder label, show/hide based on listbox state. -->
                        <span>
                          <svg class="size-5 shrink-0" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true" data-slot="icon">
                            <path fill-rule="evenodd" d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm3.536-4.464a.75.75 0 1 0-1.061-1.061 3.5 3.5 0 0 1-4.95 0 .75.75 0 0 0-1.06 1.06 5 5 0 0 0 7.07 0ZM9 8.5c0 .828-.448 1.5-1 1.5s-1-.672-1-1.5S7.448 7 8 7s1 .672 1 1.5Zm3 1.5c.552 0 1-.672 1-1.5S12.552 7 12 7s-1 .672-1 1.5.448 1.5 1 1.5Z" clip-rule="evenodd" />
                          </svg>
                          <span class="sr-only">Add your mood</span>
                        </span>
                        <!-- Selected item label, show/hide based on listbox state. -->
                        <span>
                          <span class="flex size-8 items-center justify-center rounded-full bg-red-500">
                            <svg class="size-5 shrink-0 text-white" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true" data-slot="icon">
                              <path fill-rule="evenodd" d="M13.5 4.938a7 7 0 1 1-9.006 1.737c.202-.257.59-.218.793.039.278.352.594.672.943.954.332.269.786-.049.773-.476a5.977 5.977 0 0 1 .572-2.759 6.026 6.026 0 0 1 2.486-2.665c.247-.14.55-.016.677.238A6.967 6.967 0 0 0 13.5 4.938ZM14 12a4 4 0 0 1-4 4c-1.913 0-3.52-1.398-3.91-3.182-.093-.429.44-.643.814-.413a4.043 4.043 0 0 0 1.601.564c.303.038.531-.24.51-.544a5.975 5.975 0 0 1 1.315-4.192.447.447 0 0 1 .431-.16A4.001 4.001 0 0 1 14 12Z" clip-rule="evenodd" />
                            </svg>
                          </span>
                          <span class="sr-only">Excited</span>
                        </span>
                      </span>
                    </button>

                    <!--
                      Select popover, show/hide based on select state.

                      Entering: ""
                        From: ""
                        To: ""
                      Leaving: "transition ease-in duration-100"
                        From: "opacity-100"
                        To: "opacity-0"
                    -->
                    <ul class="absolute z-10 -ml-6 mt-1 w-60 rounded-lg bg-white py-3 text-base shadow outline outline-1 outline-black/5 sm:ml-auto sm:w-64 sm:text-sm" tabindex="-1" role="listbox" aria-labelledby="listbox-label" aria-activedescendant="listbox-option-5">
                      <!--
                        Select option, manage highlight styles based on mouseenter/mouseleave and keyboard navigation.

                        Highlighted: "bg-gray-100 relative outline-none", Not Highlighted: "bg-white"
                      -->
                      <li class="cursor-default select-none bg-white px-3 py-2" id="listbox-option-0" role="option">
                        <div class="flex items-center">
                          <div class="flex size-8 items-center justify-center rounded-full bg-red-500">
                            <svg class="size-5 shrink-0 text-white" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true" data-slot="icon">
                              <path fill-rule="evenodd" d="M13.5 4.938a7 7 0 1 1-9.006 1.737c.202-.257.59-.218.793.039.278.352.594.672.943.954.332.269.786-.049.773-.476a5.977 5.977 0 0 1 .572-2.759 6.026 6.026 0 0 1 2.486-2.665c.247-.14.55-.016.677.238A6.967 6.967 0 0 0 13.5 4.938ZM14 12a4 4 0 0 1-4 4c-1.913 0-3.52-1.398-3.91-3.182-.093-.429.44-.643.814-.413a4.043 4.043 0 0 0 1.601.564c.303.038.531-.24.51-.544a5.975 5.975 0 0 1 1.315-4.192.447.447 0 0 1 .431-.16A4.001 4.001 0 0 1 14 12Z" clip-rule="evenodd" />
                            </svg>
                          </div>
                          <span class="ml-3 block truncate font-medium">Excited</span>
                        </div>
                      </li>
                      <!--
                        Select option, manage highlight styles based on mouseenter/mouseleave and keyboard navigation.

                        Highlighted: "bg-gray-100 relative outline-none", Not Highlighted: "bg-white"
                      -->
                      <li class="cursor-default select-none bg-white px-3 py-2" id="listbox-option-1" role="option">
                        <div class="flex items-center">
                          <div class="flex size-8 items-center justify-center rounded-full bg-pink-400">
                            <svg class="size-5 shrink-0 text-white" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true" data-slot="icon">
                              <path d="m9.653 16.915-.005-.003-.019-.01a20.759 20.759 0 0 1-1.162-.682 22.045 22.045 0 0 1-2.582-1.9C4.045 12.733 2 10.352 2 7.5a4.5 4.5 0 0 1 8-2.828A4.5 4.5 0 0 1 18 7.5c0 2.852-2.044 5.233-3.885 6.82a22.049 22.049 0 0 1-3.744 2.582l-.019.01-.005.003h-.002a.739.739 0 0 1-.69.001l-.002-.001Z" />
                            </svg>
                          </div>
                          <span class="ml-3 block truncate font-medium">Loved</span>
                        </div>
                      </li>
                      <!--
                        Select option, manage highlight styles based on mouseenter/mouseleave and keyboard navigation.

                        Highlighted: "bg-gray-100 relative outline-none", Not Highlighted: "bg-white"
                      -->
                      <li class="cursor-default select-none bg-white px-3 py-2" id="listbox-option-2" role="option">
                        <div class="flex items-center">
                          <div class="flex size-8 items-center justify-center rounded-full bg-green-400">
                            <svg class="size-5 shrink-0 text-white" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true" data-slot="icon">
                              <path fill-rule="evenodd" d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm3.536-4.464a.75.75 0 1 0-1.061-1.061 3.5 3.5 0 0 1-4.95 0 .75.75 0 0 0-1.06 1.06 5 5 0 0 0 7.07 0ZM9 8.5c0 .828-.448 1.5-1 1.5s-1-.672-1-1.5S7.448 7 8 7s1 .672 1 1.5Zm3 1.5c.552 0 1-.672 1-1.5S12.552 7 12 7s-1 .672-1 1.5.448 1.5 1 1.5Z" clip-rule="evenodd" />
                            </svg>
                          </div>
                          <span class="ml-3 block truncate font-medium">Happy</span>
                        </div>
                      </li>
                      <!--
                        Select option, manage highlight styles based on mouseenter/mouseleave and keyboard navigation.

                        Highlighted: "bg-gray-100 relative outline-none", Not Highlighted: "bg-white"
                      -->
                      <li class="cursor-default select-none bg-white px-3 py-2" id="listbox-option-3" role="option">
                        <div class="flex items-center">
                          <div class="flex size-8 items-center justify-center rounded-full bg-yellow-400">
                            <svg class="size-5 shrink-0 text-white" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true" data-slot="icon">
                              <path fill-rule="evenodd" d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm-3.536-3.475a.75.75 0 0 0 1.061 0 3.5 3.5 0 0 1 4.95 0 .75.75 0 1 0 1.06-1.06 5 5 0 0 0-7.07 0 .75.75 0 0 0 0 1.06ZM9 8.5c0 .828-.448 1.5-1 1.5s-1-.672-1-1.5S7.448 7 8 7s1 .672 1 1.5Zm3 1.5c.552 0 1-.672 1-1.5S12.552 7 12 7s-1 .672-1 1.5.448 1.5 1 1.5Z" clip-rule="evenodd" />
                            </svg>
                          </div>
                          <span class="ml-3 block truncate font-medium">Sad</span>
                        </div>
                      </li>
                      <!--
                        Select option, manage highlight styles based on mouseenter/mouseleave and keyboard navigation.

                        Highlighted: "bg-gray-100 relative outline-none", Not Highlighted: "bg-white"
                      -->
                      <li class="cursor-default select-none bg-white px-3 py-2" id="listbox-option-4" role="option">
                        <div class="flex items-center">
                          <div class="flex size-8 items-center justify-center rounded-full bg-blue-500">
                            <svg class="size-5 shrink-0 text-white" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true" data-slot="icon">
                              <path d="M1 8.25a1.25 1.25 0 1 1 2.5 0v7.5a1.25 1.25 0 1 1-2.5 0v-7.5ZM11 3V1.7c0-.268.14-.526.395-.607A2 2 0 0 1 14 3c0 .995-.182 1.948-.514 2.826-.204.54.166 1.174.744 1.174h2.52c1.243 0 2.261 1.01 2.146 2.247a23.864 23.864 0 0 1-1.341 5.974C17.153 16.323 16.072 17 14.9 17h-3.192a3 3 0 0 1-1.341-.317l-2.734-1.366A3 3 0 0 0 6.292 15H5V8h.963c.685 0 1.258-.483 1.612-1.068a4.011 4.011 0 0 1 2.166-1.73c.432-.143.853-.386 1.011-.814.16-.432.248-.9.248-1.388Z" />
                            </svg>
                          </div>
                          <span class="ml-3 block truncate font-medium">Thumbsy</span>
                        </div>
                      </li>
                      <!--
                        Select option, manage highlight styles based on mouseenter/mouseleave and keyboard navigation.

                        Highlighted: "bg-gray-100 relative outline-none", Not Highlighted: "bg-white"
                      -->
                      <li class="cursor-default select-none bg-white px-3 py-2" id="listbox-option-5" role="option">
                        <div class="flex items-center">
                          <div class="flex size-8 items-center justify-center rounded-full bg-transparent">
                            <svg class="size-5 shrink-0 text-gray-400" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true" data-slot="icon">
                              <path d="M6.28 5.22a.75.75 0 0 0-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 1 0 1.06 1.06L10 11.06l3.72 3.72a.75.75 0 1 0 1.06-1.06L11.06 10l3.72-3.72a.75.75 0 0 0-1.06-1.06L10 8.94 6.28 5.22Z" />
                            </svg>
                          </div>
                          <span class="ml-3 block truncate font-medium">Meh</span>
                        </div>
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
            <div class="shrink-0">
              <button type="submit" class="inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">Post</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    """
  end

  def post(assigns) do
    ~H"""
    <div class="bg-white px-4 pt-5 sm:px-6 border-b border-gray-100">
      <div class="flex space-x-3">
        <div class="shrink-0">
          <.user_avatar user={@current_user} />
        </div>
        <div class="min-w-0 flex-1">
          <p class="text-sm font-semibold text-gray-900">
            <%= if @current_user do %>
            <a href="#" class="hover:underline"><%= assigns.post.user.display_name %></a>
            <% else %>
            <a href="#" class="hover:underline">Not logged in</a>
            <% end %>
          </p>
          <p class="text-sm text-gray-500">
            <a href="#"
              class="hover:underline"
              id="{@post.id}"
              >{Calendar.strftime(@post.inserted_at, "%B %-d at %-I:%M %p")}</a>
          </p>
        </div>
        <div class="flex shrink-0 self-center">
          <div class="relative inline-block text-left">
            <div>
              <button type="button" class="-m-2 flex items-center rounded-full p-2 text-gray-400 hover:text-gray-600"
                id="menu-0-button" aria-expanded="false" aria-haspopup="true">
                <span class="sr-only">Open options</span>
                <svg class="size-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true" data-slot="icon">
                  <path
                    d="M10 3a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3ZM10 8.5a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3ZM11.5 15.5a1.5 1.5 0 1 0-3 0 1.5 1.5 0 0 0 3 0Z" />
                </svg>
              </button>
            </div>

            <!--
              Dropdown menu, show/hide based on menu state.

              Entering: "transition ease-out duration-100"
                From: "transform opacity-0 scale-95"
                To: "transform opacity-100 scale-100"
              Leaving: "transition ease-in duration-75"
                From: "transform opacity-100 scale-100"
                To: "transform opacity-0 scale-95"
            -->
            <div
              class="absolute right-0 z-10 mt-2 w-56 origin-top-right rounded-md bg-white shadow-lg ring-1 ring-black/5 focus:outline-none hidden"
              role="menu" aria-orientation="vertical" aria-labelledby="menu-0-button" tabindex="-1">
              <div class="py-1" role="none">
                <!-- Active: "bg-gray-100 text-gray-900 outline-none", Not Active: "text-gray-700" -->
                <a href="#" class="flex px-4 py-2 text-sm text-gray-700" role="menuitem" tabindex="-1" id="menu-0-item-0">
                  <svg class="mr-3 size-5 text-gray-400" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true"
                    data-slot="icon">
                    <path fill-rule="evenodd"
                      d="M10.868 2.884c-.321-.772-1.415-.772-1.736 0l-1.83 4.401-4.753.381c-.833.067-1.171 1.107-.536 1.651l3.62 3.102-1.106 4.637c-.194.813.691 1.456 1.405 1.02L10 15.591l4.069 2.485c.713.436 1.598-.207 1.404-1.02l-1.106-4.637 3.62-3.102c.635-.544.297-1.584-.536-1.65l-4.752-.382-1.831-4.401Z"
                      clip-rule="evenodd" />
                  </svg>
                  <span>Add to favorites</span>
                </a>
                <a href="#" class="flex px-4 py-2 text-sm text-gray-700" role="menuitem" tabindex="-1" id="menu-0-item-1">
                  <svg class="mr-3 size-5 text-gray-400" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true"
                    data-slot="icon">
                    <path fill-rule="evenodd"
                      d="M6.28 5.22a.75.75 0 0 1 0 1.06L2.56 10l3.72 3.72a.75.75 0 0 1-1.06 1.06L.97 10.53a.75.75 0 0 1 0-1.06l4.25-4.25a.75.75 0 0 1 1.06 0Zm7.44 0a.75.75 0 0 1 1.06 0l4.25 4.25a.75.75 0 0 1 0 1.06l-4.25 4.25a.75.75 0 0 1-1.06-1.06L17.44 10l-3.72-3.72a.75.75 0 0 1 0-1.06ZM11.377 2.011a.75.75 0 0 1 .612.867l-2.5 14.5a.75.75 0 0 1-1.478-.255l2.5-14.5a.75.75 0 0 1 .866-.612Z"
                      clip-rule="evenodd" />
                  </svg>
                  <span>Embed</span>
                </a>
                <a href="#" class="flex px-4 py-2 text-sm text-gray-700" role="menuitem" tabindex="-1" id="menu-0-item-2">
                  <svg class="mr-3 size-5 text-gray-400" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true"
                    data-slot="icon">
                    <path
                      d="M3.5 2.75a.75.75 0 0 0-1.5 0v14.5a.75.75 0 0 0 1.5 0v-4.392l1.657-.348a6.449 6.449 0 0 1 4.271.572 7.948 7.948 0 0 0 5.965.524l2.078-.64A.75.75 0 0 0 18 12.25v-8.5a.75.75 0 0 0-.904-.734l-2.38.501a7.25 7.25 0 0 1-4.186-.363l-.502-.2a8.75 8.75 0 0 0-5.053-.439l-1.475.31V2.75Z" />
                  </svg>
                  <span>Report content</span>
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="px-4 pb-5 opacity-25 sm:p-6 sm:pt-0 mt-4 text-sm">
        <p>
          {@post.content}
        </p>
      </div>
    </div>
    """
  end

  def post_form(assigns) do
    ~H"""
    <div class="p-4 border rounded-lg shadow">
      <h3 class="text-lg font-bold mb-2">Create a Post</h3>

      <form phx-submit="create_post">
        <textarea name="content" class="w-full p-2 border rounded" placeholder="Write something..."></textarea>

        <input type="file" name="attachments" multiple class="block mt-2 border rounded" />

        <input
          type="number"
          name="payment_amount" step="0.01" value={@payment_amount} class="w-full mt-2 p-2 border rounded" />

        <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded mt-2">
          Post
        </button>
      </form>
    </div>
    """
  end
end
