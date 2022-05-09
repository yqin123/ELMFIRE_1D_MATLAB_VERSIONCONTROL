for file in ./*
do
    if test -f $file
    then
        echo $file File
    else
        echo $file Dir
        cd $file
        sbatch -A filmcool-hi batch_run.sh
        cd ..
    fi
done