#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=40
#SBATCH --partition=hpc
#SBATCH --job-name="mgof14"
#SBATCH --output=log
#SBATCH --error=err

# Load module
#module load python/3.7.8
#module load singularity/3.7.1 


# Run the wf with mini dataset
# ./run_wf.sh -f test_input/wgs-paired-SRR1620013_1.fastq.gz -r test_input/wgs-paired-SRR1620013_2.fastq.gz -n mini_dataset -d MINI_DATASET -s 

# Run the wf with short dataset
# ./run_wf.sh -f test_input/test_1_fwd_HWLTKDRXY_600000.fastq.gz -r test_input/test_2_rev_HWLTKDRXY_600000.fastq.gz -n dev_dataset -d DEV_DATASET -s

# To run the manuscript use cases:
# marine sediment
# ./run_wf.sh -f test_input/DBH_AAAIOSDA_1_1_HMNJKDSX3.UDI224_clean.fastq.gz -r test_input/DBH_AAAIOSDA_1_2_HMNJKDSX3.UDI224_clean.fastq.gz -n DBH_dataset -d marine_sediment_dbh -s

# column water
# ./run_wf.sh -f test_input/DBB_AABVOSDA_1_1_HMNJKDSX3.UDI256_clean.fastq.gz -r test_input/DBB_AABVOSDA_1_2_HMNJKDSX3.UDI256_clean.fastq.gz -n DBB_dataset -d water_column_dbb -s

eval "$(conda shell.bash hook)"
conda activate metagoflow
export DATA_FORWARD="DBH_AAAEOSDA_4_1_HMNJKDSX3.UDI204_clean.fastq.gz"
export DATA_REVERSE="DBH_AAAEOSDA_4_2_HMNJKDSX3.UDI204_clean.fastq.gz"
date
./run_wf.sh -s -b -n run -d UDI204-testing-new \
-f input_data/${DATA_FORWARD} \
-r input_data/${DATA_REVERSE}
date
