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
