CC = gcc
CFLAGS = -shared -fPIC -Wall -Wextra -O2
LDFLAGS = -lsqlite3 -lm
SRC = c_src/fast_distance.c
OUT_PREFIX = priv/fast_distance
EXT = so

# Detect the host operating system
ifeq ($(shell uname -s), Darwin)
  EXT = dylib
endif

build: $(SRC)
	$(CC) $(CFLAGS) -o $(OUT_PREFIX).$(EXT) $(SRC) $(LDFLAGS)

.PHONY: clean

clean:
	rm -f $(OUT_PREFIX)-*.$(EXT)
