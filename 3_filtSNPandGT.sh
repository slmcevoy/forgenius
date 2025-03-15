#!/bin/bash
#SBATCH --job-name=snpfilter
#SBATCH --output=snpfilter_%j.o
#SBATCH --error=snpfilter_%j.e
#SBATCH --account=project_2009301
#SBATCH --partition=small
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --mem=80G
#SBATCH --mail-type=END
#SBATCH --cpus-per-task=1
#SBATCH --gres=nvme:100

### general flow: 
### split variable and invariable for separate filtering (following Pixy's recommendations)
###   first filter for SNPs using gatk; bcftools used to get invariant sites
### SNPs: variant filtering -> paralog filtering -> genotype filtering ->
###   then subset files for random and target SPET (sample missingness can vary greatly between the two)
###   sample filtering by missingness on all 3 files: random, target, all
### invariants: filtering by depth only
###   subset files for random and target regions
### combine SNP and invariants for all 3 sets: random, target, all

export TMPDIR=${LOCAL_SCRATCH}

# just change these 3 variables
SPECIES=Pavium
GENOME_FILENAME=Prunus_avium_Tieton.chr.fasta
VCF_FILENAME=Prunus_avium_raw.vcf.gz

PROJDIR=/users/mcevoysu/scratch
DATADIR=$PROJDIR/data/$SPECIES
GENOME=$DATADIR/$GENOME_FILENAME
INPUT=$DATADIR/$VCF_FILENAME
OUTDIR=$PROJDIR/output/vcf_filtering/$SPECIES

SPECIES_LC="${SPECIES,}"
REGIONS=$DATADIR/"$SPECIES_LC"_regions.bed
RANDOM_REGIONS=$DATADIR/"$SPECIES_LC"_random_regions.bed
TARGET_REGIONS=$DATADIR/"$SPECIES_LC"_target_regions.bed

INVARIANT="$OUTDIR/$SPECIES"_SPET_invariant.g.vcf.gz
INVARIANT2="$OUTDIR/$SPECIES"_SPET_invariant_filt.g.vcf.gz

SAMPLE_SIZE="$(wc -l /users/mcevoysu/scratch/data/${SPECIES}/samples.txt | cut -f1 -d ' ' -)"
echo "$(($SAMPLE_SIZE/2))"

ln -s ../HDplot_analyze.R .
ln -s ../HDplot_python.p645.py .
ln -s ../vcf_to_depth_p645.py .

module load vcftools
module load samtools
module load gatk/4.5.0.0

## VariantFiltration
gatk --java-options "-Djava.io.tmpdir=${LOCAL_SCRATCH} -Xmx60G" VariantFiltration \
-R "$GENOME" \
-L "$REGIONS" \
-V "$OUTDIR"/raw_SNP.vcf.gz \
--filter-expression "QD < 2.0 || MQ < 40.0 || MQRankSum < -12.5" \
--filter-name "FILT" \
--output "$OUTDIR"/raw_SNP_toFilt.vcf.gz

## Exclude filtered variants
gatk --java-options "-Djava.io.tmpdir=${LOCAL_SCRATCH} -Xmx60G" SelectVariants \
-R "$GENOME" \
-L "$REGIONS" \
-V "$OUTDIR"/raw_SNP_toFilt.vcf.gz \
--ignore-non-ref-in-types TRUE \
--output "$OUTDIR"/SNPs.vcf.gz \
--exclude-filtered

bcftools stats "$OUTDIR"/SNPs.vcf.gz > "$OUTDIR"/statistics/SNPs.stats

# Paralog filtering using HDplot as described in github GenTree repository https://github.com/GenTree-h2020-eu/GenTree/blob/master/rellstab/read_me.txt
# Used scripts (HDplot_python.p645.py and HDplot_analyze.R) are attached. Parameters used to select the list of SNPs to filter: Hmax=0.6, RAFmin=0.2, RAFmax=0.8, Dmin= -10, Dmax=10.

export PATH="/projappl/project_2009301/software/statsmodel/bin:$PATH"

#run HDplot - high het and allele read ratio deviation (ones that are not 50%)
zcat "$OUTDIR"/SNPs.vcf.gz > "$OUTDIR"/SNPs.vcf
python HDplot_python.p645.py "$OUTDIR"/SNPs.vcf
mv SNPs.depthsBias "$OUTDIR"/
mv SNPs.depths "$OUTDIR"/

#count missing data with vcftools
vcftools --vcf "$OUTDIR"/SNPs.vcf --out "$OUTDIR"/SNPs.miss --missing-site

module load r-env/432

# Clean up .Renviron file in home directory
if test -f ~/.Renviron; then
    sed -i '/TMPDIR/d' ~/.Renviron
fi

