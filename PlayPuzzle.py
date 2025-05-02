#!/usr/bin/env python
# coding: utf-8
# PlayPuzzle.py

''' play puzzle '''

__version__ = '1.0.2'

import sys
if sys.version_info < (3, 12):
    sys.exit("This script requires Python 3.12 or higher. Please upgrade your Python version.")
else:
    sys.path.append("./lib/312")
import PuzzleBoard
import argparse
import os
import datetime
from PIL import Image
import matplotlib.pyplot as plt

def check_photo_size(value):
    try:
        ivalue = int(value)
        if ivalue < 100:
            raise argparse.ArgumentTypeError(f"'--pwidth --pheight' Value {ivalue} is too small (minimum 100)")
        if ivalue > 50000:
            raise argparse.ArgumentTypeError(f"'--pwidthor --pheight' value {ivalue} is too large (maximum 50000)")
        return ivalue
    except ValueError:
        raise argparse.ArgumentTypeError(f"'--pwidth --pheight' an integer is expected, but '{value}' was set")

def check_photo_dpi(value):
    try:
        ivalue = int(value)
        if ivalue < 50:
            raise argparse.ArgumentTypeError(f"'--dpi' Value {ivalue} is too small (minimum 50)")
        if ivalue > 1000:
            raise argparse.ArgumentTypeError(f"'--dpi' value {ivalue} is too large (maximum 1000)")
        return ivalue
    except ValueError:
        raise argparse.ArgumentTypeError(f"'--dpi' an integer is expected, but '{value}' was set")

def check_minparts_size(value):
    try:
        ivalue = int(value)
        if ivalue < 2:
            raise argparse.ArgumentTypeError(f"'--minparts' Value {ivalue} is too small (minimum 2)")
        if ivalue > 4950:
            raise argparse.ArgumentTypeError(f"'--minparts' value {ivalue} is too large (maximum 4950)")
        return ivalue
    except ValueError:
        raise argparse.ArgumentTypeError(f"'--minparts' an integer is expected, but '{value}' was set")

def check_maxparts_size(value):
    try:
        ivalue = int(value)
        if ivalue < 2:
            raise argparse.ArgumentTypeError(f"'--maxparts' Value {ivalue} is too small (minimum 2)")
        if ivalue > 5000:
            raise argparse.ArgumentTypeError(f"'--maxparts' value {ivalue} is too large (maximum 5000)")
        return ivalue
    except ValueError:
        raise argparse.ArgumentTypeError(f"'--maxparts' an integer is expected, but '{value}' was set")
    
def check_pz_percent(value):
    try:
        ivalue = int(value)
        if ivalue < 0:
            raise argparse.ArgumentTypeError(f"'--pz' Value {ivalue} is too small (minimum 0)")
        if ivalue > 100:
            raise argparse.ArgumentTypeError(f"'--pz' value {ivalue} is too large (maximum 100)")
        return ivalue
    except ValueError:
        raise argparse.ArgumentTypeError(f"'--pz' an integer is expected, but '{value}' was set")
    
parser = argparse.ArgumentParser(prog='PlayPuzzle', description='Create puzzle piece masks and/or create puzzle pieces from a photo and make a new photo from the puzzle pieces.',
                                 epilog="""Example: Split the image into 30–40 pieces and reconstruct a new image using 60% of the pieces. The 'seed' parameter controls the randomness.

  python PlayPuzzle.py --minparts 30 --maxparts 40 --seed 35 --photo photoA.jpg --pz 60

  docker run -it -v .:/app --rm puzzle --minparts 30 --maxparts 40 --seed 35 --photo photoA.jpg --pz 60
  """,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)

valid_c_values = ['k', 'b', 'r']

valid_f_values = ['png', 'svg']

valid_an_values = ['apng', 'webp']

parser.add_argument('-v', '--version', action='version', version=f"PuzzleBoard v{PuzzleBoard.__version__}")

parser.add_argument('-c', type=str, required=False, default='k', help='fill colour (Default: "k = black")', choices=valid_c_values)

