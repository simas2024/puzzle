#!/bin/zsh

zmodload zsh/zutil

zparseopts -D -E -A opts tsdir:=opts  cb:=opts

local tsdir=$opts[-tsdir]
local cb="${opts[-cb]:-false}"

imagemagick_bevel () 
{
    for png_file in $tsdir/**/img_puzzle_*.png; do
        bevel_tmp_png_file="${png_file:r}_tmp_bevel.png"
        bevel_png_file="${png_file:r}_bevel.png"

        convert "$png_file" \
            \( +clone -alpha Extract -blur 0x3 -shade 170x40 -alpha On -normalize +level 5% \
            +clone +swap -compose overlay -composite \) \
            -compose In -composite "$bevel_tmp_png_file"

        convert "$bevel_tmp_png_file" \( +clone -background black -shadow 5x20+2+2 \) +swap \
            -background none -layers merge +repage -gravity Center -extent $(identify -format "%wx%h" "$png_file") "$bevel_png_file"
        
        rm "$bevel_tmp_png_file"
    done
}

custom_bevel () 
{
    echo ">>> Add custom bevel effects on img_puzzle_*.png in ./tmp_$tsdir now and then press <ENTER>."
    read -k REPLY

    for png_file in $tsdir/**/img_puzzle_*.png; do
        bevel_png_file="${png_file:r}_bevel.png"

        cp "$png_file" "$bevel_png_file"
    done
}

if [[ $cb == "true" ]]; then
    custom_bevel
else
    imagemagick_bevel
fi