# Specify a temp folder path
echo "TMPDIR=${LOCAL_SCRATCH}" >> ~/.Renviron

# Run the R script
srun apptainer_wrapper exec Rscript --no-save HDplot_analyze.R "$OUTDIR"

# Filter out SNPs
bcftools view -T ^"$OUTDIR"/HD_SNP_list_toFilt.txt "$OUTDIR"/SNPs.vcf.gz \
--output-type z > "$OUTDIR"/SNPs_HDfilt.vcf.gz
tabix "$OUTDIR"/SNPs_HDfilt.vcf.gz
bcftools stats "$OUTDIR"/SNPs_HDfilt.vcf.gz > "$OUTDIR"/statistics/paralogfilt.stats

# # SNP filtering with bcftools in order to: 
# # select only biallelic SNPs
# # mask genotypes with DP<6 and GQ<20
# # keep positions where more than half the samples have a depth greater than 5
# # mask genotypes in which minor allele is covered by less than 3 reads
# # remove positions that are no longer polymorphic 

# "mis" missing genotypes
# AA alt-alt hom
# RR ref-ref hom
# AR ref-alt het
# AD[:0] any sample, 1st AD field
# AD[:1] any sample, second AD field
# N_PASS number of samples which pass the expression

bcftools view "$OUTDIR"/SNPs_HDfilt.vcf.gz \
 | bcftools view -m2 -M2 \
 | bcftools filter -i "(FORMAT/DP>=6)" --set-GTs . \
 | bcftools filter -i "(FORMAT/GQ>=20)" --set-GTs . \
 | bcftools view -i "(N_PASS(FORMAT/DP>=6)>=$((${SAMPLE_SIZE}/2)))" \
 | bcftools filter -i "(((FORMAT/GT='AR') & (FORMAT/AD[:0]>2) & (FORMAT/AD[:1]>2)) | ((FORMAT/GT='RR') & (FORMAT/AD[:0]>2)) | ((FORMAT/GT='AA') & (FORMAT/AD[:1]>2)))" --set-GTs . \
 | bcftools view -i "(N_PASS(FORMAT/GT=='RA') + N_PASS(FORMAT/GT=='AA')>=1)" \
 | bcftools view -e '(COUNT(GT="AA")+COUNT(GT="mis"))=N_SAMPLES || (COUNT(GT="RR")+COUNT(GT="mis"))=N_SAMPLES' \
 --output-type z > "$OUTDIR"/SNPs_filt.vcf.gz
bcftools stats "$OUTDIR"/SNPs_filt.vcf.gz > "$OUTDIR"/statistics/SNPs_filt.stats
tabix "$OUTDIR"/SNPs_filt.vcf.gz
bcftools view -Oz -R "$RANDOM_REGIONS" "$OUTDIR"/SNPs_filt.vcf.gz -o $OUTDIR/SNPs_filt_random.vcf.gz
bcftools view -Oz -R "$TARGET_REGIONS" "$OUTDIR"/SNPs_filt.vcf.gz -o $OUTDIR/SNPs_filt_target.vcf.gz

subset_snps() {
	# # Calculate the per sample % of missing data per sample
	vcftools --gzvcf "$OUTDIR"/SNPs_filt"$1".vcf.gz --out "$OUTDIR"/SNPs_filt"$1".ind_miss --missing-indv
	# get a list of samples with missing > 80
	awk '$5 > 0.80000000' "$OUTDIR"/SNPs_filt"$1".ind_miss.imiss | grep -v 'INDV' - | cut -f1 - > "$OUTDIR"/sample_ids"$1".txt
	
	
	# # remove possible samples with >80% missing data and remove positions that are no longer polymorphic
	 bcftools view -S ^"$OUTDIR"/sample_ids"$1".txt "$OUTDIR"/SNPs_filt"$1".vcf.gz \
	 | bcftools view -i "(N_PASS(FORMAT/GT=='RA') + N_PASS(FORMAT/GT=='AA')>=1)" \
	 | bcftools view -e '(COUNT(GT="AA")+COUNT(GT="mis"))=N_SAMPLES || (COUNT(GT="RR")+COUNT(GT="mis"))=N_SAMPLES' \
	 --output-type z > "$OUTDIR"/"$SPECIES"_SNP_sampleFilt"$1".vcf.gz
	tabix "$OUTDIR"/"$SPECIES"_SNP_sampleFilt"$1".vcf.gz
	bcftools stats "$OUTDIR"/"$SPECIES"_SNP_sampleFilt"$1".vcf.gz > "$OUTDIR"/statistics/SNP_sampleFilt"$1".stats
}

subset_snps ""
subset_snps "_random"
subset_snps "_target"

