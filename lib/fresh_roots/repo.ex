defmodule FreshRoots.Repo do
  use Ecto.Repo,
    otp_app: :fresh_roots,
    adapter: Ecto.Adapters.SQLite3
end
