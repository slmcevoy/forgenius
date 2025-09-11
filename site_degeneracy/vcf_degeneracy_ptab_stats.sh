#!/bin/bash
#SBATCH --job-name=vcfdeg
#SBATCH --output=vcfdeg_%j.o
#SBATCH --error=vcfdeg_%j.e
#SBATCH --account=project_2009301
#SBATCH --partition=small
#SBATCH --time=3:00:00
#SBATCH --ntasks=1
#SBATCH --mem=80G
#SBATCH --mail-type=END
#SBATCH --cpus-per-task=1

module load biokit

DIR=/users/mcevoysu/scratch/output
OUTDIR="$DIR"/site_annotation/Pinusnigra

bcftools stats "${OUTDIR}"/Pinusnigra_SNP_sampleFilt_locimissingness_random_V1_4fold.sorted.vcf > "${OUTDIR}"/Pinusnigra_SNP_sampleFilt_locimissingness_random_V1_4fold.sorted.stats
bcftools stats "${OUTDIR}"/Pinusnigra_SNP_sampleFilt_locimissingness_random_V1_4fold_intergenic_intron.sorted.vcf > "${OUTDIR}"/Pinusnigra_SNP_sampleFilt_locimissingness_random_V1_4fold_intergenic_intron.sorted.stats
bcftools stats "${OUTDIR}"/Pinusnigra_SNP_sampleFilt_locimissingness_random_V1_0fold.sorted.vcf > "${OUTDIR}"/Pinusnigra_SNP_sampleFilt_locimissingness_random_V1_0fold.sorted.stats

bcftools stats "${OUTDIR}"/Pinusnigra_SPET_allsites_filt_locimissingness_random_V1_4fold.sorted.vcf > "${OUTDIR}"/Pinusnigra_SPET_allsites_filt_locimissingness_random_V1_4fold.sorted.stats
bcftools stats "${OUTDIR}"/Pinusnigra_SPET_allsites_filt_locimissingness_random_V1_4fold_intergenic_intron.sorted.vcf > "${OUTDIR}"/Pinusnigra_SPET_allsites_filt_locimissingness_random_V1_4fold_intergenic_intron.sorted.stats
bcftools stats "${OUTDIR}"/Pinusnigra_SPET_allsites_filt_locimissingness_random_V1_0fold.sorted.vcf > "${OUTDIR}"/Pinusnigra_SPET_allsites_filt_locimissingness_random_V1_0fold.sorted.stats

