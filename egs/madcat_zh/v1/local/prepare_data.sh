#!/bin/bash

# Copyright 2018 Johns Hopkins University (author: Ashish Arora)
# Apache 2.0
# This script loads the training and test data splits and prepares the training and test data for MADCAT Arabic dataset
#  Eg. local/prepare_data.sh


stage=0
download_dir1=/export/corpora/LDC/LDC2014T13/data
writing_condition1=/export/corpora/LDC/LDC2014T13/docs/writing_conditions.tab
train_split_url=http://www.openslr.org/resources/50/madcat.train.raw.lineid
test_split_url=http://www.openslr.org/resources/50/madcat.test.raw.lineid
dev_split_url=http://www.openslr.org/resources/50/madcat.dev.raw.lineid
data_splits_dir=data/download/data_splits

mkdir -p data/{train,test,dev}
mkdir -p data/{train,test,dev}/{img,mask,object_class,orig_dim,orig_img}

[ -f ./path.sh ] && . ./path.sh; # source the path.

. ./scripts/parse_options.sh # e.g. this parses the --stage option if supplied.

if [ -d $data_splits_dir ]; then
  echo "$0: Not downloading the data splits as it is already there."
else
  if [ ! -f $data_splits_dir/madcat.train.raw.lineid ]; then
    mkdir -p $data_splits_dir
    echo "$0: Downloading the data splits..."
    wget -P $data_splits_dir $train_split_url || exit 1;
    wget -P $data_splits_dir $test_split_url || exit 1;
    wget -P $data_splits_dir $dev_split_url || exit 1;
  fi
  echo "$0: Done downloading the data splits"
fi



echo "Date: $(date)."
if [ $stage -le 0 ]; then
  for dataset in test dev train; do
  dataset_file=$data_splits_dir/madcat.$dataset.raw.lineid
  local/process_data.py $download_dir1 $dataset_file data/$dataset $writing_condition1
  done
fi
echo "Date: $(date)."

