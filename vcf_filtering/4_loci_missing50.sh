#!/bin/bash
#SBATCH --job-name=loci
#SBATCH --output=loci_%j.o
#SBATCH --error=loci_%j.e
#SBATCH --account=project_2009301
#SBATCH --partition=small
#SBATCH --time=1:00:00
#SBATCH --ntasks=1
#SBATCH --mem=5G
#SBATCH --mail-type=END
#SBATCH --cpus-per-task=1

module load biokit
module load samtools

DIR=/users/mcevoysu/scratch/output/vcf_filtering

loci_filt() {
	INPUT="$1_SNP_sampleFilt$2$3.vcf.gz"
	SPECIES=$(echo "${1}" | sed 's/_multispecies//')
	# sample size of final filtered vcf, not samples.txt
	if [ "${3}" = "_V2" ]; then
		if [ ! -f "$DIR"/"${1}"/"${1}"_SPET_invariant_sampleFilt"${2}${3}".vcf.gz ]; then
        	bcftools view -S ^"$DIR"/"${1}"/sample_ids_duplicates.txt -Oz "$DIR"/"${1}"/"${1}"_SPET_invariant_sampleFilt"$2".vcf.gz | bcftools view -S ^"$DIR"/"${1}"/sample_ids_hybrids.txt -Oz - > "$DIR"/"${1}"/"${1}"_SPET_invariant_sampleFilt"${2}"_V2.vcf.gz
			tabix "$DIR"/"${1}"/"${1}"_SPET_invariant_sampleFilt"${2}"_V2.vcf.gz
    fi
		SAMPLE_SIZE="$(wc -l /users/mcevoysu/scratch/data/${SPECIES}/${SPECIES}_sample_list_filtered"${2}"_rmhybrids.txt | cut -f1 -d ' ' -)"
	elif [ "${3}" = "_V1" ]; then
		if [ ! -f "$DIR"/"${1}"/"${1}"_SPET_invariant_sampleFilt"${2}${3}".vcf.gz ]; then
	        bcftools view -S ^"$DIR"/"${1}"/sample_ids_duplicates.txt -Oz "$DIR"/"${1}"/"${1}"_SPET_invariant_sampleFilt"${2}".vcf.gz > "$DIR"/"${1}"/"${1}"_SPET_invariant_sampleFilt"${2}"_V1.vcf.gz
			tabix "$DIR"/"${1}"/"${1}"_SPET_invariant_sampleFilt"${2}"_V1.vcf.gz
    	fi
		SAMPLE_SIZE="$(wc -l /users/mcevoysu/scratch/data/${SPECIES}/${SPECIES}_sample_list_filtered"${2}"_rmdups.txt | cut -f1 -d ' ' -)"
	else
		SAMPLE_SIZE="$(wc -l /users/mcevoysu/scratch/data/${SPECIES}/${SPECIES}_sample_list_filtered"${2}".txt | cut -f1 -d ' ' -)"
	fi
	bcftools +fill-tags $DIR/"${1}"/$INPUT -- -t "F_MISSING,AN" | bcftools query -Hf "%CHROM\t%POS\t%AN\t%F_MISSING\n" \
		-o $DIR/"${1}"/missing_data"${2}${3}".tsv -
	awk -v samplesize="${SAMPLE_SIZE}" 'BEGIN {OFS="\t"}; (NR>1 && $3>=samplesize) {print $0}' \
		$DIR/$1/missing_data$2$3.tsv > $DIR/$1/missingness_keep$2$3.tsv
	awk -v samplesize="${SAMPLE_SIZE}" 'BEGIN {OFS="\t"}; (NR>1 && $3<samplesize) {print $0}' \
		$DIR/$1/missing_data$2$3.tsv > $DIR/$1/missingness_remove$2$3.tsv
	cut -d $'\t' -f1,2 $DIR/"${1}"/missingness_keep"${2}${3}".tsv \
		| bcftools view -R - $DIR/"${1}"/$INPUT \
		-O z -o $DIR/"${1}"/"${1}"_SNP_sampleFilt_locimissingness"${2}${3}".vcf.gz
	tabix $DIR/"${1}"/"${1}"_SNP_sampleFilt_locimissingness"${2}${3}".vcf.gz
	bcftools stats $DIR/"${1}"/"${1}"_SNP_sampleFilt_locimissingness"${2}${3}".vcf.gz > $DIR/"${1}"/statistics/"${1}"_SNP_sampleFilt_locimissingness"${2}${3}".stats

	bcftools concat \
            --allow-overlaps \
            "$DIR"/"${1}"/"${1}"_SNP_sampleFilt_locimissingness"${2}${3}".vcf.gz "$DIR"/"${1}"/"${1}"_SPET_invariant_sampleFilt"${2}${3}".vcf.gz \
            -O z -o "$DIR"/"${1}"/"${1}"_SPET_allsites_filt_locimissingness"${2}${3}".vcf.gz
	tabix "$DIR"/"${1}"/"${1}"_SPET_allsites_filt_locimissingness"${2}${3}".vcf.gz
    bcftools stats "$DIR"/"${1}"/"${1}"_SPET_allsites_filt_locimissingness"${2}${3}".vcf.gz > "$DIR"/"${1}"/statistics/"${1}"_SPET_allsites_filt_locimissingness"${2}${3}".stats
}

#loci_filt "Bpendula" "" "_V2"
#loci_filt "Bpendula" "_random" "_V2"
#loci_filt "Bpendula" "_target" "_V2"

#loci_filt "Csativa" "" "_V1"
#loci_filt "Csativa" "_random" "_V1"
#loci_filt "Csativa" "_target" "_V1"
#loci_filt "Csativa_multispecies" "" "_V1"

#loci_filt "Fsylvatica" "" "_V2"
#loci_filt "Fsylvatica" "_random" "_V2"
#loci_filt "Fsylvatica" "_target" "_V2"
#loci_filt "Fsylvatica_multispecies" "" "_V2"

#loci_filt "Msylvestris" "" "_V2"
#loci_filt "Msylvestris" "_random" "_V2"
#loci_filt "Msylvestris" "_target" "_V2"

#loci_filt "Storminalis" "" "_V1"

#loci_filt "Pavium" "" "_V2"
#loci_filt "Pavium" "_random" "_V2"
#loci_filt "Pavium" "_target" "_V2"

# fix sample lists
#loci_filt "Phalepensis" "" "_V1"
#loci_filt "Phalepensis" "_random" "_V1"
#loci_filt "Phalepensis" "_target" "_V1"

#loci_filt "Pinusnigra" "" "_V1"
#loci_filt "Pinusnigra" "_random" "_V1"
#loci_filt "Pinusnigra" "_target" "_V1"

# Qilex is V0
#loci_filt "Qilex" "" ""

#loci_filt "Qsuber" "" "_V1"
#loci_filt "Qsuber" "_random" "_V1"
#loci_filt "Qsuber" "_target" "_V1"
#loci_filt "Qsuber_multispecies" "" "_V1"

# Tbaccata is V0
