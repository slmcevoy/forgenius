#!/bin/bash
#SBATCH --job-name=anno_deg
#SBATCH --output=anno_deg_%j.o
#SBATCH --error=anno_deg_%j.e
#SBATCH --account=project_2009301
#SBATCH --partition=small
#SBATCH --time=24:00:00
#SBATCH --ntasks=1
#SBATCH --mem=300G
#SBATCH --mail-type=END
#SBATCH --cpus-per-task=1
###SBATCH --array=7-12

module load biokit
# NewAnnotateRef.py requires python 2; add python 2.7 to PATH 
export PATH="$PATH:/projappl/project_2009301/bin"

DIR=/users/mcevoysu/scratch
OUTDIR="${DIR}"/output/site_annotation

site_annotation() {
    mkdir -p "$OUTDIR"/"$1"
	python NewAnnotateRefIDfix.py "$DIR"/data/"$1"/"$2" "$DIR"/data/"$1"/"$3" > "$OUTDIR"/"$1"/"$1"_siteannotations.txt
}

# removed CIPR from annotation which fixed error
# genome is huge so split by chromosomes and ran as array
#python NewAnnotateRefIDfix.py "$DIR"/data/Ptabuliformis/Ptab_masked.chr${SLURM_ARRAY_TASK_ID}.fa "$DIR"/data/Ptabuliformis/P.tabuliformis_V1.0.gene.final_v2_contig_level.edited.spetcontigs.chr${SLURM_ARRAY_TASK_ID}.gff3 > "$OUTDIR"/Ptabuliformis/Ptabuliformis_foldannotations.chr${SLURM_ARRAY_TASK_ID}.txt
#python NewAnnotateRefIDfix.py "$DIR"/data/Ptabuliformis/Ptab_masked.tig.fa "$DIR"/data/Ptabuliformis/P.tabuliformis_V1.0.gene.final_v2_contig_level.edited.spetcontigs.tig.gff3 > "$OUTDIR"/Ptabuliformis/Ptabuliformis_foldannotations.tig.txt

# codes in fold-annotated file to use in awk below:
# {'2fold':2, '3fold':2,'intergenic':0 , 'intron':1, 'exon':2, '0fold':3, '4fold':4, '3utr':5, '5utr':6, 'istop':7, 'stop':8, 'unknown':9}

# done
#site_annotation "Bpendula" "Betula_pendula_subsp_pendula.fasta" "Betula_pendula_subsp_pendula.gff3"
#site_annotation "Bpendula" "Betula_pendula_subsp_pendula.fasta" "Betula_pendula_subsp_pendula.cleaned.gff3"
# cleaned 3 spots with orphan CDS in the gff and this file worked
#site_annotation "Bpendula" "Betula_pendula_subsp_pendula.fasta" "Betula_pendula_subsp_pendula.edited.gff"

#site_annotation "Csativa" "CmollissimaMahoganyHAP1_733_v1.0.softmasked.fa" "CmollissimaMahoganyHAP1_733_v1.1.gene_exons.gff3"
#site_annotation "Fsylvatica" "Bhaga_genome.fasta" "Bhaga_genes.cleaned.gff3"
#site_annotation "Storminalis" "Spohua.genome.fa" "Spohua.genome.gff3"
#site_annotation "Qrobur" "Qrob_PM1N.fa" "Qrob_PM1N_genes_20161004.cleaned.gff3"
#site_annotation "Pavium" "Prunus_avium_Tieton.chr.fasta" "Prunus_avium_Tieton.annotation.gff3"
#  cleaning did not improve
#site_annotation "Pavium" "Prunus_avium_Tieton.chr.fasta" "Prunus_avium_Tieton.annotation.cleaned.gff3"
#site_annotation "Msylvestris" "Msylvestris_haploid_v2.chr.fa" "Msylvestris_haploid_v2.gff"
site_annotation "Ptabuliformis" "Ptab_masked.spet_contigs.headerfix.fa" "P.tabuliformis_V1.0.gene.final_v2_contig_level.name_edits.cipr_edits.spet_contigs.gff3"
#site_annotation "Pabies" "Pabies1.0-genome.fa" "Pabies01-gene.gff3"
# TODO
#vcf used split genomes... how to handle this here?
#site_annotation "Tchinensis" "" "GCA_019776745.2_Ta-2021_genomic.gff"
#site_annotation "Qilex" "Ilex_genome/Ilex_genome.fasta" "Ilex_genome/Ilex_Annotation.gff3"
# Aalba...
