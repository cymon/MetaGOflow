#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=40
#SBATCH --partition=hpc
#SBATCH --job-name="mgfI4"
#SBATCH --output=log-mgfI4
#SBATCH --error=err-mgfI4

eval "$(conda shell.bash hook)"
conda activate metagoflow
export DATA_FORWARD="DBH_AAAOOSDA_1_1_HMNJKDSX3.UDI260_clean.fastq.gz"
export DATA_REVERSE="DBH_AAAOOSDA_1_2_HMNJKDSX3.UDI260_clean.fastq.gz"
date
./run_wf.sh -s -b -n run -d UDI260-testing-mgfI1 \
-f input_data/${DATA_FORWARD} \
-r input_data/${DATA_REVERSE}
date
