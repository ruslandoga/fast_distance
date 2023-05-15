[Distance approximation](https://jonisalonen.com/2014/computing-distance-between-coordinates-can-be-simple-and-fast/) extension demo in SQLite.

Most similar to

```sql
-- Geometry example - units in meters (SRID: 3857 as above, but corrected by cos(lat) to account for distortion)
SELECT ST_Distance(
  ST_Transform('SRID=4326;POINT(-72.1235 42.3521)'::geometry, 3857),
  ST_Transform('SRID=4326;LINESTRING(-72.1260 42.45, -72.123 42.1546)'::geometry, 3857)
) * cosd(42.3521);
```

example from [postgis docs.](https://postgis.net/docs/manual-2.5/ST_Distance.html)

---

```console
$ MIX_ENV=bench mix run bench/distance.exs

Operating System: macOS
CPU Information: Apple M1
Number of Available Cores: 8
Available memory: 8 GB
Elixir 1.14.4
Erlang 25.3

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 0 ns
reduction time: 0 ns
parallel: 1
inputs: euclidean_distance x100k, fast_distance x100k, haversine_distance x100k
Estimated total run time: 42 s

Benchmarking PostGIS with input euclidean_distance x100k ...
Benchmarking PostGIS with input fast_distance x100k ...
Benchmarking PostGIS with input haversine_distance x100k ...
Benchmarking SQLite with input euclidean_distance x100k ...
Benchmarking SQLite with input fast_distance x100k ...
Benchmarking SQLite with input haversine_distance x100k ...

##### With input euclidean_distance x100k #####
Name              ips        average  deviation         median         99th %
PostGIS         20.75       48.19 ms     ±4.35%       47.60 ms       63.38 ms
SQLite          16.20       61.72 ms     ±6.80%       61.89 ms       69.05 ms

Comparison:
PostGIS         20.75
SQLite          16.20 - 1.28x slower +13.53 ms

##### With input fast_distance x100k #####
Name              ips        average  deviation         median         99th %
PostGIS         21.02       47.57 ms     ±1.87%       47.41 ms       50.86 ms
SQLite          15.83       63.18 ms     ±7.77%       64.44 ms       72.16 ms

Comparison:
PostGIS         21.02
SQLite          15.83 - 1.33x slower +15.61 ms

##### With input haversine_distance x100k #####
Name              ips        average  deviation         median         99th %
PostGIS         21.40       46.73 ms     ±1.50%       46.61 ms       51.14 ms
SQLite          14.85       67.32 ms     ±7.63%       67.23 ms       77.32 ms

Comparison:
PostGIS         21.40
SQLite          14.85 - 1.44x slower +20.59 ms
```
