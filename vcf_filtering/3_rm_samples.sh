#!/bin/bash
#SBATCH --job-name=rmsamples
#SBATCH --output=rmsamples_%j.o
#SBATCH --error=rmsamples_%j.e
#SBATCH --account=project_2009301
#SBATCH --partition=small
#SBATCH --time=04:00:00
#SBATCH --ntasks=1
#SBATCH --mem=40G
#SBATCH --mail-type=END
#SBATCH --cpus-per-task=1
#SBATCH --gres=nvme:100

export TMPDIR=${LOCAL_SCRATCH}

module load vcftools
module load samtools

# # remove outlier and duplicate samples

rmsamples() {
    OUTDIR=/users/mcevoysu/scratch/output/vcf_filtering/"${1}"
    fname=$(basename $f "${4}.vcf.gz")

    if [ "${5}" = "hybrids" ]; then
        INPUT="$OUTDIR"/"${1}"_SNP_sampleFilt"${2}${3}${4}".vcf.gz
        fname=$(basename $INPUT "${4}.vcf.gz")
	    bcftools view -S ^"$OUTDIR"/sample_ids_hybrids.txt "$INPUT" \
            | bcftools view -i "(N_PASS(FORMAT/GT=='RA') + N_PASS(FORMAT/GT=='AA')>=1)" \
            | bcftools view -e '(COUNT(GT="AA")+COUNT(GT="mis"))=N_SAMPLES || (COUNT(GT="RR")+COUNT(GT="mis"))=N_SAMPLES' \
            --output-type z > "$OUTDIR"/"${fname}"_V2.vcf.gz 
        tabix "$OUTDIR"/"${fname}"_V2.vcf.gz
        bcftools stats "$OUTDIR"/"${fname}"_V2.vcf.gz > "$OUTDIR"/statistics/"${fname}"_V2.stats
	if [ ! -f "${1}"_SPET_invariant_sampleFilt"${2}"_V2.vcf.gz ]; then
        if [ ! -f "$OUTDIR"/"sample_ids_duplicates.txt" ]; then
            bcftools view -S ^"$OUTDIR"/sample_ids_hybrids.txt -Oz "$OUTDIR"/"${1}"_SPET_invariant_sampleFilt"${2}".vcf.gz > "$OUTDIR"/"${1}"_SPET_invariant_sampleFilt"${2}"_V2.vcf.gz
        else
            cat "$OUTDIR"/sample_ids_duplicates.txt "$OUTDIR"/sample_ids_hybrids.txt | bcftools view -S ^- -Oz "$OUTDIR"/"${1}"_SPET_invariant_sampleFilt"${2}".vcf.gz > "$OUTDIR"/"${1}"_SPET_invariant_sampleFilt"${2}"_V2.vcf.gz
        fi
        tabix "$OUTDIR"/"${1}"_SPET_invariant_sampleFilt"${2}"_V2.vcf.gz
	fi
        bcftools concat \
            --allow-overlaps \
            "$OUTDIR"/"${fname}"_V2.vcf.gz "$OUTDIR"/"${1}"_SPET_invariant_sampleFilt"${2}"_V2.vcf.gz \
            -O z -o "$OUTDIR"/"${1}"_SPET_allsites_filt"${2}${3}"_V2.vcf.gz
        tabix "$OUTDIR"/"${1}"_SPET_allsites_filt"${2}${3}"_V2.vcf.gz
        bcftools stats "$OUTDIR"/"${1}"_SPET_allsites_filt"${2}${3}"_V2.vcf.gz > "$OUTDIR"/statistics/"${1}"_SPET_allsites_filt"${2}${3}"_V2.stats
    elif [ "${5}" = "duplicates" ]; then
        for f in $OUTDIR/"${1}"_SNP_sampleFilt*.vcf.gz $OUTDIR/"${1}"_SPET_allsites*.vcf.gz; do
            fname=$(basename $f .vcf.gz)
	    bcftools view -S ^"$OUTDIR"/sample_ids_duplicates.txt "$f" --output-type z > "$OUTDIR"/"${fname}"_V1.vcf.gz
            tabix "$OUTDIR"/"${fname}"_V1.vcf.gz
            bcftools stats "$OUTDIR"/"${fname}"_V1.vcf.gz > "$OUTDIR"/statistics/"${fname}"_V1.stats
        done
    else
        echo "Unrecognized removal type"; exit 1;
    fi
}

#rmsamples "species" " empty string or _V1" "duplicates or hybrids"
#rmsamples "Qpubescens" "" "" "" "duplicates"
#rmsamples "Qpubescens" "" "" "_V1" "hybrids"
#rmsamples "Qpubescens_multispecies" "" "" "" "duplicates"
#rmsamples "Qpubescens_multispecies" "" "" "_V1" "hybrids"

#rmsamples "Qpetraea" "" "" "" "duplicates"
#rmsamples "Qpetraea" "" "" "_V1" "hybrids"
#rmsamples "Qpetraea_multispecies" "" "" "" "duplicates"
rmsamples "Qpetraea_multispecies" "" "" "_V1" "hybrids"

#rmsamples "Qrobur" "" "" "" "duplicates"
#rmsamples "Qrobur" "" "" "_V1" "hybrids"
#rmsamples "Qrobur_multispecies" "" "" "" "duplicates"
#rmsamples "Qrobur_multispecies" "" "" "_V1" "hybrids"

#rmsamples "Msylvestris" "" "" "" "duplicates"
#rmsamples "Msylvestris" "" "" "_V1" "hybrids"
#rmsamples "Msylvestris" "_random" "" "_V1" "hybrids"
#rmsamples "Msylvestris" "_target" "" "_V1" "hybrids"

#rmsamples "Pabies" "" "" "" "duplicates"
#rmsamples "Storminalis" "" "" "" "duplicates"

#rmsamples "Fsylvatica" "" "" "" "hybrids"
#rmsamples "Fsylvatica" "_random" "" "" "hybrids"
#rmsamples "Fsylvatica" "_target" "" "" "hybrids"

#rmsamples "Fsylvatica_multispecies" "" "" "" "hybrids"
#rmsamples "Qsuber" "" "" "" "duplicates"
#rmsamples "Qsuber_multispecies" "" "" "" "duplicates"
#rmsamples "Bpendula" "" "" "_V1" "hybrids"
#rmsamples "Bpendula" "_random" "" "_V1" "hybrids"
#rmsamples "Bpendula" "_target" "" "_V1" "hybrids"

#rmsamples "Pavium" "" "" "_V1" "hybrids"
#rmsamples "Pavium" "_random" "" "_V1" "hybrids"
#rmsamples "Pavium" "_target" "" "_V1" "hybrids"

#rmsamples "Fexcelsior" "" "" "_V1" "hybrids"
#rmsamples "Fexcelsior" "_random" "" "_V1" "hybrids"
#rmsamples "Fexcelsior" "_target" "" "_V1" "hybrids"
