#/bin/bash
current_distribution=$(. /etc/os-release;echo $ID$VERSION_ID)

distribution=${1:-$current_distribution}
distribution_no_dot=$(echo $distribution | sed -e 's/\.//g')

# nvidia drivers
cd ~ && wget https://developer.download.nvidia.com/compute/cuda/repos/$distribution_no_dot/x86_64/cuda-$distribution_no_dot.pin \
    && sudo mv cuda-$distribution_no_dot.pin /etc/apt/preferences.d/cuda-repository-pin-600 \
    && sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/$distribution_no_dot/x86_64/3bf863cc.pub \
    && sudo echo "deb http://developer.download.nvidia.com/compute/cuda/repos/$distribution_no_dot/x86_64 /" | tee /etc/apt/sources.list.d/cuda.list \
    && sudo apt-get update && sudo apt-get install -y cuda-drivers-470 --no-install-recommends \
    || (echo 'nvidia drivers install fail' && exit 1)

# nvidia-container-toolkit
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
	&& curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list \
	&& sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit \
	&& sudo systemctl restart docker \
	|| (echo 'dvidia-container-toolkit install fail' && exit 1)

# final check
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi || (echo 'docker gpu test fail' && exit 1)

echo 'setup nvidia ok'