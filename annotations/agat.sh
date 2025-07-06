#!/bin/bash
#SBATCH --job-name=agat
#SBATCH --output=agat_%j.o
#SBATCH --error=agat_%j.e
#SBATCH --account=project_2009301
#SBATCH --partition=small
#SBATCH --time=24:00:00
#SBATCH --ntasks=1
#SBATCH --mem=40G
#SBATCH --mail-type=END
#SBATCH --cpus-per-task=1

export PATH=/projappl/project_2010526/software/agat/bin:$PATH

DATADIR=/users/mcevoysu/scratch/data
OUTDIR=/users/mcevoysu/scratch/output

runagat() {
	agat_sp_statistics.pl -gff "$DATADIR"/"$1"/"$2" -o "$1"_gff_stats.txt
}

makeproteins() {
	fname=$(basename "$2" .gff3)
	agat_sp_extract_sequences.pl -g "$DATADIR"/"$1"/"$2" -f "$DATADIR"/"$1"/"$3" -t cds -p -o "$DATADIR"/"$1"/"$fname".pep
}

standardizeannotation() {
	f="${2##*/}"
	fname="${f%.*}"
	agat_convert_sp_gxf2gxf.pl -g "$DATADIR"/"$1"/"$2" -o "$DATADIR"/"$1"/"$fname".cleaned.gff3
}

#standardizeannotation "Bpendula" "Betula_pendula_subsp_pendula.gff"
#standardizeannotation "Qrobur" "Qrob_PM1N_genes_20161004.gff"
#standardizeannotation "Pavium" "Prunus_avium_Tieton.annotation.gff3"
standardizeannotation "Fsylvatica" "Bhaga_genes.gff3"

#runagat "Ptabuliformis" "P.tabuliformis_V1.0.gene.final_v2_contig_level.name_edits.gtf"
#runagat "Tchinensis" "GCA_019776745.2_Ta-2021_genomic.gtf"
#runagat "Aalba" "Abal.1_1.gtf"
#runagat "Bpendula" "Betula_pendula_subsp_pendula.gff"
#runagat "Csativa" "CmollissimaMahoganyHAP1_733_v1.1.gene_exons.gff3"
#runagat "Fsylvatica" "Bhaga_genes.gff3"
#runagat "Pabies" "Pabies01-gene.gff3"
#runagat "Qrobur" "Qrob_PM1N_genes_20161004.gff"
#runagat "Storminalis" "Spohua.genome.gff3"
#runagat "Qilex" "Ilex_genome/Ilex_Annotation.gff3"
#runagat "Pavium" "Prunus_avium_Tieton.annotation.gff3"
#runagat "Msylvestris" "Msylvestris_haploid_v2.gff"

#makeproteins "Bpendula" "Betula_pendula_subsp_pendula.gff" "Betula_pendula_subsp_pendula.fasta"
#makeproteins "Pabies" "Pabies01-gene.gff3" "Pabies1.0-genome.fa"
#makeproteins "Qilex" "Ilex_genome/Ilex_Annotation.chromsfixed.gff3" "Ilex_genome/Ilex_genome.fasta"

