#!/bin/bash
if [ "$1" == "-h" ]; then
    echo "USAGE: newpbs.sh title queue ppn mem walltime(hours)"
    exit
fi
if [ "$2" == "tyjames_fluxod" ]; then
    Q="fluxod"
elif [ "$2" == "lsa_fluxm" ]; then
    Q="fluxm"
elif [ "$2" == "lsa_flux" ]; then
    Q="flux"
fi

cat <<EOF > $1.pbs
#PBS -N $1
#PBS -V
#PBS -A $2
#PBS -l qos=flux
#PBS -q $Q
#PBS -l nodes=1:ppn=${3},mem=${4}gb,walltime=${5}:00:00
#PBS -M amsesk@umich.edu
#PBS -m abe
#PBS -j oe

#Your Code Goes Below:

EOF

vim $1.pbs
