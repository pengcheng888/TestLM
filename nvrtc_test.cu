#include <nvrtc.h>
#include <iostream>
#include <cstdlib>

int main() {
    nvrtcProgram prog;
    const char *src = "extern \"C\" __global__ void kernel() {}";
    
    // 创建 NVRTC 程序
    nvrtcResult result = nvrtcCreateProgram(&prog, src, "test.cu", 0, NULL, NULL);
    
    if (result != NVRTC_SUCCESS) {
        std::cerr << "nvrtcCreateProgram failed: " << nvrtcGetErrorString(result) << std::endl;
        return EXIT_FAILURE;
    }
    
    // 编译程序
    const char *opts[] = {"--gpu-architecture=compute_80"};
    result = nvrtcCompileProgram(prog, 1, opts);
    
    if (result != NVRTC_SUCCESS) {
        size_t logSize;
        nvrtcGetProgramLogSize(prog, &logSize);
        char *log = new char[logSize];
        nvrtcGetProgramLog(prog, log);
        std::cerr << "Compilation failed:\n" << log << std::endl;
        delete[] log;
        return EXIT_FAILURE;
    }
    
    // 清理资源
    nvrtcDestroyProgram(&prog);
    std::cout << "NVRTC test succeeded!" << std::endl;
    return EXIT_SUCCESS;
}
