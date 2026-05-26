#!/bin/bash
#SBATCH --job-name=mosdepth
#SBATCH --export=ALL
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --partition=medium
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=jackgrayner@gmail.com

sample_name=$1
~/mosdepth --fast-mode --d4 ${sample_name} ${sample_name}.bam
bgzip --index ${sample_name}.per-base.d4
