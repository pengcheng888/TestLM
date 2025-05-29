#!/bin/bash

FolderPath= /home/ubuntu/workspace_aisys/LLM/
export TEST_MODEL=/home/ubuntu/workspace_aisys/gguf_model/TinyLlama-1.1B-Chat-v1.0-F16.gguf

#!
#! 安装 operators
#!
function install_operators() {
cd  "$FolderPath"
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
cd  "$FolderPath"
git clone https://github.com/InfiniTensor/infer.cc.git
cd infer.cc
xmake f --nv-gpu=true -cv
xmake f --ccl=false --infer=false -cv
xmake && xmake install
}

#!
#! 安装 gguf
#!
function install_gguf(){
cd  "$FolderPath"
git clone https://github.com/InfiniTensor/gguf.git
cd gguf
# cargo convert /home/ubuntu/workspace_aisys/gguf_model/TinyLlama-1.1B-Chat-v1.0-F16.gguf -x cast:linear:f16,norm:f32->merge-linear->sort --log trace
}


#!
#! 安装 InfiniLM
#!
function install_InfiniLM(){
cd  "$FolderPath"
git clone https://github.com/InfiniTensor/InfiniLM
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
cd "$FolderPath"
cd InfiniLM/
export DEVICES=1
cargo test --release --package llama-cpu --lib -- infer::test_infer --exact --nocapture
}

#!
#! 在gpu上运行
#!
function run_nvidia() {
cd "$FolderPath"
cd InfiniLM/
export DEVICES=0
cargo test --release --package llama-cuda --lib -- infer::test_infer --exact --nocapture
}



##########################################################################
##########################################################################
##########################################################################
##########################################################################
function install_test(){
#install_operators
#install_infer
#install_gguf
#install_InfiniLM
pwd
}

function run_test(){
#run_cpu
run_nvidia
pwd
}



