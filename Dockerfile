FROM python:3.12-slim-bullseye

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    apt-get update && apt-get install -y \
    zsh \
    imagemagick \
    webp \
    wget \
    unzip \
    git \
    cmake libpng-dev libboost-program-options-dev libboost-regex-dev libboost-system-dev libboost-filesystem-dev build-essential \
    fonts-dejavu-core

# Build apngasm library and CLI manually
RUN rm -rf /tmp/apngasm/ \
 && git clone https://github.com/apngasm/apngasm.git --branch 3.1.10 --single-branch /tmp/apngasm \
 && mkdir -p /tmp/apngasm/build \
 && cd /tmp/apngasm/build \
 && cmake ../ \
 && make -j$(nproc) \
 && cp lib/libapngasm.so /usr/local/lib/ \
 && echo "/usr/local/lib" > /etc/ld.so.conf.d/apngasm.conf \
 && ldconfig \
 && cp cli/apngasm /usr/local/bin/ \
 && cd / && rm -rf /tmp/apngasm

RUN mkdir /app
WORKDIR /app

COPY . /app

RUN --mount=type=cache,target=/root/.cache pip install -r requirements.txt

RUN python3 -c "import matplotlib.pyplot as plt"

ENTRYPOINT ["python", "PlayPuzzle.py"]
