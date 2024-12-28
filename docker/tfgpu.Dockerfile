FROM tensorflow/tensorflow:latest-gpu-jupyter

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        git libsndfile1-dev tesseract-ocr espeak-ng python3 python3-pip ffmpeg git-lfs curl && \
    rm -rf /var/lib/apt/lists/*
RUN git lfs install
RUN python3 -m pip install --no-cache-dir --upgrade pip

RUN python3 -m pip install --no-cache-dir --upgrade tensorflow[and-cuda] 

RUN python3 -m pip install --no-cache-dir jupyterlab matplotlib
RUN python3 -m pip install --no-cache-dir jupyter_http_over_ws ipykernel nbformat  jedi 
#RUN jupyter serverextension enable --py jupyter_http_over_ws
RUN python3 -m pip install --no-cache-dir ipywidgets widgetsnbextension pandas-profiling

COPY requirements.txt /tmp/
RUN python3 -m pip install --requirement /tmp/requirements.txt

WORKDIR /

EXPOSE 8888