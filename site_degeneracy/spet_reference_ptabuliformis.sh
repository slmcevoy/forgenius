#!/bin/bash
#SBATCH --job-name=anno_deg
#SBATCH --output=anno_deg_%j.o
#SBATCH --error=anno_deg_%j.e
#SBATCH --account=project_2009301
#SBATCH --partition=small
#SBATCH --time=03:00:00
#SBATCH --ntasks=1
#SBATCH --mem=50G
#SBATCH --mail-type=END
#SBATCH --cpus-per-task=1
###SBATCH --array=7-12

module load biokit
#module load bedtools

PTABDIR=/users/mcevoysu/scratch/data/Ptabuliformis/

# Ptab_masked.spet_contigs.length.txt has 5058 contigs
#samtools faidx -r $PTABDIR/Ptab_masked.spet_contigs.length.txt  -o $PTABDIR/Ptab_masked.spet_contigs.fa $PTABDIR/Ptab_masked.fa

grep -Ff $PTABDIR/ptab_spet_contigs.txt $PTABDIR/P.tabuliformis_V1.0.gene.final_v2_contig_level.name_edits.cipr_edits.gff3 > $PTABDIR/P.tabuliformis_V1.0.gene.final_v2_contig_level.name_edits.cipr_edits.spet_contigs.gff3

# 'edited' gff3 has had 'CPIR1' removed from gene features last column
#bedtools intersect -wa -a $PTABDIR/P.tabuliformis_V1.0.gene.final_v2_contig_level.edited.gff3 -b $PTABDIR/phalepensis_pinusnigra_regions.bed > $PTABDIR/P.tabuliformis_V1.0.gene.final_v2_contig_level.edited.spet_regions.gff3

#cat $PTABDIR/../Phalepensis/phalepensis_random_regions.txt $PTABDIR/../Phalepensis/phalepensis_target_regions.txt $PTABDIR/../Pinusnigra/Pinus_nigra_random_regions.txt $PTABDIR/../Pinusnigra/Pinus_nigra_target_regions.txt | sort -k1,1 -k2,2n - | sed 's/	/:/' - | sed 's/	/-/' > $PTABDIR/Ptab_masked.spet_regions.length.txt

#cat $PTABDIR/../Phalepensis/phalepensis_random_regions.txt $P	TABDIR/../Phalepensis/phalepensis_target_regions.txt $PTABDIR/../Pinusnigra/Pinus_nigra_random_regions.txt $PTABDIR/../Pinusnigra/Pinus_nigra_target_regions.txt > ptab_regions.txt
#awk 'BEGIN {OFS="\t"}{print $1, "1", $3}' ptab_regions.txt > ptab_regions.1s.txt
#sort -k1,1 -k3,3nr ptab_regions.1s.txt > ptab_regions.1s.sorted.txt
#awk 'FNR==NR { array[$0]++; next } $1 in array { print; delete array[$1] }' /users/mcevoysu/scratch/data/Ptabuliformis/ptab_contigs_used.txt ptab_regions.1s.sorted.txt > ptab_regions.1s.sorted.unique.txt
#sed 's/	/:/' ptab_regions.1s.sorted.unique.txt | sed 's/	/-/' -  > $PTABDIR/Ptab_masked.spet_contigs.1-endofregions.txt

#samtools faidx -r $PTABDIR/Ptab_masked.spet_contigs.1-endofregions.txt -o $PTABDIR/Ptab_masked.spet_contigs.1-endofregions.fa  $PTABDIR/Ptab_masked.fa

# NewAnnotateRef.py requires python 2; add python 2.7 to PATH 
#export PATH="$PATH:/projappl/project_2009301/bin"

#DIR=/users/mcevoysu/scratch
#OUTDIR="${DIR}"/output/site_annotation



# removed CIPR from annotation which fixed error
# genome is huge so split by chromosomes and ran as array
#python NewAnnotateRefIDfix.py "$DIR"/data/Ptabuliformis/Ptab_masked.chr${SLURM_ARRAY_TASK_ID}.fa "$DIR"/data/Ptabuliformis/P.tabuliformis_V1.0.gene.final_v2_contig_level.edited.spetcontigs.chr${SLURM_ARRAY_TASK_ID}.gff3 > "$OUTDIR"/Ptabuliformis/Ptabuliformis_foldannotations.chr${SLURM_ARRAY_TASK_ID}.txt
#python NewAnnotateRefIDfix.py "$DIR"/data/Ptabuliformis/Ptab_masked.tig.fa "$DIR"/data/Ptabuliformis/P.tabuliformis_V1.0.gene.final_v2_contig_level.edited.spetcontigs.tig.gff3 > "$OUTDIR"/Ptabuliformis/Ptabuliformis_foldannotations.tig.txt

