FROM ubuntu:20.04 as builder

# common
RUN apt-get update && apt-get --yes upgrade
RUN DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    apt-get -y install tzdata keyboard-configuration wget linux-headers-5.11.0-46-generic gnupg2 git lsb-release software-properties-common unzip ninja-build cmake build-essential libssl-dev rapidjson-dev libz-dev

ENV CC=/usr/bin/clang-14
ENV CXX=/usr/bin/clang++-14
ENV CXXFLAGS=-stdlib=libc++

# download all
RUN cd ~ && wget https://apt.llvm.org/llvm.sh
RUN cd ~ && wget https://boostorg.jfrog.io/artifactory/main/release/1.79.0/source/boost_1_79_0.zip && unzip boost_1_79_0.zip
RUN cd ~ && wget https://github.com/opencv/opencv/archive/4.5.5.zip && unzip 4.5.5.zip
RUN cd ~ && wget https://github.com/Kitware/CMake/releases/download/v3.23.1/cmake-3.23.1.tar.gz && tar -zxvf cmake-3.23.1.tar.gz
RUN cd ~ && git clone https://github.com/triton-inference-server/client.git triton-client

# clang 14 + libc++
RUN cd ~ && chmod +x llvm.sh && ./llvm.sh && ldconfig
RUN apt-get install -y libc++-14-dev libc++abi-14-dev libunwind-14-dev

# Boost
RUN cd ~/boost_1_79_0/tools/build \
  && ./bootstrap.sh \
  && ./b2 install --prefix=/usr/local
RUN cd ~/boost_1_79_0 \
    && b2 --build-dir=./build --with-filesystem --with-program_options --with-system --with-thread --with-date_time toolset=clang-14 variant=release link=static runtime-link=static cxxflags="-std=c++20 -stdlib=libc++" linkflags="-stdlib=libc++" release install

# OpenCV
RUN cd ~/opencv-4.5.5 \
  && mkdir build \
  && cd build \
  && cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER=/usr/bin/clang++-14 \
    -DCMAKE_C_COMPILER=/usr/bin/clang-14 \
    -DCMAKE_CXX_FLAGS="-stdlib=libc++" \
    -DCMAKE_CXX_STANDARD=20 \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_LIST="core,imgcodecs,calib3d,imgproc" \
    -DOPENCV_ENABLE_NONFREE=ON \
    -DBUILD_PERF_TESTS=OFF \
    -DBUILD_TESTS=OFF \
    -DBUILD_ZLIB=ON \
    -DBUILD_OPENEXR=OFF \
    -DBUILD_JPEG=ON \
    -DBUILD_OPENJPEG=ON \
    -DBUILD_PNG=ON \
    -DBUILD_WEBP=ON \
    -DBUILD_PACKAGE=OFF \
    -DCMAKE_CONFIGURATION_TYPES="Release" \
    -DBUILD_JAVA=OFF \
    -DBUILD_opencv_python3=OFF \
    -DBUILD_opencv_python_bindings_generator=OFF \
    -DBUILD_opencv_python_tests=OFF \
    -DWITH_FFMPEG=OFF \
    -DWITH_GSTREAMER=OFF \
    -DWITH_GTK=OFF \
    -DWITH_OPENGL=OFF \
    -DWITH_1394=OFF \
    -DWITH_ADE=OFF \
    -DWITH_OPENEXR=OFF \
    -DWITH_PROTOBUF=OFF \
    -DWITH_QUIRC=OFF \
    -DWITH_TIFF=OFF \
    -DWITH_V4L=OFF \
    -DWITH_VA=OFF \
    -DWITH_VA_INTEL=OFF \
    -DWITH_VTK=OFF \
    -DWITH_OPENCL=OFF \
  .. \
  && make -j`nproc`

# new CMake for Triton client
RUN cd ~/cmake-3.23.1 \
  && cmake . \
  && make -j`nproc` \
  && make install \
  && ldconfig

# Triton client
RUN cd ~/triton-client \
    && git checkout r22.04 \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_CXX_STANDARD=20 -DCMAKE_INSTALL_PREFIX=`pwd`/install -DCMAKE_BUILD_TYPE=Release -DTRITON_ENABLE_CC_HTTP=ON -DTRITON_ENABLE_CC_GRPC=OFF -DTRITON_ENABLE_PERF_ANALYZER=OFF -DTRITON_ENABLE_PYTHON_HTTP=OFF -DTRITON_ENABLE_PYTHON_GRPC=OFF -DTRITON_ENABLE_GPU=OFF -DTRITON_ENABLE_EXAMPLES=OFF -DTRITON_ENABLE_TESTS=OFF -DTRITON_COMMON_REPO_TAG=r22.04 -DTRITON_THIRD_PARTY_REPO_TAG=r22.04 ..

RUN cd ~/triton-client/build && make cc-clients -j`nproc`

# cp sources only
COPY ./*.cpp /root/frs/
COPY ./*.h /root/frs/
COPY ./CMakeLists.txt /root/frs/
COPY ./contrib/ /root/frs/contrib/

# make frs
RUN cd ~/frs \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release -DOpenCV_DIR:PATH=$HOME/opencv-4.5.5/build -DTRITON_CLIENT_DIR:PATH=$HOME/triton-client/build/install -DCURL_ZLIB=OFF -DBoost_USE_STATIC_RUNTIME=ON .. \
    && make -j`nproc`

# install some runtime shit
RUN apt-get update && apt-get install -y mysql-client dnsutils gettext-base

COPY ./docker/entrypoint.sh /root/entrypoint.sh
COPY ./opt/*.config /root/frs
COPY ./opt/*.template /root/frs

ENTRYPOINT ["bash", "/root/entrypoint.sh"]