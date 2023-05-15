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
postgis_params = [_kremlin = 37.622973, 55.754517, _svo = 37.417312, 55.978027]

postgis_stmt = fn fun ->
  "#{generate_series_cte} select #{fun} from generate_series"
end

Benchee.run(
  %{
    "SQLite" => fn %{sqlite: %{conn: conn, stmt: stmt}} ->
      :ok = Sqlite3.bind(conn, stmt, params)
      Sqlite3.fetch_all(conn, stmt)
    end,
    "PostGIS" => fn %{postgis: %{conn: conn, query: query}} ->
      Postgrex.execute!(conn, query, postgis_params)
    end
  },
  inputs: %{
    "haversine_distance x100k" =>
      (
        {:ok, sqlite_conn} = FastDistance.open()
        {:ok, sqlite_stmt} = Sqlite3.prepare(sqlite_conn, sqlite_stmt.("haversine_distance"))

        {:ok, postgrex_conn} = Postgrex.start_link(database: "t_dev")

        {:ok, postgrex_query} =
          Postgrex.prepare(
            postgrex_conn,
            "name",
            postgis_stmt.("""
            ST_Distance(
              ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography,
              ST_SetSRID(ST_MakePoint($3, $4), 4326)::geography
            )
            """)
          )

        %{
          sqlite: %{conn: sqlite_conn, stmt: sqlite_stmt},
          postgis: %{conn: postgrex_conn, query: postgrex_query}
        }
      ),
    "fast_distance x100k" =>
      (
        {:ok, sqlite_conn} = FastDistance.open()
        {:ok, sqlite_stmt} = Sqlite3.prepare(sqlite_conn, sqlite_stmt.("fast_distance"))

        {:ok, postgrex_conn} = Postgrex.start_link(database: "t_dev")

        {:ok, postgrex_query} =
          Postgrex.prepare(
            postgrex_conn,
            "name",
            postgis_stmt.("""
            ST_Distance(
              ST_Transform(ST_SetSRID(ST_MakePoint($1, $2), 4326), 3857),
              ST_Transform(ST_SetSRID(ST_MakePoint($3, $4), 4326), 3857)
            ) * cosd(42.3521)
            """)
          )

        %{
          sqlite: %{conn: sqlite_conn, stmt: sqlite_stmt},
          postgis: %{conn: postgrex_conn, query: postgrex_query}
        }
      ),
    "euclidean_distance x100k" =>
      (
        {:ok, sqlite_conn} = FastDistance.open()
        {:ok, sqlite_stmt} = Sqlite3.prepare(sqlite_conn, sqlite_stmt.("euclidean_distance"))

        {:ok, postgrex_conn} = Postgrex.start_link(database: "t_dev")

        {:ok, postgrex_query} =
          Postgrex.prepare(
            postgrex_conn,
            "name",
            postgis_stmt.(
              "ST_Distance(ST_SetSRID(ST_MakePoint($1, $2), 4326), ST_SetSRID(ST_MakePoint($3, $4), 4326))"
            )
          )

        %{
          sqlite: %{conn: sqlite_conn, stmt: sqlite_stmt},
          postgis: %{conn: postgrex_conn, query: postgrex_query}
        }
      )
  }
)
