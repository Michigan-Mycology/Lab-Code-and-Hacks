#!/bin/bash
if [[ $1 == '-help' || $1 == '-h' ]]; then
    echo "Usage: sh better_maker_labels.sh maker_map_ids_out prefix"
    exit
fi
maker_map_ids_out=$1
prefix=$2
while IFS='' read -r line || [[ -n "$line" ]]; do
    line=$line
    col1=$(echo $line | cut -d ' ' -f1)
    org=$(echo $col1 | cut -d '-' -f2)
    #echo $org
    #iter="g"$(echo $line | cut -d ' ' -f2 | cut -d '_' -f2 | sed 's/-RA$//')
    iter="g"$(echo $line | cut -d ' ' -f2 | cut -d '_' -f2)
    echo -e $col1"\t"$prefix"_"$org"_"$iter

done < $maker_map_ids_out
