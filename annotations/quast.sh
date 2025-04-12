#!/bin/bash
#SBATCH --job-name=quast
#SBATCH --output=quast_%j.o
#SBATCH --error=quast_%j.e
#SBATCH --account=project_2009301
#SBATCH --partition=small
#SBATCH --time=24:00:00
#SBATCH --ntasks=1
#SBATCH --mem=100G
#SBATCH --mail-type=END
#SBATCH --cpus-per-task=16

module load quast/5.2.0

runquast() {
	python /appl/soft/bio/quast/quast-5.2.0/bin/quast.py --large -o "$1"_quast_o /users/mcevoysu/scratch/data/"$1"/"$2"
}

#runquast "Phalepensis" "reference_ptabuliformis_masked/Ptab_masked.fa"
#runquast "Tbaccata" "genome/GCA_019776745.2_Ta-2021_genomic.fna"
#runquast "Bpendula" "Betula_pendula_subsp_pendula.fasta"
#runquast "Csativa" "CmollissimaMahoganyHAP1_733_v1.0.softmasked.fa"
#runquast "Fsylvatica" "Bhaga_genome.fasta"
#runquast "Fexcelsior" "FRAX_001_PL_genomic.fasta"
#runquast "Pabies" "Pabies1.0-genome.fa"

#runquast "Qilex" "Ilex_genome/Ilex_genome.fasta"
#runquast "Qrobur" "Qrob_PM1N.fa"
#runquast "Storminalis" "Spohua.genome.fa"
runquast "Pavium" "Prunus_avium_Tieton.chr.fasta"
