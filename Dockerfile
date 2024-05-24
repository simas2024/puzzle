FROM python:3.12-slim-bullseye

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    apt-get update && apt-get install -y \
    zsh \
    imagemagick \
    apngasm \
    webp

RUN mkdir /app

WORKDIR /app

COPY . /app

RUN --mount=type=cache,target=/root/.cache pip install -r requirements.txt

ENTRYPOINT ["python", "PlayPuzzle.py"]