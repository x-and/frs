#/bin/bash

docker pull nvcr.io/nvidia/tensorrt:21.05-py3

repo_dir=$(pwd)/../opt/model_repository

# scrfd
[ ! -f "$repo_dir/scrfd/1/model.plan" ] \
	&& docker run --gpus all --rm -v $(pwd)/../opt/:/opt/frs --entrypoint=bash nvcr.io/nvidia/tensorrt:21.05-py3 -c \
		"cd /opt/frs/plan_source/scrfd && trtexec --onnx=scrfd_10g_bnkps.onnx --saveEngine=model.plan --shapes=input.1:1x3x320x320 --workspace=1024" \
	&& mkdir -p $(pwd)/../opt/model_repository/scrfd/1/ \
	&& mv $(pwd)/../opt/plan_source/scrfd/model.plan $(pwd)/../opt/model_repository/scrfd/1/model.plan

# genet
[ ! -f "$repo_dir/genet/1/model.plan" ] \
	&& docker run --gpus all --rm -v $(pwd)/../opt/:/opt/frs --entrypoint=bash nvcr.io/nvidia/tensorrt:21.05-py3 -c \
		"cd /opt/frs/plan_source/genet && trtexec --onnx=genet_small_custom_ft.onnx --saveEngine=model.plan --optShapes=input.1:1x3x192x192 --minShapes=input.1:1x3x192x192 --maxShapes=input.1:1x3x192x192 --workspace=3000" \
	&& mkdir -p $(pwd)/../opt/model_repository/genet/1/ \
	&& mv $(pwd)/../opt/plan_source/genet/model.plan $(pwd)/../opt/model_repository/genet/1/model.plan

# arcface
[ ! -f "$repo_dir/arcface/1/model.plan" ] \
	wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm= \
		$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1gnt6P3jaiwfevV4hreWHPu0Mive5VRyP' \
		-O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1gnt6P3jaiwfevV4hreWHPu0Mive5VRyP" -O $(pwd)/../opt/plan_source/arcface/glint360k_r50.onnx && rm -rf /tmp/cookies.txt \
	&& docker run --gpus all --rm -v $(pwd)/../opt/:/opt/frs --entrypoint=bash nvcr.io/nvidia/tensorrt:21.05-py3 -c \
		"cd /opt/frs/plan_source/arcface && trtexec --onnx=glint360k_r50.onnx --saveEngine=model.plan --optShapes=input.1:1x3x112x112 --minShapes=input.1:1x3x112x112 --maxShapes=input.1:1x3x112x112 --workspace=1500" \
	&& mkdir -p $(pwd)/../opt/model_repository/arcface/1/ \
	&& mv $(pwd)/../opt/plan_source/arcface/model.plan $(pwd)/../opt/model_repository/arcface/1/model.plan
