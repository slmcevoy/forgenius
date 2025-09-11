#!/bin/bash
#SBATCH --job-name=sfs
#SBATCH --output=sfs_%j.o
#SBATCH --error=sfs_%j.e
#SBATCH --account=project_2009301
#SBATCH --partition=small
#SBATCH --time=2:00:00
#SBATCH --ntasks=1
#SBATCH --mem=80G
#SBATCH --mail-type=END
#SBATCH --cpus-per-task=1

module load biokit
module load r-env
start-r

# Clean up .Renviron file in home directory
if test -f ~/.Renviron; then
    sed -i '/TMPDIR/d' ~/.Renviron
fi

echo "TMPDIR=/scratch/project_2009301/scripts/tmp" >> ~/.Renviron


resample_fold() {
	DIR=/users/mcevoysu/scratch/output/site_annotation/"${1}"
	SPECIES=$(echo "${1}" | sed 's/_multispecies//')
	OUTDIR=/users/mcevoysu/scratch/output/sfs/"${1}"
	VCFNAME="${1}"_SNP_sampleFilt_locimissingness"${2}${3}"
	mkdir -p $OUTDIR

	if [ "${3}" = "_V2" ]; then
        SAMPLE_SIZE="$(wc -l /users/mcevoysu/scratch/data/${SPECIES}/${SPECIES}_sample_list_filtered"${2}"_rmhybrids.txt | cut -f1 -d ' ' -)"
    elif [ "${3}" = "_V1" ]; then
        SAMPLE_SIZE="$(wc -l /users/mcevoysu/scratch/data/${SPECIES}/${SPECIES}_sample_list_filtered"${2}"_rmdups.txt | cut -f1 -d ' ' -)"
    else
        SAMPLE_SIZE="$(wc -l /users/mcevoysu/scratch/data/${SPECIES}/${SPECIES}_sample_list_filtered"${2}".txt | cut -f1 -d ' ' -)"
    fi

#    declare -a INPUT=("${DIR}"/"${VCFNAME}_0fold.sorted.vcf" \
#		"${DIR}"/"${VCFNAME}_4fold_intergenic_intron.sorted.vcf")
	declare -a INPUT=("${DIR}"/"${VCFNAME}_4fold.vcf")
    for i in "${INPUT[@]}"; do
        FNAME=$(basename "$i" .vcf)
        echo "${FNAME}"
		echo "${SAMPLE_SIZE}"
		bcftools query -Hf "%CHROM\t%POS\t%AN\t%AC\n" "$i" \
			| srun apptainer_wrapper exec Rscript --no-save vcf2sfs_resample.R -f -n "${SAMPLE_SIZE}" \
	   		> "${DIR}"/"${FNAME}".tsv
		# remove first 4 lines and add to the list missing bins with a value of 0
    	awk 'BEGIN{OFS="\t"; i=0} FNR>4  { if($1 != i+1){while ($1 > i + 1){i++; print i, 0;}} i=$1;print $0}' "${DIR}"/"${FNAME}".tsv  > "${DIR}"/"${FNAME}".fixed
        
		x=$( wc -l < "${DIR}"/"${FNAME}".fixed  | tr ' ' '\n')
        
		while [ ${x} -le "${SAMPLE_SIZE}" ]; do echo -e "$x\t0"; x=$(( $x + 1 )); done > "${DIR}"/tmpzeros.tsv
        
		cat "${DIR}"/${FNAME}.fixed "${DIR}"/tmpzeros.tsv | cut -f2 - | tr '\n' ' ' \
			> "${OUTDIR}"/${FNAME}.folded.tsv
	done
}

#resample_fold "Pinusnigra" "_random" "_V1"
#resample_fold "Msylvestris" "_random" "_V2"
resample_fold "Bpendula" "_random" "_V2"
#resample_fold "Pavium" "_random" "_V2"
#resample_fold "Csativa" "_random" "_V1"
#resample_fold "Fsylvatica" "_random" "_V2"
#resample_fold "Storminalis" "" "_V1"

# manual correction of 0-bins using gVCF (_SPET_allsites_filt_locimissingness_random) stats for "no-ALTs"
# Bpendula: 0-fold from 284 to 90942 and 4-fold_intergenic_intron from 3337 to 605568
# Csativa: 0-fold from 720 to 925688 and 4-fold_intergenic_intron from 1222 to 1264255
# Pavium: 0-fold from 134 to 299124 and 4-fold_intergenic_intron from 1559 to 1901880
# Fsylvatica: 0-fold from 328 (update 357) to 130611 and 4-fold_intergenic_intron from 2939 (update 2936) to 941353
# Fsylvatica corrected: 0-fold from 334 to 130611 and 4-fold_intergenic_intron from 2740 to 879389
# Storminalis: : 0-fold from 1540 to 1179203 and 4-fold_intergenic_intron from 1483 to 778538
# Msylvestris: 0-fold from 200 to 97722 and 4-fold_intergenic_intron from 4148 to 1229787
# Pinusnigra: 0-fold from 2645 to 379298 and 4-fold_intergenic_intron from 3053 to 351987

# cat Bpendula_SNP_sampleFilt_locimissingness_random_V2_0fold.folded.tsv Bpendula_SNP_sampleFilt_locimissingness_random_V2_4fold_intergenic_intron.folded.tsv > Bpendula_random_folded_sfs.fxt
# add 1 and 273 to top of file
# cat Csativa_SNP_sampleFilt_locimissingness_random_V1_0fold.folded.tsv Csativa_SNP_sampleFilt_locimissingness_random_V1_4fold_intergenic_intron.folded.tsv > Csativa_random_folded_sfs.txt
# add 1 and 312 to top of file
# cat Fsylvatica_SNP_sampleFilt_locimissingness_random_V2_0fold.folded.tsv Fsylvatica_SNP_sampleFilt_locimissingness_random_V2_4fold_intergenic_intron.folded.tsv > Fsylvatica_random_folded_sfs.txt
# add 1 and 344 to top of file
# cat Msylvestris_SNP_sampleFilt_locimissingness_random_V2_0fold.folded.tsv Msylvestris_SNP_sampleFilt_locimissingness_random_V2_4fold_intergenic_intron.folded.tsv > Msylvestris_random_folded_sfs.txt
# add 1 and 320 to top of file
#cat Pinusnigra_SNP_sampleFilt_locimissingness_random_V1_0fold.sorted.folded.tsv Pinusnigra_SNP_sampleFilt_locimissingness_random_V1_4fold_intergenic_intron.sorted.folded.tsv > Pinusnigra_random_folded_sfs.txt
# add 1 and 369 to top of file

