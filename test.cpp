#include <iostream>
#include <fstream>
#include <cstring>
#include <stdlib.h>
//declare GPU function
extern void grep(char* buffer, int* len, char* key, int* keylen);

using namespace std;

int main(int argc, char* argv[]) {
        //initial parameters
        ifstream myfile;
        string line;
        int count = 0;

        int i = 0;
        const int BUFFER_SIZE = 1000;
        const int BUFFER_LINE = 1000;
        char* buffer = (char*)malloc(BUFFER_SIZE * BUFFER_LINE * sizeof(char));
        int* len = (int*)calloc(BUFFER_LINE, sizeof(int));
        //read keyword
        char* key = argv[1];
        int keylen = strlen(key);
        //read data from file
        myfile.open("../data/enwiki-latest-abstract.xml");
        while (!myfile.eof()) {
                //read line from file
                getline(myfile, line);
                //record line length
                if (count == 0){
                        len[count] = line.length();
                }
                else {
                        len[count] = len[count-1] + line.length();
                }
                //add line into buffer
                if (count == 0){
                        memcpy(&buffer[0], line.c_str(), len[0]*sizeof(char));
                }
                else {
                        memcpy(&buffer[len[count-1]], line.c_str(), (len[count]-len[count-1])*sizeof(char));
                }

                //use GPU grep when buffer is full with 1000 lines (0 - 999 line)
                if (count == BUFFER_LINE - 1) {
                        grep(buffer, len, key, &keylen);

                        //flush buffer & len
                        free(buffer);
                        buffer = (char*)malloc(BUFFER_SIZE * BUFFER_LINE * sizeof(char));
                        free(len);
                        len = (int*)malloc(BUFFER_LINE * sizeof(int));
                        //prepare for another buffer
                        i++;
                        count = -1;
                }
                count++;
        }
        myfile.close();

        return 0;
}

