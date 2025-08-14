FROM python:3.12-slim-bullseye

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    apt-get update && apt-get install -y \
    zsh \
    imagemagick \
    webp \
    wget \
    unzip \
    cmake libpng-dev libboost-program-options-dev libboost-regex-dev libboost-system-dev libboost-filesystem-dev build-essential \
    fonts-dejavu-core

# Build apngasm library and CLI manually
RUN rm -rf /tmp/apngasm \
 && wget https://github.com/apngasm/apngasm/archive/refs/tags/3.1.10.tar.gz -O /tmp/apngasm.tar.gz \
 && mkdir -p /tmp/apngasm \
 && tar -xzf /tmp/apngasm.tar.gz -C /tmp/apngasm --strip-components=1 \
 && mkdir -p /tmp/apngasm/build \
 && cd /tmp/apngasm/build \
 && cmake ../ \
 && make \
 && make install \
 && ldconfig \
 && cd / && rm -rf /tmp/apngasm /tmp/apngasm.tar.gz

RUN mkdir /app
WORKDIR /app

COPY . /app

RUN --mount=type=cache,target=/root/.cache pip install -r requirements.txt

RUN python3 -c "import matplotlib.pyplot as plt"

ENTRYPOINT ["python", "PlayPuzzle.py"]
