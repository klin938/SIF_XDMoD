#!/bin/bash

# input arg $1 should be full path to file
# /path/to/Grandline62_accounting.tar.gz

# This script assumes the first part of file
# name is XDMoD resource name.

# Grandline62_accounting.tar.gz
file="$(echo $1 | awk -F"/" '{print $(NF)}')"

# Grandline62, Wolfpack60, Brenner70 etc
xdmod_res="$(echo $1 | awk -F"/" '{print $(NF)}' | awk -F"_" '{print $1}')"

wk_dir="/tmp/$xdmod_res"

mkdir "$wk_dir"

tar -xvf $1 -C "$wk_dir"


for FILE in "$wk_dir"/*; do 
  xdmod-shredder -r $xdmod_res -f sge -i $FILE
  sleep 10
done

rm -rf "$wk_dir"

xdmod-ingestor
sleep 60
