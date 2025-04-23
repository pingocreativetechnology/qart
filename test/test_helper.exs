ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Qart.Repo, :manual)

Code.require_file("support/feature_case.ex", __DIR__)

# For Wallaby
{:ok, _} = Application.ensure_all_started(:wallaby)

Application.put_env(:wallaby, :base_url, QartWeb.Endpoint.url())
Application.put_env(:wallaby, :base_url, QartWeb.Endpoint.url())
