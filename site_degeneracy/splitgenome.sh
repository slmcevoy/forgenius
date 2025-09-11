#!/bin/bash
#SBATCH --job-name=split
#SBATCH --output=split_%j.o
#SBATCH --error=split_%j.e
#SBATCH --account=project_2009301
#SBATCH --partition=small
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --mem=10G
#SBATCH --mail-type=END
#SBATCH --cpus-per-task=1

module load biokit


#for i in {1..12}; do
#	samtools faidx -r /users/mcevoysu/scratch/data/Ptabuliformis/Ptab_masked.contigs_used.length.chr"$i".txt -o /users/mcevoysu/scratch/data/Ptabuliformis/Ptab_masked.chr"$i".fa  /users/mcevoysu/scratch/data/Ptabuliformis/Ptab_masked.fa
#done

samtools faidx -r /users/mcevoysu/scratch/data/Ptabuliformis/Ptab_masked.contigs_used.length.tig.txt -o /users/mcevoysu/scratch/data/Ptabuliformis/Ptab_masked.tig.fa  /users/mcevoysu/scratch/data/Ptabuliformis/Ptab_masked.fa
