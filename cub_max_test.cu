#include <cub/cub.cuh>
#include <iostream>
#include <cstdlib>

__global__ void find_max_kernel(const float* input, float* output, int size) {
    // 使用共享内存进行块内归约
    typedef cub::BlockReduce<float, 256> BlockReduce;
    __shared__ typename BlockReduce::TempStorage temp_storage;
    
    float thread_data = -__FLT_MAX__;
    
    // 每个线程处理一个或多个元素
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid < size) {
        thread_data = input[tid];
    }
    
    // 使用 cub::Max() 进行块内归约
    float block_max = BlockReduce(temp_storage).Reduce(thread_data, cub::Max());
    
    // 第一个线程存储结果
    if (threadIdx.x == 0) {
        output[blockIdx.x] = block_max;
    }
}

int main() {
    const int N = 1024;
    const int block_size = 256;
    const int grid_size = (N + block_size - 1) / block_size;
    
    // 创建主机数据
    float* h_data = new float[N];
    for (int i = 0; i < N; i++) {
        h_data[i] = static_cast<float>(rand()) / RAND_MAX; // 0.0 - 1.0
    }
    
    // 创建设备内存
    float *d_input, *d_output;
    cudaMalloc(&d_input, N * sizeof(float));
    cudaMalloc(&d_output, grid_size * sizeof(float));
    
    // 复制数据到设备
    cudaMemcpy(d_input, h_data, N * sizeof(float), cudaMemcpyHostToDevice);
    
    // 启动内核
    find_max_kernel<<<grid_size, block_size>>>(d_input, d_output, N);
    
    // 复制结果回主机
    float* h_output = new float[grid_size];
    cudaMemcpy(h_output, d_output, grid_size * sizeof(float), cudaMemcpyDeviceToHost);
    
    // 在主机上计算最终最大值
    float final_max = -__FLT_MAX__;
    for (int i = 0; i < grid_size; i++) {
        if (h_output[i] > final_max) {
            final_max = h_output[i];
        }
    }
    
    // 在主机上验证
    float host_max = -__FLT_MAX__;
    for (int i = 0; i < N; i++) {
        if (h_data[i] > host_max) {
            host_max = h_data[i];
        }
    }
    
    // 输出结果
    std::cout << "Host computed max: " << host_max << std::endl;
    std::cout << "CUB computed max: " << final_max << std::endl;
    
    // 验证结果
    if (std::abs(host_max - final_max) < 1e-5) {
        std::cout << "\033[32mTest PASSED\033[0m" << std::endl;
    } else {
        std::cout << "\033[31mTest FAILED\033[0m" << std::endl;
    }
    
    // 清理资源
    delete[] h_data;
    delete[] h_output;
    cudaFree(d_input);
    cudaFree(d_output);
    
    return 0;
} // nvcc cub_max_test.cu -o cub_max_test -I/usr/local/cuda/include -L/usr/local/cuda/lib64 -lcudart
