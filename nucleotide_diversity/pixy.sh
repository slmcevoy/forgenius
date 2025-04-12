#!/bin/bash
#SBATCH --job-name=pixy
#SBATCH --output=pixy_%j.o
#SBATCH --error=pixy_%j.e
#SBATCH --account=project_2009301
#SBATCH --partition=small
#SBATCH --time=08:00:00
#SBATCH --ntasks=1
#SBATCH --mem=80G
#SBATCH --mail-type=END
#SBATCH --cpus-per-task=16

export PATH=$PATH:/projappl/project_2009301/software/pixy/bin
module load r-env/442

# Clean up .Renviron file in home directory
if test -f ~/.Renviron; then
    sed -i '/TMPDIR/d' ~/.Renviron
fi

# Specify a temp folder path
echo "TMPDIR=${LOCAL_SCRATCH}" >> ~/.Renviron


setupPixy() (
	DATADIR=/users/mcevoysu/scratch/data
	OUTPUT=/users/mcevoysu/scratch/output
	SPECIES=$(echo "${1}" | sed 's/_multispecies//')
	mkdir -p "$OUTPUT"/pixy/"$1"
   
    runPixy() {
        echo "Three: ${3}"
        echo "Two ${2}"
        if [ ! -f "$DATADIR"/"${SPECIES}"/"${SPECIES,,}""${3}"_regions.bed ]; then
            BED="$DATADIR"/"${SPECIES}"/"${4}"
        else
            BED="$DATADIR"/"${SPECIES}"/"${SPECIES,,}""${3}"_regions.bed
        fi
        echo "BED: ${BED}"
        echo "VCF: $OUTPUT"/vcf_filtering/"$1"/"$1"_SPET_allsites_filt"${3}${2}".vcf.gz
        echo "POP: $DATADIR"/"${SPECIES}"/"${SPECIES}"_sample_list_filtered"${3}""${RMLIST}".txt
	    pixy --stats pi dxy fst \
	    --vcf "$OUTPUT"/vcf_filtering/"$1"/"$1"_SPET_allsites_filt"${3}${2}".vcf.gz \
	    --populations "$DATADIR"/"${SPECIES}"/"${SPECIES}"_sample_list_filtered"${3}""${RMLIST}".txt \
	    --bed_file "${BED}" \
	    --n_cores 16 \
	    --output_folder "$OUTPUT"/pixy/"${1}" \
	    --output_prefix pixy_"${1}${3}${2}"
    }

    popnt() {
        OUTPUT=/users/mcevoysu/scratch/output/pixy/"${1}"

        for f in "$OUTPUT"/*_pi.txt
        do
            fname=$(basename $f .txt)
            grep -v "NA" "$f" > "$OUTPUT"/"$fname"_NAfilt.txt
        done

        srun apptainer_wrapper exec Rscript --no-save pixysummary.R "${1}" "${2}" "${3}"
    }

    if [ -z "${2}" ]; then
        RMLIST=""
    elif [[ "${2}" =~ "_V1" ]]; then
        RMLIST="_rmdups"
    elif [[ "${2}" =~ "_V2" ]]; then
        RMLIST="_rmhybrids"
    else
        echo "Unrecognized removal type"; exit 1;
    fi

    if [[ "${3}" =~ "yes" ]]; then
        runPixy "${1}" "${2}" "" "${4}"
        runPixy "${1}" "${2}" "_random" "${4}"
        runPixy "${1}" "${2}" "_target" "${4}"
    else 
        runPixy "${1}" "${2}" "" "${4}"
    fi

    popnt "${1}" "${2}" "${3}" 
)


# arguments: popnt(species, version, subsets)

setupPixy "Aalba" "_V1" "yes"
#no v2

#setupPixy "Anebrodensis" "_V1" "yes"
# no v2

#setupPixy "Bpendula" "_V1" "yes"
#setupPixy "Bpendula" "_V2" "yes"

#setupPixy "Csativa" "_V1" "yes"
#setupPixy "Csativa_multispecies" "_V1" "no" "Csat-Fsyl-Qile-Qrob_regions.bed"
# no v2

# Fsylvatica V0=V1
#setupPixy "Fsylvatica" "" "yes"
#setupPixy "Fsylvatica" "_V2" "yes"
#setupPixy "Fsylvatica_multispecies" "" "Fsyl-Csat-Qile-Qrob_regions.bed"
#setupPixy "Fsylvatica_multispecies" "_V2" "Fsyl-Csat-Qile-Qrob_regions.bed"

#setupPixy "Fexcelsior" "_V1" "yes"
#setupPixy "Fexcelsior" "_V2" "yes"

#setupPixy "Phalepensis" "_V1" "yes"
# no v2

#setupPixy "Pinusnigra" "_V1" "yes"
# v2 not determined yet

#setupPixy "Pabies" "_V1" "yes"

#setupPixy "Pavium" "_V1" "yes"
#setupPixy "Pavium" "_V2" "yes"

# Qilex V0=V1
#setupPixy "Qilex" "" "no" "qilex-qrobur_regions.bed"
#setupPixy "Qilex_multispecies" "" "no" "qilex-qrobur-Csat-Fsyl_regions.bed"
# no v2

#setupPixy "Qsuber" "_V1" "no" "qilex-qrobur_regions.bed"
#setupPixy "Qsuber_multispecies" "_V1" "no" "qilex-qrobur-Csat-Fsyl_regions.bed"
# no v2

#setupPixy "Storminalis" "_V1" "no"

# Tbaccata V0=V1
#setupPixy "Tbaccata" "" "yes"
# no v2

# Anebrodensis is run by itself.  Only 1 pop, so the dxy and fst flags in the general script cause an error
#DATADIR=/users/mcevoysu/scratch/data
#OUTPUT=/users/mcevoysu/scratch/output
#SUBSET=""
#SUBSET="_random"
#SUBSET="_target"

#pixy --stats pi \
#        --vcf "$OUTPUT"/vcf_filtering/Anebrodensis/Anebrodensis_SPET_allsites_filt"$SUBSET"_V1.vcf.gz \
#        --populations "$DATADIR"/Anebrodensis/Anebrodensis_sample_list_filtered"$SUBSET"_rmdups.txt \
#		--bed_file "$DATADIR"/Anebrodensis/anebrodensis"$SUBSET"_regions.bed \
#        --n_cores 16 \
#        --output_folder "$OUTPUT"/pixy/Anebrodensis \
#        --output_prefix pixy_Anebrodensis_V1"$SUBSET"

#DATADIR=/users/mcevoysu/scratch/data/Aalba
#OUTPUT=/users/mcevoysu/scratch/output/Aalba
#INPUT=$OUTPUT/vcf_filtering/Aalba_SPET_allsites_filt_random.vcf.gz
#INPUT=$OUTPUT/vcf_filtering/Aalba_SPET_allsites_filt_target.vcf.gz
#INPUT=$OUTPUT/vcf_filtering/Aalba_SPET_allsites_filt.vcf.gz
#SPECIES=Aalba
#INPUT=$OUTPUT/vcf_filtering/Aalba_SPET_allsites_filt_V1.vcf.oldheader.gz
#INPUT=$OUTPUT/vcf_filtering/Aalba_SPET_allsites_filt_V1_random.vcf.oldheader.gz
#INPUT=$OUTPUT/vcf_filtering/Aalba_SPET_allsites_filt_V1_target.vcf.oldheader.gz
