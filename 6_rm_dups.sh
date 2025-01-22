#!/bin/bash
#SBATCH --job-name=rmdups
#SBATCH --output=rmdups_%j.o
#SBATCH --error=rmdups_%j.e
#SBATCH --account=project_2009301
#SBATCH --partition=small
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --mem=10G
#SBATCH --mail-type=END
#SBATCH --cpus-per-task=1
#SBATCH --gres=nvme:100

export TMPDIR=${LOCAL_SCRATCH}
OUTDIR=/users/mcevoysu/scratch/output/Psylvestris
INPUT=$OUTDIR/Pinus_sylvestris
OUTFILE=$OUTDIR/Pinus_sylvestris_V1
#SPECIES=Pavium

module load vcftools
module load samtools

## remove duplicate samples identified by KING

remove_dups() {
	bcftools view -S ^"$OUTDIR"/sample_ids_duplicates.txt "$INPUT$1".vcf.gz --output-type z > "$OUTFILE$1".vcf.gz
	tabix "$OUTFILE$1".vcf.gz 
	bcftools stats "$OUTFILE$1".vcf.gz > "$OUTDIR"/statistics/"$OUTFILE$1".stats
}

remove_dups ""
#remove_dups "_random"
#remove_dups "_target"

### for SPET only

subset_invar_concat_all() {
        bcftools view -S ^"$OUTDIR"/sample_ids_duplicates.txt -Oz "$OUTDIR/$SPECIES"_SPET_invariant_sampleFilt"$1".vcf.gz  > "$OUTDIR/$SPECIES"_SPET_invariant_sampleFilt_V1"$1".vcf.gz
        tabix "$OUTDIR/$SPECIES"_SPET_invariant_sampleFilt_V1"$1".vcf.gz
        # combine with invariants vcf
        bcftools concat \
                --allow-overlaps \
                "$OUTDIR"/SNP_sampleFilt_V1"$1".vcf.gz "$OUTDIR/$SPECIES"_SPET_invariant_sampleFilt_V1"$1".vcf.gz \
                -O z -o "$OUTDIR"/"$SPECIES"_SPET_allsites_filt_V1"$1".vcf.gz
        tabix "$OUTDIR"/"$SPECIES"_SPET_allsites_filt_V1"$1".vcf.gz
        bcftools stats "$OUTDIR"/"$SPECIES"_SPET_allsites_filt_V1"$1".vcf.gz > "$OUTDIR"/statistics/"$SPECIES"_SPET_allsites_filt_V1"$1".stats
        }

subset_invar_concat_all ""
subset_invar_concat_all "_random"
subset_invar_concat_all "_target"
