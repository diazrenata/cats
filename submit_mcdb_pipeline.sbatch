#!/bin/bash
#SBATCH --job-name=mcdb-cats   # Job name
#SBATCH --mail-type=ALL               # Mail events (NONE, BEGIN, END, FAIL, AL$
#SBATCH --mail-user=diaz.renata@ufl.edu   # Where to send mail
#SBATCH --account=ewhite
#SBATCH --qos=ewhite-b
#SBATCH --ntasks=1                 # Number of MPI ranks
#SBATCH --cpus-per-task=1            # Number of cores per MPI rank
#SBATCH --mem-per-cpu=8GB
#SBATCH --time=24:00:00       #Time limit hrs:min:sec
#SBATCH --output logs/mcdb_pipeline%j.out
#SBATCH --error logs/mcdb_pipeline%j.err

#This is a generic R submission script
module load R
Rscript analysis/mcdb_pipeline.R
