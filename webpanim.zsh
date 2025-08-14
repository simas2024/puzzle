#!/usr/bin/env zsh

zparseopts -D -E -A opts tsdir:=opts

local tsdir=$opts[-tsdir]

local pngframes=("${(@f)$(printf '%s\n' $tsdir/frame_puzzle_*.png(.oL))}")
local webpframes=()
local durNxt=200

for png_frame_file in $pngframes; do
    webp_frame_file="${png_frame_file:r}.webp"
    cwebp -q 80 "$png_frame_file" -o "$webp_frame_file" 2>> /dev/null
    webpframes+=( -frame "$webp_frame_file" +$durNxt+0+0+0+b )
done

webpmux "${webpframes[@]}" -o "$tsdir/done_puzzle.webp"