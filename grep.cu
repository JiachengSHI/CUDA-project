#include <stdio.h>
#include <stdlib.h>

void grep(char* buffer, int* len, char* key, int* keylen);

__global__ void search(char* d_in, int* d_out, char* d_key, int* d_len, int* d_keylen){
        //index of the thread is the index of the line it will process
        int i = threadIdx.x;
        //initial result to 0 
        d_out[i] = 0;
        if (i == 0){
                //search each charact in line
                for (int k=0; k < d_len[0] - *d_keylen; k++){
                        if (d_in[k] == d_key[0]) {
                                //compare all charact with keywords
                                for (int j=1; j< *d_keylen; j++) {
                                        if (d_in[k+j] != d_key[j]) {
                                            break;
					}
					//all charact match
                                        if (j == *d_keylen - 1){
                                            //set result to 1 means find match word
                                            d_out[i] = 1;
                                            break;
					}
                                }
                        }
                        //find 1 match is ok to break out
                        if (d_out[i] == 1) {
                                break;
                        }
                }
        }
        else {
                //search each charact in line
                for (int k=d_len[i-1]; k < d_len[i] - *d_keylen; k++) {
                        if (d_in[k] == d_key[0]) {
                                //compare all charact with keywords
                                for (int j=1; j < *d_keylen; j++) {
                                        if (d_in[k+j] != d_key[j]){
                                                break;
					}
					// all charact match
                                        if (j == *d_keylen - 1) {
                                                //set result to 1 means find match word
                                                d_out[i] = 1;
                                                break;
					}
                                }
                        }
                        //find 1 match is ok to break out
                        if (d_out[i] == 1) {
                                break;
                        }
                }
        }
}
unsigned long BUFFER_SIZE = 1000000;
unsigned long BUFFER_BYTES = BUFFER_SIZE * sizeof(char);

void grep(char* buffer, int* len, char* key, int* keylen) {
        // generate the output array on the host
        int h_out[1000];

        // declare GPU memory pointers
        char* d_in;
        int* d_out;
        char* d_key;
        int* d_len;
        int* d_keylen;

        // allocate GPU memory
        cudaMalloc((void**) &d_in, BUFFER_BYTES);
        cudaMalloc((void**) &d_out, 1000 * sizeof(int));
        cudaMalloc((void**) &d_key, *keylen * sizeof(int));
        cudaMalloc((void**) &d_len, 1000 * sizeof(int));
        cudaMalloc((void**) &d_keylen, sizeof(int));

        // transfer the array to the GPU
        cudaMemcpy(d_in, buffer, BUFFER_BYTES, cudaMemcpyHostToDevice);
        cudaMemcpy(d_key, key, *keylen * sizeof(char), cudaMemcpyHostToDevice);
        cudaMemcpy(d_len, len, 1000 * sizeof(int) , cudaMemcpyHostToDevice);
        cudaMemcpy(d_keylen, keylen, sizeof(int), cudaMemcpyHostToDevice);

        // launch the kernel
        search<<<1, 1000>>>(d_in, d_out, d_key, d_len, d_keylen);

        // copy back the result array to the CPU
        cudaMemcpy(h_out, d_out, 1000*sizeof(int), cudaMemcpyDeviceToHost);

        // print out the resulting array
        for (int q=0; q < 1000; q++) {
                if (h_out[q] == 1){
                        if (q == 0) {
                                for (int j=0; j < len[0]; j++){
                                        printf("%c", buffer[j]);
                                }
                        }
                        else {
                                for (int j=len[q-1]; j < len[q]; j++){
                                        printf("%c", buffer[j]);
                                }	
                        }
			printf("\n");
                }
        }
        //free GPU memory
        cudaFree(d_in);
        cudaFree(d_out);
        cudaFree(d_key);
        cudaFree(d_len);
        cudaFree(d_keylen);
}
