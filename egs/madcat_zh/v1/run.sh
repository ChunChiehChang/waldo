#!/bin/bash

set -e # exit on error
. ./path.sh

stage=0

. ./scripts/parse_options.sh # e.g. this parses the --stage option if supplied.

. ./cmd.sh ## You'll want to change cmd.sh to something that will work on your system.
           ## This relates to the queue.

nj=70
download_dir1=/export/corpora/LDC/LDC2014T13/data
writing_condition1=/export/corpora/LDC/LDC2014T13/docs/writing_conditions.tab
local/check_dependencies.sh


if [ $stage -le 0 ]; then
  # data preparation
  local/prepare_data.sh --download_dir1 $download_dir1 --writing_condition1 $writing_condition1
fi

epochs=10
depth=5
dir=exp/unet_${depth}_${epochs}_sgd
if [ $stage -le 1 ]; then
  # training
  local/run_unet.sh --epochs $epochs --depth $depth \
    --train-image-size 256 --batch-size 8
fi

if [ $stage -le 2 ]; then
    echo "doing segmentation...."
  local/segment.py \
    --train-image-size 256 \
    --model model_best.pth.tar \
    --test-data data/dev \
    --dir $dir/segment
fi
