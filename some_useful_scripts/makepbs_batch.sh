#!/bin/bash
LIST=()
FILES=()
n=0
list_dir=$(readlink -f $1)
batch_out_dir=$(readlink -f $2)
analysis_out_dir=$(readlink -f $3)

for i in $(ls -p $list_dir | grep -v /); do
    FILES[n]=$i
    n=$((n+1))
done

n=0
for i in $(ls -p $list_dir | grep -v / | awk 'match($0, /[a-zA-Z0-9]+/) { print substr($0, RSTART, RLENGTH)}'); do
    LIST[n]=$i
    n=$((n+1))
done

n=0
for i in ${LIST[*]}; do
    cat <<EOF > $batch_out_dir"/"$i"_functional_annotation.pbs"
    #PBS -N ${i}_funcAnnot
    #PBS -V
    #PBS -A tyjames_fluxod
    #PBS -l qos=flux
    #PBS -q fluxod
    #PBS -l nodes=1:ppn=12,mem=20gb,walltime=100:00:00
    #PBS -M amsesk@umich.edu
    #PBS -m abe
    #PBS -j oe

    #Your Code Goes Below:
    cd $analysis_out_dir
    mkdir logfiles
    mkdir ${i}_functional_annotation_out
    cd ${i}_functional_annotation_out

    #Load Module Dependencies
    module load hmmer/3.1b2
    module load ncbi-blast 
    module load mcl

    echo "### Starting "$i" ###" > ../logfiles/${i}_logfile
    ###dbCAN
    hmmscan --domtblout ${i}.dbcan.dm.out /home/amsesk/dbCAN/dbCAN-fam-HMMs.txt ${list_dir}/${FILES[$n]} > ${i}.dbcan.out
    sh /home/amsesk/dbCAN/hmmscan-parser.sh ${i}.dbcan.dm.out > ${i}.dbcan.dm.out.parsed
    echo "...dbCAN done..." >> ../logfiles/${i}_logfile

    ###MEROPS
    blastp -query ${list_dir}/${FILES[$n]} -out ${i}.pepunit.out -evalue 1e-5 -outfmt 6 -max_target_seqs 1 -db ~/MEROPS/pepunit -num_threads 12
    echo "...MEROPS done..." >> ../logfiles/${i}_logfile

    ###interproscan
    cp ${list_dir}/${FILES[$n]} ${FILES[$n]}.no_asterisks
    sed -i 's/\*//g' ${FILES[$n]}.no_asterisks
    /home/amsesk/interproscan-5.27-66.0/interproscan.sh -i ${FILES[$n]}.no_asterisks -b ${i}.ips.out -pa -goterms
    echo "...interproscan done..." >> ../logfiles/${i}_logfile
    rm ${FILES[$n]}.no_asterisks

    echo "### ${i} Done ###" >> ../logfiles/${i}_logfile    
EOF
n=$((n+1))
done
