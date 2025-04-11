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

### chip data - not spet

DIR1=/users/mcevoysu/scratch

# vcf provided, create bed, rel, and grm-gz needed for KING

INOUT=Populusnigra/Populus_nigra
#awk -F '\t' 'BEGIN {OFS = FS} {print $(NF-26),$(NF-27),0,$(NF-25) }' $DIR1/data/$INOUT.txt.tmp > $DIR1/data/$INOUT.map
#plink --vcf $DIR1/data/$INOUT.vcf --out $DIR1/output/$INOUT --make-bed --allow-extra-chr --double-id --distance triangle --threads 4 --memory 1000
#plink --vcf $DIR1/data/$INOUT.vcf --out $DIR1/output/$INOUT --make-rel --allow-extra-chr --double-id --distance triangle --threads 4 --memory 1000
#plink --vcf $DIR1/data/$INOUT.vcf --out $DIR1/output/$INOUT --make-grm-gz --allow-extra-chr --double-id --distance triangle --threads 4 --memory 1000


# ped provided, create a vcf and then bed, rel, and grm-gz needed for KING

#INOUT=Psylvestris/Pinus_sylvestris
INOUT=Ppinaster/Pinus_pinaster

# To create a .map, if needed. Didn't end up using this as maps were provided
#awk -F '\t' 'BEGIN {OFS = FS} {print 1,$(NF-26),0,+NR }' $DIR1/data/$INOUT.txt.tmp > $DIR1/data/$INOUT.map
plink --bfile $DIR1/output/$INOUT --out $DIR1/output/$INOUT --recode vcf-iid --keep-allele-order --allow-extra-chr --double-id --distance triangle --threads 4 --memory 1000
bgzip "$DIR1"/output/"$INOUT".vcf
tabix "$DIR1"/output/"$INOUT".vcf.gz
#bcftools stats "$DIR1"/output/"$INOUT".vcf.gz > "$DIR1"/output/Psylvestris/statistics/Pinus_sylvestris.stats
bcftools stats "$DIR1"/output/"$INOUT".vcf.gz > "$DIR1"/output/Ppinaster/statistics/Pinus_pinaster.stats
# create the bed, rel, and grm-gz
plink --no-fid --no-parents --no-sex --no-pheno --file $DIR1/data/$INOUT --out $DIR1/output/$INOUT --make-bed --allow-extra-chr --double-id --distance triangle --threads 4 --memory 1000
plink --no-fid --no-parents --no-sex --no-pheno --file $DIR1/data/$INOUT --out $DIR1/output/$INOUT --make-rel --allow-extra-chr --double-id --distance triangle --threads 4 --memory 1000
plink --no-fid --no-parents --no-sex --no-pheno --file $DIR1/data/$INOUT --out $DIR1/output/$INOUT --make-grm-gz --allow-extra-chr --double-id --distance triangle --threads 4 --memory 1000
