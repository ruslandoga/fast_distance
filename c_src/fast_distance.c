#include <math.h>
#include <stddef.h>

#include "../deps/exqlite/c_src/sqlite3ext.h"
SQLITE_EXTENSION_INIT1

#define DEG_TO_RAD (M_PI / 180.0)
#define EARTH_RADIUS_KM_PER_DEG 110.25
#define EARTH_RADIUS_KM 6371.0

static void fast_distance(sqlite3_context *ctx, int argc,
                          sqlite3_value **argv) {
  (void)argc;

  double lat1 = sqlite3_value_double(argv[0]);
  double lng1 = sqlite3_value_double(argv[1]);
  double lat0 = sqlite3_value_double(argv[2]);
  double lng0 = sqlite3_value_double(argv[3]);

  double dlat = lat1 - lat0;
  double dlng = (lng1 - lng0) * cos(lat0 * DEG_TO_RAD);

  sqlite3_result_double(
      ctx, EARTH_RADIUS_KM_PER_DEG * sqrt(dlat * dlat + dlng * dlng));
}

static void haversine_distance(sqlite3_context *ctx, int argc,
                               sqlite3_value **argv) {
  (void)argc;

  double lat1 = sqlite3_value_double(argv[0]) * DEG_TO_RAD;
  double lng1 = sqlite3_value_double(argv[1]) * DEG_TO_RAD;
  double lat2 = sqlite3_value_double(argv[2]) * DEG_TO_RAD;
  double lng2 = sqlite3_value_double(argv[3]) * DEG_TO_RAD;

  double dlat = lat2 - lat1;
  double dlng = lng2 - lng1;

  double a = sin(dlat / 2) * sin(dlat / 2) +
             cos(lat1) * cos(lat2) * sin(dlng / 2) * sin(dlng / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  sqlite3_result_double(ctx, EARTH_RADIUS_KM * c);
}

static void euclidean_distance(sqlite3_context *ctx, int argc,
                               sqlite3_value **argv) {
  (void)argc;

  double x1 = sqlite3_value_double(argv[0]);
  double y1 = sqlite3_value_double(argv[1]);
  double x2 = sqlite3_value_double(argv[2]);
  double y2 = sqlite3_value_double(argv[3]);

  double dx = x2 - x1;
  double dy = y2 - y1;

  sqlite3_result_double(ctx, sqrt(dx * dx + dy * dy));
}

int sqlite3_fastdistance_init(sqlite3 *db, char **pzErrMsg,
                              const sqlite3_api_routines *pApi) {
  SQLITE_EXTENSION_INIT2(pApi);
  (void)pzErrMsg;
  sqlite3_create_function(db, "fast_distance", 4, SQLITE_UTF8, NULL,
                          fast_distance, NULL, NULL);
  sqlite3_create_function(db, "haversine_distance", 4, SQLITE_UTF8, NULL,
                          haversine_distance, NULL, NULL);
  sqlite3_create_function(db, "euclidean_distance", 4, SQLITE_UTF8, NULL,
                          euclidean_distance, NULL, NULL);
  return SQLITE_OK;
}
