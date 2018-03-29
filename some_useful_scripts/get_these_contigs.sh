#!/bin/bash

list=$1
contig_file=$2

#sed -ie 's/|/\\\\|/g' $list

while read l; do
    #echo $l
    #s="/$l/,/>/p"
    #echo $s
    #s=$(echo "$s" | sed -e 's/|/\\|/g')
    #out=$(sed -nE $s $contig_file)
    #awk -v i=$l '/$i/ {print;flag=1;next} />/ {flag=0}flag' $contig_file
    e=$(echo $l | sed 's/|/\\\\|/g')
    #echo $e
    awk -v i="$e" '$0 ~ i {print;flag=1;next} />/ {flag=0}flag' $contig_file
    #echo "$out"
done < $list

#sed -ie 's/\\\\|/|/g' $list
