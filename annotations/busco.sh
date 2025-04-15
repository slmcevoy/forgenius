#!/bin/bash
#SBATCH --job-name=busco
#SBATCH --output=busco_%j.o
#SBATCH --error=busco_%j.e
#SBATCH --account=project_2009301
#SBATCH --partition=small
#SBATCH --time=24:00:00
#SBATCH --ntasks=1
#SBATCH --mem=100G
#SBATCH --mail-type=END
#SBATCH --cpus-per-task=16


#export PATH=/projappl/project_2009301/software/busco/bin:$PATH
export PATH="/projappl/project_2009301/software/busco2/bin:$PATH"

runbusco() {
	busco -i /users/mcevoysu/scratch/data/"$1"/"$2" -m prot -l "$3" -c 16 -o "$4"
}

#runbusco "Ptabuliformis" "P.tabuliformis_V1.0.gene.final_v2_contig_level.faa"
#runbusco "Tchinensis" "GCA_019776745.2_Ta-2021_protein.faa"
#runbusco "Aalba" "Abal.1_1.pep.fa"
#runbusco "Bpendula" "Betula_pendula_subsp_pendula.pep"
#runbusco "Csativa" "CmollissimaMahoganyHAP1_733_v1.1.protein_primaryTranscriptOnly.fa"
#runbusco "Fsylvatica" "Bhaga_genes_annotated.pep"
#runbusco "Pabies" "Pabies01-gene.pep" "embryophyta_odb10" "Pabies_busco_o"
#runbusco "Pabies" "Pabies01-gene.pep" "busco_downloads/lineages/Gymnosperm_odb10" "Pabies_gymno_busco_o"
#runbusco "Qrobur" "Qrob_PM1N_CDS_aa_20161004.fa" "embryophyta_odb10" "Qrob_busco_o"
#runbusco "Storminalis" "Spohua.protein.fa" "embryophyta_odb10" "Storminalis_busco_o"
#runbusco "Qilex" "Ilex_genome/Ilex_Annotation.chromsfixed.pep" "embryophyta_odb10" "Qilex_busco_o"
#runbusco "Pavium" "Prunus_avium_Tieton.proteins.fixeddups.fa" "embryophyta_odb10" "Pavium_busco_o"
runbusco "Msylvestris" "Msylvestris_haploid_v2.pep.fa" "embryophyta_odb10" "Msylvestris_busco_o"

# https://github.com/jjwujay/Gymnosperm_odb10/blob/main/Gymnosperm_odb10.tar.gz
#busco -i $DIR/$INPUT -m prot -l Gymnosperm_odb10 -c 16 -o $OUTPUT -l busco_downloads/lineages/Gymnosperm_odb10
