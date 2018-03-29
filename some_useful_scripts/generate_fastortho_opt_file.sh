#!/bin/bash
FILES=()
n=0
list_dir=$(readlink -f $1)
output=$(readlink -f $2)
analysis_out_dir=$(readlink -f $3)
job_name=$4

for i in $(ls $list_dir); do
    FILES[n]=$i
    n=$((n+1))
done

for i in ${FILES[*]}; do
    cat <<EOF >> $output
    --single_genome_fasta ${list_dir}/${i}
EOF
done

cat <<EOF >> $output
    --working_directory $analysis_out_dir
    --project_name $job_name
    --formatdb_path makeblastdb
    --blastall_path blastp
    --blast_cpus 12
    --blast_b 1000
    --blast_v 1000
    --blast_e 1e-5
    --pv_cutoff 1e-5
    --pi_cutoff 0.000000
    --pmatch_cutoff 0.000000
    --maximum_weight 316.000000
    --mcl_path mcl
    --inflation 1.5
    --result_file ${analysis_out_dir}/${job_name}.end
EOF
