# Image Tiler

A very simple ImageMagick-based bash script that takes an image and tiles it.
This script depends on ImageMagick, so make sure that's installed.

## Usage

`./image-tiler.sh -w <width> -h <height> -f <jpg|png|pdf|...> [-r <resize>] [-s <0-1>] <files...>`

Each file will be tiled on its own, with each file's output being written to `<filename>-tiled.<format>`.
Note that this script cannot combine different files into a single tiled image.

Required:
* `-w <width>` — Output image width in pixels.
* `-h <height>` — Output image height in pixels.
* `-f <format>` — Output image format passed to ImageMagick (`jpg`, `png`, `pdf`, ...).

Optional:
* `-r <resize>` — The input image will be resized to `<width>`, `x<height>`, or `<width>x<height>` (in pixels).
* `-s <shift>` — Every second column will be shifted by this ratio (`0.5` means a shifting the image halfway).
