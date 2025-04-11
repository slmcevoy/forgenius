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

### SPET data
SPECIES=(Aalba Anebrodensis Bpendula Csativa Csativa_multispecies Fexcelsior Fsylvatica Fsylvatica_multispecies Pabies Pavium Phalepensis Pinusnigra Qilex Qilex_multispecies Qpetraea Qpetraea_multispecies Qpubescens Qpubescens_multispecies Qrobur Qrobur_multispecies Qsuber Qsuber_multispecies Storminalis Tbaccata)
DIR=/users/mcevoysu/scratch/output/vcf_filtering
PREFIX=/users/mcevoysu/scratch/output/king
INPUT="_SNP_sampleFilt.bed"

for S in ${SPECIES[@]}; do
    mkdir -p $PREFIX/${S}
#   king -b $DIR/${S}/${S}${INPUT} --unrelated --degree 2 --prefix $PREFIX/${S}/king_unrelated_${S} --cpus 4
    [[ -f $DIR/${S}/${S}${INPUT} ]] || { echo "File not found"; exit 1; }
    king -b $DIR/${S}/${S}${INPUT} --kinship --prefix $PREFIX/${S}/king_kinship_${S} --cpus 4
    king -b $DIR/${S}/${S}${INPUT} --duplicate --prefix $PREFIX/${S}/king_duplicate_${S} --cpus 4
    king -b $DIR/${S}/${S}${INPUT} --related --rplot --prefix $PREFIX/${S}/king_related_${S} --cpus 4
	# clean up results for summary file
	cut -f2,4-11 $PREFIX/${S}/king_duplicate_${S}.con > $PREFIX/${S}/${S}_duplicates.txt
done

### chip data
king -b $DIR/Psylvestris/Pinus_sylvestris.bed --duplicate --prefix $DIR/king/king_duplicate_Psylvestris --cpu 4
king -b $DIR/Psylvestris/Pinus_sylvestris.bed --related --rplot --prefix $DIR/king/king_related_Psylvestris --cpu 4
king -b $DIR/Ppinaster/Pinus_pinaster.bed --duplicate --prefix $DIR/king/king_duplicate_Pinuspinaster --cpu 4
king -b $DIR/Ppinaster/Pinus_pinaster.bed --related --rplot --prefix $DIR/king/king_related_Pinuspinaster --cpu 4
king -b $DIR/Populusnigra/Populus_nigra.bed --duplicate --prefix $DIR/king/king_duplicate_Populusnigra --cpu 4
king -b $DIR/Populusnigra/Populus_nigra.bed --related --rplot --prefix $DIR/king/king_related_Populusnigra --cpu 4