parser.add_argument('-f', type=str, required=False, default='png', help='format (Default: "png")', choices=valid_f_values)

parser.add_argument('-ot', action='store_true', help='save puzzle pieces in the subdirectory according to type')

parser.add_argument('-cb', action='store_true', help='script is interrupted to allow manual design of the beveling')

parser.add_argument('-an', type=str, required=False, default=None, help='animate puzzle game with given format', choices=valid_an_values)

parser.add_argument('--pz', type=check_pz_percent, required=False, default=0, help='make a new photo with percentage of puzzle pieces. 0 = no photo, 100 = complete puzzle', metavar='<[0..100]>')

parser.add_argument('--ep', type=int, required=False, default=0, help='try to create equal puzzle pieces', metavar='<integer>')

parser.add_argument('--seed', type=int, required=False, default=92, help='initial random seed', metavar='<integer>')

parser.add_argument('--width', type=check_photo_size, required=False, default=None, help='photo width', metavar='<integer>')

parser.add_argument('--height', type=check_photo_size, required=False, default=None, help='photo height', metavar='<integer>')

parser.add_argument('--dpi', type=check_photo_dpi, required=False, default=plt.rcParams['figure.dpi'], help='photo dpi value', metavar='<integer>')

parser.add_argument('--minparts', type=check_minparts_size, required=False, default=25, help='minimum number of puzzle pieces', metavar='<integer>')

parser.add_argument('--maxparts', type=check_maxparts_size, required=False, default=50, help='maximum number of puzzle pieces', metavar='<integer>')

parser.add_argument('--photo', type=str, required=False, default=None, help='photo file', metavar=('<file-path>'))

args = parser.parse_args()

if (args.height and args.width and not args.photo) or (args.photo and not args.height and not args.width):
  pass 
else:
  parser.error('Set both --width and --height or only --photo.')

if (args.pz>0 and not (args.photo)):
  parser.error('If the --pz option is set >0, choose a photo to puzzle.')
else:
  args.f=="png"
  pass

PuzzleBoard.PuzzleConfig.NUMBER_EP=args.ep
PuzzleBoard.PuzzleConfig.MASK_COLOUR=args.c
PuzzleBoard.PuzzleConfig.LINE_LEN=10
PuzzleBoard.PuzzleConfig.PHOTO=args.photo
PuzzleBoard.PuzzleConfig.OT=args.ot
PuzzleBoard.PuzzleConfig.CB=args.cb
PuzzleBoard.PuzzleConfig.PZ=args.pz
PuzzleBoard.PuzzleConfig.AN=args.an
PuzzleBoard.PuzzleConfig.FORMAT=args.f
PuzzleBoard.PuzzleConfig.SEED=args.seed

input_image = Image.open(PuzzleBoard.PuzzleConfig.PHOTO) if not(PuzzleBoard.PuzzleConfig.PHOTO is None) else None 
PuzzleBoard.PuzzleConfig.PHOTO_WIDTH=args.width if input_image is None else input_image.width
PuzzleBoard.PuzzleConfig.PHOTO_HEIGHT=args.height if input_image is None else input_image.height
if not(input_image is None):
  input_image.close()
PuzzleBoard.PuzzleConfig.PHOTO_DPI=args.dpi
PuzzleBoard.PuzzleConfig.PUZZLE_PARTS_MIN=args.minparts 
PuzzleBoard.PuzzleConfig.PUZZLE_PARTS_MAX=args.maxparts+1

timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
subdirectory = "tmp_" + timestamp
current_directory = os.path.dirname(os.path.abspath(__file__ or '.'))
target_directory = os.path.join(current_directory, subdirectory)

game=PuzzleBoard.PuzzleBoard(PuzzleBoard.PuzzleConfig.SEED)
game.create()
game.plotMasks(target_directory)
if PuzzleBoard.PuzzleConfig.FORMAT=="png" and not(PuzzleBoard.PuzzleConfig.PHOTO is None):
  game.plotPuzzles(args.photo,target_directory)
  if PuzzleBoard.PuzzleConfig.PZ>0:
    print("Play puzzle")
    game.makePuzzle(target_directory)