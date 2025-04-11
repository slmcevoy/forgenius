#!/bin/bash
#SBATCH --job-name=plink
#SBATCH --output=plink_%j.o
#SBATCH --error=plink_%j.e
#SBATCH --account=project_2009301
#SBATCH --partition=small
#SBATCH --time=1:00:00
#SBATCH --ntasks=1
#SBATCH --mem=10G
#SBATCH --mail-type=END
#SBATCH --cpus-per-task=4

module load plink/1.90
module load biokit

SPECIES=(Aalba Anebrodensis Bpendula Csativa Csativa_multispecies Fexcelsior Fsylvatica Fsylvatica_multispecies Pabies Pavium Phalepensis Pinusnigra Qilex Qilex_multispecies Qpetraea Qpetraea_multispecies Qpubescens Qpubescens_multispecies Qrobur Qrobur_multispecies Qsuber Qsuber_multispecies Storminalis Tbaccata)
DIR=/users/mcevoysu/scratch/output/vcf_filtering
INPUT="SNP_sampleFilt.vcf.gz"
OUTPUT="_SNP_sampleFilt"

for S in ${SPECIES[@]}; do
    [[ -f $DIR/${S}/${S}$INPUT ]] || { echo "File not found"; exit 1; }
    plink --vcf $DIR/${S}/${S}$INPUT --out $DIR/${S}/${S}${OUTPUT} --make-bed --allow-extra-chr --double-id --distance triangle --threads 4 --memory 5000
    plink --vcf $DIR/${S}/${S}$INPUT --out $DIR/${S}/${S}${OUTPUT} --make-rel --allow-extra-chr --threads 4 --memory 5000
    plink --vcf $DIR/${S}/${S}$INPUT --out $DIR/${S}/${S}${OUTPUT} --make-grm-gz no-gz --allow-extra-chr --threads 4 --memory 5000
    cp $DIR/${S}/${S}${OUTPUT}.bim $DIR/${S}/${S}${OUTPUT}.bim.save
    awk '$1=1' OFS="\t"  $DIR/${S}/${S}${OUTPUT}.bim > $DIR/${S}/${S}${OUTPUT}.bim.edited
    mv $DIR/${S}/${S}${OUTPUT}.bim.edited $DIR/${S}/${S}${OUTPUT}.bim
done;
