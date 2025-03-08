CC = gcc
CFLAGS = -fPIC -D_GNU_SOURCE
CURL_CFLAGS = $(shell pkg-config --cflags libcurl)
CURL_LIBS = $(shell pkg-config --libs libcurl)

all: libclib.so

freeipa.o: freeipa.c
	$(CC) $(CFLAGS) $(CURL_CFLAGS) -c freeipa.c -o freeipa.o

libclib.so: freeipa.o
	$(CC) -shared freeipa.o -o libclib.so $(CURL_LIBS)

clean:
	rm -f freeipa.o libclib.so

.PHONY: all clean