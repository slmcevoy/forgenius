#!/bin/bash

# running this step first to separate SNPs for data exploration in scikit-allel: full set of SPET, random only, target only

export TMPDIR=${LOCAL_SCRATCH}
SPECIES=Fexcelsior
GENOME=FRAX_001_PL_genomic.fasta
INPUT=Fraxinus_excelsior_raw.vcf.gz
OUTCORE=vcf_filtering
OUTDIR=$OUTCORE
mkdir -p "$OUTDIR"/statistics
REGIONS=Fexcelsior_region.bed
RANDOM_REGIONS=Fexcelsior_random_region.bed
TARGET_REGIONS=Fexcelsior_target_region.bed

### splitting var and invar following Pixy recommendations
### https://pixy.readthedocs.io/en/latest/guide/pixy_guide.html#optional-population-genetic-filters

module load vcftools
module load samtools
module load gatk/4.5.0.0

gatk CreateSequenceDictionary -R "$GENOME"
samtools faidx "$GENOME"

gatk IndexFeatureFile \
	     -I $INPUT

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

module load vcftools
module load samtools
bcftools stats "$OUTDIR"/raw_SNP.vcf.gz > "$OUTDIR"/statistics/raw_SNP.stats

bcftools view -Oz -R "$RANDOM_REGIONS" "$OUTDIR"/raw_SNP.vcf.gz -o $OUTDIR/raw_SNP_random.vcf.gz
bcftools view -Oz -R "$TARGET_REGIONS" "$OUTDIR"/raw_SNP.vcf.gz -o $OUTDIR/raw_SNP_target.vcf.gz
bcftools stats "$OUTDIR"/raw_SNP_random.vcf.gz > "$OUTDIR"/statistics/raw_SNP_random.stats
bcftools stats "$OUTDIR"/raw_SNP_target.vcf.gz > "$OUTDIR"/statistics/raw_SNP_target.stats

