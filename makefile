all: libclib.so

freeipa.o: freeipa.c
	apt-get update && apt-get install -y libcurl4-openssl-dev

libclib.so: freeipa.o
	gcc -shared freeipa.o -o libclib.so

clean:
	rm -f freeipa.o libclib.so