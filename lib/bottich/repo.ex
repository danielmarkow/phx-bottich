defmodule Bottich.Repo do
  use Ecto.Repo,
    otp_app: :bottich,
    adapter: Ecto.Adapters.Postgres
end
