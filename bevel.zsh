#!/usr/bin/env zsh

zmodload zsh/zutil

zparseopts -D -E -A opts tsdir:=opts  cb:=opts

local tsdir=$opts[-tsdir]
local cb="${opts[-cb]:-false}"

if command -v magick >/dev/null; then
    function convert()  { magick "$@"; }
fi

imagemagick_bevel ()
{
    for png_file in "$tsdir"/**/img_puzzle_*.png; do
        local file_path_base_name="${png_file:r}"
        local out_file="${file_path_base_name}_bevel.png"

        convert "$png_file" -alpha extract "${file_path_base_name}_mask.png"

        convert "${file_path_base_name}_mask.png" \( +clone -blur 0x2 -shade 120x20 -contrast-stretch 0% +sigmoidal-contrast 2x50% -fill grey70 -colorize 10%  \) +swap -alpha Off -compose CopyOpacity -composite "${file_path_base_name}_overlay.png"

        convert "${png_file}" "${file_path_base_name}_overlay.png" -compose Hardlight -composite "${file_path_base_name}_bevel.png"

        rm "${file_path_base_name}_mask.png" "${file_path_base_name}_overlay.png"
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

