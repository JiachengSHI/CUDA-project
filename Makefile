grep: grep.o test.o
	nvcc -o grep grep.o test.o

grep.o: grep.cu
	nvcc -c grep.cu

test.o: test.cpp
	g++ -c test.cpp
