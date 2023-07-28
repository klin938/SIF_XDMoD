#!/bin/sh

#########################################################
# This script removes the prefix for the files from
# logrotate the SGE accounting  file. Basically it does:
#
# accounting-20150607 ---> 20150607
#
# The new file name is desired by XDMoD shredder
#
# Derrick Lin 11/06/2015
# d.lin@garvan.org.au
#########################################################

for name in accounting-*
do
    newname="$(echo "$name" | cut -c12-)"
    mv "$name" "$newname"
done
