#!/usr/bin/env zsh

zmodload zsh/zutil

zparseopts -D -E -A opts tsdir:=opts

local tsdir=$opts[-tsdir]

local pngframes=("${(@f)$(printf '%s\n' $tsdir/frame_puzzle_*.png(.oL))}")

for png_frame_file in $pngframes; do
    # set delay
    # 200ms delay (macOS)
    apngframes+=( "$png_frame_file" 200 )
done

apngasm -o "$tsdir/done_puzzle.apng.png" "${apngframes[@]}"
