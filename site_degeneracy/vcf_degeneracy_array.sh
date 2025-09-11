#!/bin/bash
#SBATCH --job-name=vcfdeg
#SBATCH --output=vcfdeg_%j.o
#SBATCH --error=vcfdeg_%j.e
#SBATCH --account=project_2009301
#SBATCH --partition=small
#SBATCH --time=4:00:00
#SBATCH --ntasks=1
#SBATCH --mem=280G
#SBATCH --mail-type=END
#SBATCH --cpus-per-task=1
#SBATCH --array=6-12

module load biokit

DIR=/users/mcevoysu/scratch/output
OUTDIR="$DIR"/site_annotation

# codes in fold-annotated file to use in awk below:
# {'2fold':2, '3fold':2,'intergenic':0 , 'intron':1, 'exon':2, '0fold':3, '4fold':4, '3utr':5, '5utr':6, 'istop':7, 'stop':8, 'unknown':9}

subsets() {
	VCFDIR="${DIR}"/vcf_filtering/"${1}"
    VCFNAME="${1}"_SNP_sampleFilt_locimissingness"${2}${3}"
    GVCFNAME="${1}"_SPET_allsites_filt_locimissingness"${2}${3}"
	SPECIES=$(echo "${1}" | sed 's/_multispecies//')
	SITE_ANN="${DIR}"/site_annotation/Ptabuliformis/Ptabuliformis_siteannotations.chr${SLURM_ARRAY_TASK_ID}.txt
	mkdir -p "${OUTDIR}"/"${1}"

    subsetintersect() {
		awk '$6 ~ /3/ {printf ("%s\t%d\t%d\t%s\n", $1, $2-1, $2, $4)}' "${SITE_ANN}" \
			| bedtools intersect -header -a "${VCFDIR}"/"${2}".vcf.gz -b - > "${OUTDIR}"/"${1}"/"${2}"_0fold.chr${SLURM_ARRAY_TASK_ID}.vcf
        awk '$6 !~ /8|3|2/ && $6 ~ /4/ {printf ("%s\t%d\t%d\t%s\n", $1, $2-1, $2, $4)}' "${SITE_ANN}" \
			| bedtools intersect -header -a "${VCFDIR}"/"${2}".vcf.gz -b - > "${OUTDIR}"/"${1}"/"${2}"_4fold.chr${SLURM_ARRAY_TASK_ID}.vcf
        awk '$6 !~ /8|3|2/ && $6 ~ /4|0|1/ {printf ("%s\t%d\t%d\t%s\n", $1, $2-1, $2, $4)}' "${SITE_ANN}" \
			| bedtools intersect -header -a "${VCFDIR}"/"${2}".vcf.gz -b - > "${OUTDIR}"/"${1}"/"${2}"_4fold_intergenic_intron.chr${SLURM_ARRAY_TASK_ID}.vcf
	
#		bcftools stats "${OUTDIR}"/"${1}"/"${2}"_4fold.vcf > "${OUTDIR}"/"${1}"/"${2}"_4fold.stats
#	    bcftools stats "${OUTDIR}"/"${1}"/"${2}"_4fold_intergenic_intron.vcf > "${OUTDIR}"/"${1}"/"${2}"_4fold_intergenic_intron.stats
#    	bcftools stats "${OUTDIR}"/"${1}"/"${2}"_0fold.vcf > "${OUTDIR}"/"${1}"/"${2}"_0fold.stats
	}

    subsetintersect "${1}" "${VCFNAME}"
    subsetintersect "${1}" "${GVCFNAME}"
}

subsets "Pinusnigra" "_random" "_V1"
#subsets "Phalepensis" "_random" "_V1"
