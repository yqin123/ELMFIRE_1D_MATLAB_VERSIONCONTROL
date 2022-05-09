#!/bin/tcsh
#SBATCH -n 20
#SBATCH -N 1
#SBATCH -t 1000

module load matlab

matlab -nodisplay -nosplash -r "BATCH_TEST; exit" > BATCH_TEST.out

tar -czvf results.tar.gz main_result ember_result prop_log
rm -r main_result ember_result prop_log
mv results.tar.gz `pwd`.tar.gz
