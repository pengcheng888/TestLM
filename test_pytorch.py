import torch
 
# 检查CUDA是否可用
if torch.cuda.is_available():
    x = torch.randn(5, 3).cuda()  # 将张量移至GPU
    print(x)
    y = x + 2  # 在GPU上执行操作
    print(y)
else:
    print("CUDA is not available. Running on CPU.")