defmodule QartWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.Feature
      import Wallaby.Query
      import Phoenix.VerifiedRoutes
      import Qart.Factory
      @endpoint QartWeb.Endpoint
    end
  end

  setup tags do
    # :ok = Ecto.Adapters.SQL.Sandbox.checkout(Qart.Repo)
    # Ecto.Adapters.SQL.Sandbox.mode(Qart.Repo, {:shared, self()})

    # # {:ok, session} = Wallaby.start_session()
    # {:ok, session} = Wallaby.start_session(metadata: %{owner_pid: self()})


    # Qart.Sandbox.allow(Qart.Repo, self(), self())
    # # Ecto.Adapters.SQL.Sandbox.allow(Qart.Repo, self(), self())

    # {:ok, session: session}

    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Qart.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(Qart.Repo, pid)
    {:ok, session} = Wallaby.start_session(metadata: metadata)

    [session: session]
  end

  def pause_here(session, ms \\ 5_000) do
    IO.puts("⏸  pause_here/2 hit — sleeping for #{ms}ms")
    :timer.sleep(ms)
    session
  end

end
