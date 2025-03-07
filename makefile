all: libclib.so

freeipa.o: freeipa.c
	gcc -c -fPIC freeipa.c -o freeipa.o

libclib.so: freeipa.o
	gcc -shared freeipa.o -o libclib.so

clean:
	rm -f freeipa.o libclib.so