loci_missing_50() {
	bcftools +fill-tags "$OUTDIR"/SNP_sampleFilt"$1".vcf.gz -- -t "F_MISSING,AN" | bcftools query -Hf "%CHROM\t%POS\t%AN\t%F_MISSING\n" -o "$OUTDIR"/missing_data$1.tsv -
	awk -v samplesize="${SAMPLE_SIZE}" 'BEGIN {OFS="\t"}; (NR>1 && $3>=samplesize) {print $0}' "$OUTDIR"/missing_data"$1".tsv > "$OUTDIR"/missingness_keep"$1".tsv
	awk -v samplesize="${SAMPLE_SIZE}" 'BEGIN {OFS="\t"}; (NR>1 && $3<samplesize) {print $0}' "$OUTDIR"/missing_data"$1".tsv > "$OUTDIR"/missingness_remove"$1".tsv
	cut -d $'\t' -f1,2 "$OUTDIR"/missingness_keep"$1".tsv | bcftools view -R - "$OUTDIR"/SNP_sampleFilt"$1".vcf.gz -O z -o "$OUTDIR"/${SPECIES}_SNP_sampleFilt"$1"_locimissingness.vcf.gz
	tabix "$OUTDIR"/${SPECIES}_SNP_sampleFilt"$1"_locimissingness.vcf.gz
}

loci_missing_50 ""
loci_missing_50 "_random"
loci_missing_50 "_target"

# create invariant subset
# switched to bcftools because vcftools was including 811 indels
bcftools view --max-af 0 -V snps,indels,mnps,other -R "$REGIONS" "$INPUT" | bgzip -c > "$OUTDIR/$SPECIES"_SPET_invariant.vcf.gz
bcftools stats "$OUTDIR/$SPECIES"_SPET_invariant.vcf.gz > "$OUTDIR"/statistics/invariant_raw.stats

bcftools view "$OUTDIR/$SPECIES"_SPET_invariant.vcf.gz \
 | bcftools filter -i "(FORMAT/DP>=6)" --set-GTs . \
 | bcftools view -i "(N_PASS(FORMAT/DP>=6)>=$((${SAMPLE_SIZE}/2)))" \
 --output-type z > "$OUTDIR/$SPECIES"_SPET_invariant_filt.vcf.gz
bcftools stats "$OUTDIR/$SPECIES"_SPET_invariant_filt.vcf.gz > "$OUTDIR"/statistics/invariant_filt.stats
tabix "$OUTDIR/$SPECIES"_SPET_invariant_filt.vcf.gz

bcftools view -Oz -R "$RANDOM_REGIONS" "$OUTDIR/$SPECIES"_SPET_invariant_filt.vcf.gz -o "$OUTDIR/$SPECIES"_SPET_invariant_filt_random.vcf.gz
bcftools stats "$OUTDIR/$SPECIES"_SPET_invariant_filt_random.vcf.gz > "$OUTDIR"/statistics/invariant_filt_random.stats
bcftools view -Oz -R "$TARGET_REGIONS" "$OUTDIR/$SPECIES"_SPET_invariant_filt.vcf.gz -o "$OUTDIR/$SPECIES"_SPET_invariant_filt_target.vcf.gz
bcftools stats "$OUTDIR/$SPECIES"_SPET_invariant_filt_target.vcf.gz > "$OUTDIR"/statistics/invariant_filt_target.stats

subset_invar_concat_all() {
	bcftools view -S ^"$OUTDIR"/sample_ids"$1".txt -Oz "$OUTDIR/$SPECIES"_SPET_invariant_filt"$1".vcf.gz  > "$OUTDIR/$SPECIES"_SPET_invariant_sampleFilt"$1".vcf.gz	
	tabix "$OUTDIR/$SPECIES"_SPET_invariant_sampleFilt"$1".vcf.gz
	# combine with invariants vcf
	bcftools concat \
		--allow-overlaps \
		"$OUTDIR"/"$SPECIES"_SNP_sampleFilt"$1""$2".vcf.gz "$OUTDIR"/"$SPECIES"_SPET_invariant_sampleFilt"$1".vcf.gz \
		-O z -o "$OUTDIR"/"$SPECIES"_SPET_allsites_filt"$1""$2".vcf.gz
	tabix "$OUTDIR"/"$SPECIES"_SPET_allsites_filt"$1""$2".vcf.gz
	bcftools stats "$OUTDIR"/"$SPECIES"_SPET_allsites_filt"$1""$2".vcf.gz > "$OUTDIR"/statistics/"$SPECIES"_SPET_allsites_filt"$1""$2".stats
}

subset_invar_concat_all "" ""
subset_invar_concat_all "_random" ""
subset_invar_concat_all "_target" ""
subset_invar_concat_all "" "_locimissingness"
subset_invar_concat_all "_random" "_locimissingness"
subset_invar_concat_all "_target" "_locimissingness"
