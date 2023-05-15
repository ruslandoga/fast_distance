alias Exqlite.Sqlite3

generate_series_cte = """
with recursive generate_series(value) as (
  select 1
    union all
  select value+1
    from generate_series
    where value+1<=100000
)
"""

sqlite_stmt = fn fun ->
  "#{generate_series_cte} select #{fun}(?, ?, ?, ?) from generate_series"
end

params = [_kremlin = 55.754517, 37.622973, _svo = 55.978027, 37.417312]

Benchee.run(
  %{
    "SQLite" => fn %{sqlite: %{conn: conn, stmt: stmt}} ->
      :ok = Sqlite3.bind(conn, stmt, params)
      Sqlite3.fetch_all(conn, stmt)
    end
  },
  inputs: %{
    "haversine_distance x100k" =>
      (
        {:ok, sqlite_conn} = FastDistance.open()
        {:ok, sqlite_stmt} = Sqlite3.prepare(sqlite_conn, sqlite_stmt.("haversine_distance"))
        %{sqlite: %{conn: sqlite_conn, stmt: sqlite_stmt}}
      ),
    "fast_distance x100k" =>
      (
        {:ok, sqlite_conn} = FastDistance.open()
        {:ok, sqlite_stmt} = Sqlite3.prepare(sqlite_conn, sqlite_stmt.("fast_distance"))
        %{sqlite: %{conn: sqlite_conn, stmt: sqlite_stmt}}
      ),
    "euclidean_distance x100k" =>
      (
        {:ok, sqlite_conn} = FastDistance.open()
        {:ok, sqlite_stmt} = Sqlite3.prepare(sqlite_conn, sqlite_stmt.("euclidean_distance"))
        %{sqlite: %{conn: sqlite_conn, stmt: sqlite_stmt}}
      )
  }
)
