defmodule FastDistance do
  @moduledoc "Fast distance approximation example"
  alias Exqlite.Sqlite3

  def open do
    with {:ok, conn} = result <- Sqlite3.open(":memory:") do
      :ok = Sqlite3.enable_load_extension(conn, true)
      :ok = Sqlite3.execute(conn, "select load_extension('priv/fast_distance')")
      :ok = Sqlite3.enable_load_extension(conn, false)
      result
    end
  end
end
