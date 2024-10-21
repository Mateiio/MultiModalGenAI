# Copyright 2019 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================
#https://github.com/tensorflow/build/tree/master/tensorflow_runtime_dockerfiles
#https://github.com/tensorflow/build/blob/master/tensorflow_runtime_dockerfiles/gpu.Dockerfile
#
# FROM nvidia/cuda:12.3.0-base-ubuntu22.04 as base
# FROM nvidia/cuda:12.1.0-base-ubuntu20.04 as base
FROM nvidia/cuda:12.6.2-base-ubuntu20.04 as base

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8

COPY setup.sources.sh /setup.sources.sh
COPY setup.packages.sh /setup.packages.sh
COPY gpu.packages.txt /gpu.packages.txt

# RUN /setup.sources.sh
# Set up shared custom sources
RUN apt-get update
RUN apt-get install -y gnupg ca-certificates wget
# Install Nvidia repo keys
# See: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#network-repo-installation-for-ubuntu
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
RUN dpkg -i cuda-keyring_1.1-1_all.deb

RUN /setup.packages.sh /gpu.packages.txt

ARG PYTHON_VERSION=python3.11
ARG TENSORFLOW_PACKAGE=tf-nightly
COPY setup.python.sh /setup.python.sh
COPY gpu.requirements.txt /gpu.requirements.txt
RUN /setup.python.sh $PYTHON_VERSION /gpu.requirements.txt
RUN pip install --no-cache-dir ${TENSORFLOW_PACKAGE} 

COPY setup.cuda.sh /setup.cuda.sh
RUN /setup.cuda.sh

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc

FROM base as jupyter

COPY jupyter.requirements.txt /jupyter.requirements.txt
COPY setup.jupyter.sh /setup.jupyter.sh
RUN python3 -m pip install --no-cache-dir -r /jupyter.requirements.txt -U
RUN /setup.jupyter.sh
#COPY jupyter.readme.md /tf/tensorflow-tutorials/README.md

WORKDIR /
EXPOSE 8888

## From https://github.com/tensorflow/build/blob/master/tensorflow_runtime_dockerfiles/gpu.Dockerfile
#CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter notebook --notebook-dir=/tf --ip 0.0.0.0 --no-browser --allow-root"]
#
#FROM base as test
#
#ENV LD_LIBRARY_PATH /usr/local/cuda/lib64/stubs/:$LD_LIBRARY_PATH
#COPY test.import_cpu.sh /test.import_cpu.sh
#RUN /test.import_cpu.sh
