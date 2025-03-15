#!/bin/bash
#SBATCH --job-name=pavi
#SBATCH --output=pavi_%j.o
#SBATCH --error=pavi_%j.e
#SBATCH --account=
#SBATCH --partition=small
#SBATCH --time=08:00:00
#SBATCH --ntasks=1
#SBATCH --mem=80G
#SBATCH --mail-type=END
#SBATCH --cpus-per-task=1
#SBATCH --gres=nvme:100

export TMPDIR=${LOCAL_SCRATCH}

#running this step first to separate SNPs for data exploration in scikit-allel: full set of SPET, random only, target only

# just change these three variables as needed
SPECIES=Pavium
GENOME_FILENAME=Prunus_avium_Tieton.chr.fasta
VCF_FILENAME=Prunus_avium_raw.vcf.gz

PROJDIR=/users/mcevoysu/scratch
DATADIR=$PROJDIR/data/$SPECIES
GENOME=$DATADIR/$GENOME_FILENAME
INPUT=$DATADIR/$VCF_FILENAME
OUTDIR=$PROJDIR/output/vcf_filtering/$SPECIES
mkdir -p "$OUTDIR"/statistics

# intervals have been provded in .txt tab-delimited files
# be sure to change these to .bed files with 0-based start coordinate for GATK
SPECIES_LC="${SPECIES,}"
REGIONS=$DATADIR/"$SPECIES_LC"_regions.bed
RANDOM_REGIONS=$DATADIR/"$SPECIES_LC"_random_regions.bed
TARGET_REGIONS=$DATADIR/"$SPECIES_LC"_target_regions.bed

awk 'BEGIN { OFS = "\t" } { print $1, $2-1, $3 }' < $DATADIR/"$SPECIES_LC"_regions.txt > $REGIONS
awk 'BEGIN { OFS = "\t" } { print $1, $2-1, $3 }' < $DATADIR/"$SPECIES_LC"_random_regions.txt > $RANDOM_REGIONS
awk 'BEGIN { OFS = "\t" } { print $1, $2-1, $3 }' < $DATADIR/"$SPECIES_LC"_target_regions.txt > $TARGET_REGIONS

### splitting var and invar following Pixy recommendations
### vars first - invars at end of filtering file
### https://pixy.readthedocs.io/en/latest/guide/pixy_guide.html#optional-population-genetic-filters

module load vcftools
module load samtools
module load gatk/4.5.0.0

gatk CreateSequenceDictionary -R "$GENOME"
samtools faidx "$GENOME"

# SNP selection
# --ignore-non-ref-in-types If set, NON_REF alleles will be ignored for variant type determination, which is required for filtering GVCF files by type
# https://github.com/broadinstitute/gatk/pull/7193
gatk --java-options "-Djava.io.tmpdir=${LOCAL_SCRATCH} -Xmx60G" SelectVariants \
-R "$GENOME" \
-V "$INPUT" \
-L "$REGIONS" \
--select-type-to-include SNP \
--ignore-non-ref-in-types TRUE \
-O "$OUTDIR"/raw_SNP.vcf.gz

# create subsets
bcftools view -Oz -R "$RANDOM_REGIONS" "$OUTDIR"/raw_SNP.vcf.gz -o $OUTDIR/raw_SNP_random.vcf.gz
bcftools view -Oz -R "$TARGET_REGIONS" "$OUTDIR"/raw_SNP.vcf.gz -o $OUTDIR/raw_SNP_target.vcf.gz

# write statistics
bcftools stats "$OUTDIR"/raw_SNP.vcf.gz > "$OUTDIR"/statistics/raw_SNP.stats
bcftools stats "$OUTDIR"/raw_SNP_random.vcf.gz > "$OUTDIR"/statistics/raw_SNP_random.stats
bcftools stats "$OUTDIR"/raw_SNP_target.vcf.gz > "$OUTDIR"/statistics/raw_SNP_target.stats

