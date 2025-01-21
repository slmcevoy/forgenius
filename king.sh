#!/bin/bash
#SBATCH --job-name=king
#SBATCH --output=king_%j.o
#SBATCH --error=king_%j.e
#SBATCH --account=project_2009301
#SBATCH --partition=small
#SBATCH --time=1:00:00
#SBATCH --ntasks=1
#SBATCH --mem=11G
#SBATCH --mail-type=END
#SBATCH --cpus-per-task=4

export PATH=/users/mcevoysu/software:$PATH
# R is only  needed for the plot function
module load r-env
start-r

# need to modify .bim created by plink to put all snps on fake chromosome '1'
# bim format should be CHROM	SNPID	0	position	a1	a2
# awk '$2=$1; $1=1' OFS="\t" Aalba_SNP_sampleFilt.bim > Aalba_SNP_sampleFilt.bim.edited
# mv Aalba_SNP_sampleFilt.bim.edited Aalba_SNP_sampleFilt.bin &&# rm Aalba_SNP_sampleFilt.bim.edited
# 1	aalba5_s00000177	0	174048	A	G

### SPET data
SPECIES=(Aalba Anebrodensis Bpendula Fexcelsior Phalepensis Pinusnigra Tbaccata)
DIR1=/users/mcevoysu/scratch/output
DIR2=vcf_filtering
INPUT="_SNP_sampleFilt.bed"

for S in ${SPECIES[@]}; do
	king -b $DIR1/${S}/$DIR2/${S}${INPUT} --duplicate --prefix king_${S} --cpus 4
	king -b $DIR1/${S}/$DIR2/${S}${INPUT} --related --rplot --prefix king_locimissingness_rel_${S} --cpus 4
done

### chip data
king -b $DIR1/Psylvestris/Pinus_sylvestris.bed --duplicate --prefix king_Psylvestris --cpu 4
king -b $DIR1/Psylvestris/Pinus_sylvestris.bed --related --rplot --prefix king_rel_Psylvestris --cpu 4
king -b $DIR1/Ppinaster/Pinus_pinaster.bed --duplicate --prefix king_Pinuspinaster --cpu 4
king -b $DIR1/Ppinaster/Pinus_pinaster.bed --related --rplot --prefix king_rel_Pinuspinaster --cpu 4
king -b $DIR1/Populusnigra/Populus_nigra.bed --duplicate --prefix king_Populusnigra --cpu 4
king -b $DIR1/Populusnigra/Populus_nigra.bed --related --rplot --prefix king_rel_Populusnigra --cpu 4

