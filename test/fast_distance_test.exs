defmodule FastDistanceTest do
  alias Exqlite.Sqlite3
  use ExUnit.Case

  describe "fast_distance" do
    setup do
      {:ok, conn} = FastDistance.open()
      {:ok, conn: conn}
    end

    test "in msk", %{conn: conn} do
      # distance in degrees
      assert {:ok, [[0.3037320645256252]]} =
               query(conn, "select euclidean_distance(?, ?, ?, ?)", [
                 _kremlin = 55.754517,
                 37.622973,
                 _svo = 55.978027,
                 37.417312
               ])

      # distance in km
      assert {:ok, [[27.970367116014373]]} =
               query(conn, "select haversine_distance(?, ?, ?, ?)", [
                 _kremlin = 55.754517,
                 37.622973,
                 _svo = 55.978027,
                 37.417312
               ])

      # approx distance in km
      assert {:ok, [[27.715920610330436]]} =
               query(conn, "select fast_distance(?, ?, ?, ?)", [
                 _kremlin = 55.754517,
                 37.622973,
                 _svo = 55.978027,
                 37.417312
               ])
    end
  end

  describe "postgis" do
    setup do
      {:ok, conn} = Postgrex.start_link(database: "t_dev", pool_size: 1)
      Postgrex.query!(conn, "create extension if not exists postgis", [])
      {:ok, conn: conn}
    end

    test "in msk", %{conn: conn} do
      # https://postgis.net/docs/manual-2.5/ST_Distance.html
      # distance in degrees
      assert Postgrex.query!(
               conn,
               "SELECT ST_Distance(ST_SetSRID(ST_MakePoint($1, $2), 4326), ST_SetSRID(ST_MakePoint($3, $4), 4326))",
               [
                 _kremlin = 37.622973,
                 55.754517,
                 _svo = 37.417312,
                 55.978027
               ]
             ).rows == [[0.3037320645256252]]

      # distance in meters, 28km, correct (according to yandex)
      # https://yandex.com/maps/213/moscow/?ll=37.383746%2C55.973687&rl=37.623372%2C55.754660~-0.206523%2C0.223560&z=12.4
      assert Postgrex.query!(
               conn,
               """
               SELECT ST_Distance(
                 ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography,
                 ST_SetSRID(ST_MakePoint($3, $4), 4326)::geography
               )
               """,
               [
                 _kremlin = 37.622973,
                 55.754517,
                 _svo = 37.417312,
                 55.978027
               ]
             ).rows == [[28019.22616132]]
    end
  end

  def query(conn, sql, params \\ []) do
    with {:ok, stmt} <- Sqlite3.prepare(conn, sql) do
      try do
        :ok = Sqlite3.bind(conn, stmt, params)
        Sqlite3.fetch_all(conn, stmt)
      after
        :ok = Sqlite3.release(conn, stmt)
      end
    end
  end
end
