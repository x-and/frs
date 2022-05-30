# Requirements
 - debian-based system (tested on ubuntu 20.04)
 - installed docker and docker-compose 1.28.0+ (with support for NVIDIA GPUs)

## Install nvidia drivers and nvidia-container-toolkit
 - follow instructions https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html#ubuntu-lts and https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker
 - or run `cd docker && sudo setup_nvidia.sh` from project root

## Build frs application
 - run `cd docker && bash build.sh` from project root

## Create tensort models
 - download https://drive.google.com/file/d/1gnt6P3jaiwfevV4hreWHPu0Mive5VRyP/view?usp=sharing into `project_root/opt/frs/plan_source/arcface/glint360k_r50.onnx`
 - run `cd docker && bash create_models.sh` from project_root

## Run application
 - change variable in `docker-compose.yml`
 - run `cd docker && docker-compose up` from project root