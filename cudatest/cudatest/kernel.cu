
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdlib.h>
#include <stdio.h>
#include <io.h>
#include <string.h>

typedef struct daily_data
{
	float open;
	float high;
	float low;
	float close;
	float volume;
	float adj_close;
	char date[12];
}data_t; // every line has 69 chars (68 + 1 * '\n')

__global__ void parseKernel(char * data, data_t * trading_data)
{
	int i = threadIdx.x; 
	char temp[69]; 
	memcpy(temp, data + i * 69, 69); 
	temp[10] = 0;
	temp[20] = 0;
	temp[30] = 0;
	temp[40] = 0;
	temp[50] = 0;
	temp[58] = 0;
	temp[68] = 0;
	memcpy(trading_data[i].data, temp, 11); 
	trading_data[i].open = strtof(temp+11);
	trading_data[i].high = strtof(temp + 21);
	trading_data[i].low = strtof(temp + 31);
	trading_data[i].close = strtof(temp + 41);
	trading_data[i].volume = atoi(temp + 51);
	trading_data[i].adj_close = strtof(temp + 58);
}

__global__ void computation(data_t * trading_data)
{

}

__global__ void addKernel(int *c, const int *a, const int *b)
{
    int i = threadIdx.x;
	memcpy(c + i, a + i, 4);
    //c[i] = a[i] + b[i];
}



__shared__ char data[16384];

int main()
{
	FILE * f = fopen("table.csv", "r");
	int d; 
	size_t f_size; 
	f_size = fread(data, 1, 16384,  f);
	printf("length of string is %ld", strlen(data));
	unsigned int days = (int)strlen(data) / 69;
	data_t * trading_data = (data_t *) malloc(days * sizeof(data_t));

	for (int i = 0; i < 10300; i++)
	{
		//putc(data[i], stdout);
		if (data[i] == ',')
		{
			printf("%i is a comma\n", i); 
		}
		if (data[i] == '\n') break; 
	}

	scanf("%d", &d); 
	return 0;
	/*
	const int arraySize = 5;
    const int a[arraySize] = { 1, 2, 3, 4, 5 };
    const int b[arraySize] = { 10, 20, 30, 40, 50 };
    int c[arraySize] = { 0 };

    // Add vectors in parallel.
    cudaError_t cudaStatus = addWithCuda(c, a, b, arraySize);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "addWithCuda failed!");
        return 1;
    }

    printf("{1,2,3,4,5} + {10,20,30,40,50} = {%d,%d,%d,%d,%d}\n",
        c[0], c[1], c[2], c[3], c[4]);
	//int varvar; 
	//scanf("%d", &varvar);
    // cudaDeviceReset must be called before exiting in order for profiling and
    // tracing tools such as Nsight and Visual Profiler to show complete traces.
    cudaStatus = cudaDeviceReset();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaDeviceReset failed!");
        return 1;
    }

    return 0;*/
}

// Helper function for using CUDA to add vectors in parallel.

cudaError_t parse_cuda(char * data, data_t * trading_data, unsigned int days)
{
	char *dev_data = NULL;
	data_t * dev_trading_data = NULL; 

	cudaMalloc((void**) &dev_data, strlen(data));
	cudaMalloc((void**) & dev_trading_data, days * sizeof(trading_data)); 
	cudaError_t cuaStatus; 
	cudaMemcpy(dev_data, data, strlen(data), cudaMemcpyHostToDevice);  
	parseKernel <<<1, days >>>(dev_data, dev_trading_data);
	cudaDeviceSynchronize(); 
	cudaMemcpy(trading_data, dev_trading_data, sizeof(data_t)*days , cudaMemcpyDeviceToHost); 
	cudaFree(dev_data);
	cudaFree(dev_trading_data);
	return cudaSuccess;
}

/*
cudaError_t addWithCuda(int *c, const int *a, const int *b, unsigned int size)
{
    int *dev_a = 0;
    int *dev_b = 0;
    int *dev_c = 0;
    cudaError_t cudaStatus;

    // Choose which GPU to run on, change this on a multi-GPU system.
    cudaStatus = cudaSetDevice(0);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
        goto Error;
    }

    // Allocate GPU buffers for three vectors (two input, one output)    .
    cudaStatus = cudaMalloc((void**)&dev_c, size * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&dev_a, size * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&dev_b, size * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    // Copy input vectors from host memory to GPU buffers.
    cudaStatus = cudaMemcpy(dev_a, a, size * sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

    cudaStatus = cudaMemcpy(dev_b, b, size * sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

    // Launch a kernel on the GPU with one thread for each element.
    addKernel<<<1, size>>>(dev_c, dev_a, dev_b);

    // Check for any errors launching the kernel
    cudaStatus = cudaGetLastError();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "addKernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
        goto Error;
    }
    
    // cudaDeviceSynchronize waits for the kernel to finish, and returns
    // any errors encountered during the launch.
    cudaStatus = cudaDeviceSynchronize();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching addKernel!\n", cudaStatus);
        goto Error;
    }

    // Copy output vector from GPU buffer to host memory.
    cudaStatus = cudaMemcpy(c, dev_c, size * sizeof(int), cudaMemcpyDeviceToHost);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

Error:
    cudaFree(dev_c);
    cudaFree(dev_a);
    cudaFree(dev_b);
    
    return cudaStatus;
}
*/