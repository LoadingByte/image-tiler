#!/bin/bash

usage() {
    >&2 echo "Image tiling script by LoadingByte"
    >&2 echo "Usage: $0 -w <width> -h <height> -f <jpg|png|pdf|...> [-r <resize>] [-s <0-1>] <files...>"
    >&2 echo ""
    >&2 echo "Required:"
    >&2 echo "  -w <width>     Output image width in pixels."
    >&2 echo "  -h <height>    Output image height in pixels."
    >&2 echo "  -f <format>    Output image format passed to ImageMagick (jpg, png, pdf, ...)."
    >&2 echo ""
    >&2 echo "Optional:"
    >&2 echo "  -r <resize>    The input image will be resized to <width>, x<height>, or <width>x<height> (in pixels)."
    >&2 echo "  -s <shift>     Every second column will be shifted by this ratio (0.5 means a shifting the image halfway)."
    exit 1
}

# Verify that bc and ImageMagick are installed
if ! [ -x "$(command -v bc)" ]; then
    >&2 echo 'Error: bc is not installed.'
    exit 2
fi
if ! [ -x "$(command -v convert)" ]; then
    >&2 echo 'Error: ImageMagick is not installed.'
    exit 3
fi

# Reset in case getopts has been used previously in this shell
OPTIND=1

# Parse options: -w -h -r -s
while getopts ":f:w:h:r:s:" opt; do
    case "${opt}" in
        w)
            width=${OPTARG}
            (( width >= 1 )) || usage
            ;;
        h)
            height=${OPTARG}
            (( height >= 1 )) || usage
            ;;
        f)
            format=${OPTARG}
            ;;
        r)
            resize=${OPTARG}
            ;;
        s)
            odd_col_vertical_shift=${OPTARG}
            (( $(echo "${odd_col_vertical_shift} >= 0" | bc -l) && $(echo "${odd_col_vertical_shift} <= 1" | bc -l) )) || usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

# Verify that the required arguments format, width, and height have been supplied
if [ -z "${format}" ] || [ -z "${width}" ] || [ -z "${height}" ]; then
    usage
fi

# For each operand, process that image
for input_file in "$@"
do
    # If resize has been used, generate the part of the ImageMagick command which will to the resizing
    if [ -n "${resize}" ]; then
        cmd_part_resize="-resize ${resize}"
        # In case the user wants to change both width and height, we have to tell imagemagick to force that change in aspect ratio
        if [[ $resize =~ [0-9]+x[0-9]+ ]]; then
            cmd_part_resize+=!
        fi
    fi

    # If odd column vertical shift has been used, convert the relative shift to an absolute number of pixels
    if [ -n "${odd_col_vertical_shift}" ]; then
        absolute_shift=`convert $input_file $cmd_part_resize -format "%[fx:round(h*${odd_col_vertical_shift})]" info:`
    fi

    # Actually tile the image
    convert ${input_file} ${cmd_part_resize} \( -clone 0 -roll +0+${absolute_shift} \) +append -write mpr:sometile +delete -size ${width}x${height} tile:mpr:sometile -quality 100% ${input_file%.*}-tiled.${format}
done
