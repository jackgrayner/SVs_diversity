#!/bin/bash
#SBATCH --job-name=aln_sort_rmdup_depth
#SBATCH --export=ALL
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=16G
#SBATCH --partition=long
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=jackgrayner@gmail.com
#SBATCH --array=0-20
#SBATCH --output=aln_depth_%A_%a.out

while read line
do
	
	sample_id=$(echo "$line" | awk '{print $1}') #this is the SRR accession
	sample_name=$(echo "$line" | awk '{print $2}') #this is the sample ID in the existing VCF
	
	#clean if cleaned file not already created
	if [ ! -f ${sample_name}_R2_cleaned.fastq.gz ]; then
		
		source activate sratools
		fastq-dump --split-files ${sample_id}
		gzip ${sample_id}_1.fastq
		gzip ${sample_id}_2.fastq
		
		source activate fastp
		fastp -i ${sample_id}_1.fastq.gz -I ${sample_id}_2.fastq.gz \
		 -o ${sample_name}_R1_cleaned.fastq.gz -O ${sample_name}_R2_cleaned.fastq.gz
		
		#if fastp worked, remove uncleaned file
		if [[ -s "${sample_name}_R2_cleaned.fastq.gz" ]]; then
			rm ${sample_id}_*.fastq.gz
		fi
	
	fi
	
	genome_index="TOC.asm.scaffold.fasta"  
	input_fastq1="${sample_name}_R1_cleaned.fastq.gz"
	input_fastq2="${sample_name}_R2_cleaned.fastq.gz"
	output_bam="${sample_name}_sorted.bam"
	
	#add read group info
	library_name="${sample_name}"
	platform="ILLUMINA"
	unit="unit1"
	rg_string="@RG\tID:${sample_name}\tSM:${sample_name}\tLB:${library_name}\tPL:${platform}\tPU:${unit}"
	
	#align reads and sort
	#just use bwa-mem rather than bwa-mem2? better to submit more jobs at a time with less memory?
	source activate bwa-mem2
	bwa mem -t 16 -R "$rg_string" "$genome_index" "$input_fastq1" "$input_fastq2" | samtools sort -o "$output_bam"
	samtools index "$output_bam"
	
	#mark duplicated and re-index
	source activate sambamba
	sambamba markdup -r "$output_bam" "${sample_name}.rmdup.bam"
	
	#if sambamba worked, remove unmarked bam file
	if [[ -s "${sample_name}.rmdup.bam" ]]; then
		rm ${sample_name}.bam
	fi
	
	mv "${sample_name}.rmdup.bam" "${sample_name}.bam"
	samtools index "${sample_name}.bam"
	
done < "snp_SraRunSplit_0${SLURM_ARRAY_TASK_ID}"
