#!/bin/bash

FolderPath=/home/nvidia/LMcode
gguf_model_Folder=/mnt/DataDisk/gguf_model

export MAX_STEPS=1000
export TEMPERATURE=1.0
export AS_USER=1
##
#export TEST_MODEL="$gguf_model_Folder"/TinyLlama-1.1B-Chat-v1.0-F16.gguf
#export TEST_MODEL="$gguf_model_Folder"/DeepSeek-R1-Distill-Qwen-1.5B-v0.0-F16.gguf
#export TEST_MODEL="$gguf_model_Folder"/DeepSeek-R1-Distill-Llama-8B-v0.0-F16.gguf
export TEST_MODEL="$gguf_model_Folder"/fm9g-8.8B-sft-v0.0-FP16.gguf
##
#export TEST_MODEL="$gguf_model_Folder"/fm9g-2B-sft-v0.0-F16.gguf
#export TEST_MODEL="$gguf_model_Folder"/fm9g-7B-sft-v0.0-F16.gguf

#export PROMPT="Once upon a time,"
export PROMPT="接下来讲一个不少于1000字的故事，"


function install_env() {
echo "=========================================================================================="
echo "==========================        install_operators     =================================="
echo "=========================================================================================="

# xmake
curl -fsSL https://xmake.io/shget.text | bash
sleep 1
# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# INFINI =======> 
export INFINI_ROOT=/home/nvidia/.infini
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/nvidia/.infini/lib
sleep 1
sudo apt-get update
sleep 1
sudo apt-get install clang

# jtop
sudo -H pip install jetson-stats
sudo jtop

#安装llvm
sudo apt update
sudo apt install llvm clang
}


#!
#! 安装 operators
#!
function install_operators() {
echo "=========================================================================================="
echo "==========================        install_operators     =================================="
echo "=========================================================================================="

sleep 1
cd "$FolderPath" || { echo "无法进入目录: $FolderPath"; exit 1; }
pwd

git clone https://github.com/InfiniTensor/operators.git
cd operators
xmake f -v
xmake f --cpu=true -cv
xmake f --nv-gpu=true --cuda=$CUDA_HOME -cv
xmake build && xmake install
}

#!
#! 安装 infer
#!
function install_infer(){
echo "=========================================================================================="
echo "==========================         install_infer        =================================="
echo "=========================================================================================="
sleep 1
cd "$FolderPath" || { echo "无法进入目录: $FolderPath"; exit 1; }
pwd

git clone https://github.com/InfiniTensor/infer.cc.git
cd infer.cc
xmake f --nv-gpu=true -cv
xmake f --ccl=true --infer=true -cv
xmake && xmake install
}

#!
#! 安装 gguf
#!
function install_gguf(){

echo "=========================================================================================="
echo "==========================         install_gguf         =================================="
echo "=========================================================================================="
sleep 1
cd "$FolderPath" || { echo "无法进入目录: $FolderPath"; exit 1; }
pwd

git clone https://github.com/InfiniTensor/gguf.git
cd gguf
# cargo convert /home/ubuntu/workspace_aisys/gguf_model/TinyLlama-1.1B-Chat-v1.0-F16.gguf -x cast:linear:f16,norm:f32->merge-linear->sort --log trace
}


#!
#! 安装 InfiniLM
#!
function install_InfiniLM(){
echo "=========================================================================================="
echo "==========================       install_InfiniLM       =================================="
echo "=========================================================================================="

sleep 1
cd "$FolderPath" || { echo "无法进入目录: $FolderPath"; exit 1; }
pwd

git clone https://github.com/InfiniTensor/InfiniLM -b dev
cd InfiniLM
}
##########################################################################
##########################################################################
##########################################################################
##########################################################################

#!
#! 在cpu上运行
#!
function run_cpu() {
echo "=========================================================================================="
echo "==========================          run_cpu             =================================="
echo "=========================================================================================="
sleep 1
cd "$FolderPath" || { echo "无法进入目录: $FolderPath"; exit 1; }
cd InfiniLM/
pwd

export DEVICES=1
cargo test --release --package llama-cpu --lib -- infer::test_infer --exact --nocapture
}

#!
#! 在gpu上运行
#!
function run_nvidia() {
echo "=========================================================================================="
echo "==========================       run_nvidia             =================================="
echo "=========================================================================================="
sleep 1
cd "$FolderPath" || { echo "无法进入目录: $FolderPath"; exit 1; }

cd InfiniLM/
pwd
export DEVICES=0
#export RUST_BACKTRACE=1 # debug
#export RUSTFLAGS="-C target-feature=+fullfp16" # error: instruction requires: fullfp16
export RUSTFLAGS="-C target-feature=+fp16"

# cargo test --package operators --lib -- add::cuda::test --show-output 
# cargo test --package operators --lib -- rms_norm::cuda::test --show-output
# cargo test --release
cargo test --release --package llama-cuda --lib -- infer::test_infer --exact --nocapture
}



##########################################################################
##########################################################################
##########################################################################
##########################################################################
function install_test(){
echo "=========================================================================================="
echo "==========================       install_test           =================================="
echo "=========================================================================================="

#install_operators
#install_infer
#install_gguf
install_InfiniLM
pwd
}

function run_test(){
echo "=========================================================================================="
echo "==========================         run_test             =================================="
echo "=========================================================================================="
#run_cpu

run_nvidia
pwd
}
##########################################################################
##########################################################################
##########################################################################
##########################################################################
#install_test
run_test

# zuihoude zongjie 

