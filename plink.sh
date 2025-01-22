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

### SPET data species first, chip below

#SPECIES=(Aalba Anebrodensis Bpendula Fexcelsior Phalepensis Pinusnigra Tbaccata)
#DIR1=/users/mcevoysu/scratch/output
#DIR2=vcf_filtering
#INPUT="SNP_sampleFilt.vcf.gz"
#OUTPUT="_SNP_sampleFilt"

# test of raw SNPs
# did not work due to memory issues
#INPUT="raw_SNP.vcf.gz"
#OUTPUT="_raw_SNP"

# test loci_missingness set
#SPECIES=(Bpendula)
#SPECIES=(Pinusnigra)
#INPUT=SNP_sampleFilt_random_locimissingness.vcf.gz
#OUTPUT=_SNP_sampleFilt_random_locimissingness

#for S in ${SPECIES[@]}; do
#	plink --vcf $DIR1/${S}/$DIR2/$INPUT --out $DIR1/${S}/$DIR2/${S}${OUTPUT} --make-bed --allow-extra-chr --double-id --distance triangle --threads 4 --memory 1000
#	plink --vcf $DIR1/${S}/$DIR2/$INPUT --out $DIR1/${S}/$DIR2/${S}${OUTPUT} --make-rel --allow-extra-chr --threads 4 --memory 1000
#	plink --vcf $DIR1/${S}/$DIR2/$INPUT --out $DIR1/${S}/$DIR2/${S}${OUTPUT} --make-grm-gz no-gz --allow-extra-chr --threads 4 --memory 1000
done;


### chip data - not spet

DIR1=/users/mcevoysu/scratch

# vcf provided, create bed, rel, and grm-gz needed for KING

INOUT=Populusnigra/Populus_nigra

#awk -F '\t' 'BEGIN {OFS = FS} {print $(NF-26),$(NF-27),0,$(NF-25) }' $DIR1/data/$INOUT.txt.tmp > $DIR1/data/$INOUT.map

#plink --vcf $DIR1/data/$INOUT.vcf --out $DIR1/output/$INOUT --make-bed --allow-extra-chr --double-id --distance triangle --threads 4 --memory 1000
#
#plink --vcf $DIR1/data/$INOUT.vcf --out $DIR1/output/$INOUT --make-rel --allow-extra-chr --double-id --distance triangle --threads 4 --memory 1000
#
#plink --vcf $DIR1/data/$INOUT.vcf --out $DIR1/output/$INOUT --make-grm-gz --allow-extra-chr --double-id --distance triangle --threads 4 --memory 1000

#, .ped provided, create a vcf and bed, rel, and grm-gz needed for KING
#INOUT=Psylvestris/Pinus_sylvestris
INOUT=Ppinaster/Pinus_pinaster

# I ended up not needing to create a .map because Sara provided one
#awk -F '\t' 'BEGIN {OFS = FS} {print 1,$(NF-26),0,+NR }' $DIR1/data/$INOUT.txt.tmp > $DIR1/data/$INOUT.map

# create a vcf
plink --bfile $DIR1/output/$INOUT --out $DIR1/output/$INOUT --recode vcf-iid --keep-allele-order --allow-extra-chr --double-id --distance triangle --threads 4 --memory 1000
bgzip "$DIR1"/output/"$INOUT".vcf
tabix "$DIR1"/output/"$INOUT".vcf.gz
bcftools stats "$DIR1"/output/"$INOUT".vcf.gz > "$DIR1"/output/Psylvestris/statistics/Pinus_sylvestris.stats

plink --no-fid --no-parents --no-sex --no-pheno --file $DIR1/data/$INOUT --out $DIR1/output/$INOUT --make-bed --allow-extra-chr --double-id --distance triangle --threads 4 --memory 1000

plink --no-fid --no-parents --no-sex --no-pheno --file $DIR1/data/$INOUT --out $DIR1/output/$INOUT --make-rel --allow-extra-chr --double-id --distance triangle --threads 4 --memory 1000

plink --no-fid --no-parents --no-sex --no-pheno --file $DIR1/data/$INOUT --out $DIR1/output/$INOUT --make-grm-gz --allow-extra-chr --double-id --distance triangle --threads 4 --memory 1000
