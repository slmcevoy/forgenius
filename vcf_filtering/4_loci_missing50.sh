#!/bin/bash
#SBATCH --job-name=loci
#SBATCH --output=loci_%j.o
#SBATCH --error=loci_%j.e
#SBATCH --account=project_2009301
#SBATCH --partition=small
#SBATCH --time=1:00:00
#SBATCH --ntasks=1
#SBATCH --mem=50M
#SBATCH --mail-type=END
#SBATCH --cpus-per-task=1

module load biokit
module load bcftools
DIR=/users/mcevoysu/scratch/output/vcf_filtering

SPECIES=(Aalba Anebrodensis Bpendula Fexcelsior Phalepensis Pinusnigra Tbaccata)
SUBSETS=("random" "target")
SAMPLE_SIZE=(wc -l /users/mcevoysu/scratch/data)
for S in ${SPECIES[@]}; do
  for SUBSET in ${SUBSETS[@]}; do
	INPUT="SNP_sampleFilt_${SUBSET}.vcf.gz"
	SAMPLE_SIZE="$(wc -l /users/mcevoysu/scratch/data/${S}/samples.txt | cut -f1 -d ' ' -)"
	bcftools +fill-tags $DIR/${S}/$INPUT -- -t "F_MISSING,AN" | bcftools query -Hf "%CHROM\t%POS\t%AN\t%F_MISSING\n" -o $DIR/${S}/missing_data_${SUBSET}.tsv -
	awk -v samplesize="${SAMPLE_SIZE}" 'BEGIN {OFS="\t"}; (NR>1 && $3>=samplesize) {print $0}' $DIR/${S}/missing_data_${SUBSET}.tsv > $DIR/${S}/missingness_keep_${SUBSET}.tsv
	awk -v samplesize="${SAMPLE_SIZE}" 'BEGIN {OFS="\t"}; (NR>1 && $3<samplesize) {print $0}' $DIR/${S}/missing_data_${SUBSET}.tsv > $DIR/${S}/missingness_remove_${SUBSET}.tsv
	cut -d $'\t' -f1,2 $DIR/${S}/missingness_keep_${SUBSET}.tsv | bcftools view -R - $DIR/${S}/$INPUT -O z -o $DIR/${S}/${S}_SNP_sampleFilt_${SUBSET}_locimissingness.vcf.gz
	bcftools stats $DIR/${S}/${S}_SNP_sampleFilt_${SUBSET}_locimissingness.vcf.gz
  done
done

