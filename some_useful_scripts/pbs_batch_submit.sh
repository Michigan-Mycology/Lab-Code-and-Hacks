#!/bin/bash
for i in $(ls -p | grep -v /); do
    #echo $i
    qsub $i
done

