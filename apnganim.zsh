#!/usr/bin/env zsh

docker build -t puzzle .

zmodload zsh/zutil

zparseopts -D -E -A opts tsdir:=opts

local tsdir=$opts[-tsdir]

local pngframes=("${(@f)$(printf '%s\n' $tsdir/frame_puzzle_*.png(.oL))}")
local webpframes=()
local os_type="$(uname -s)"

if [[ "$os_type" == "Darwin" ]]; then
    for png_frame_file in $pngframes; do
        # set delay
        # 200ms delay (macOS)
        apngframes+=( "$png_frame_file" 200 )
    done
fi

if [[ "$os_type" == "Linux" ]]; then
    # set delay (see https://manpages.ubuntu.com/manpages/kinetic/man1/apngasm.1.html)
    # 1s / 5 = 200ms delay (Linux/Ubuntu)
    apngasm "$tsdir/done_puzzle.apng.png" $tsdir/frame_puzzle_0000.png 1 5
else
    apngasm -o "$tsdir/done_puzzle.apng.png" "${apngframes[@]}"
fi
