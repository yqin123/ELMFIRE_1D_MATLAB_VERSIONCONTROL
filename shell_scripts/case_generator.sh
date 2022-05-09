#!/bin/bash

ERR1=100
ERR2=0
ERR=${ERR1}.${ERR2}

GR[0]=2
GR[1]=3
GR[2]=8
GR[3]=12
GR[4]=20
GR[5]=30
GR[6]=80
GR[7]=120
GR[8]=200
GR[9]=300
GR[10]=800
GR[11]=1200
GR[12]=2000
GR[13]=3000
GR[14]=8000
GR[15]=12000
GR[16]=20000

PIGN=100
DELX=30

printf -v E "%s" ${ERR1}D${ERR2}
printf -v P "%03d" $PIGN
printf -v D "%03d" $DELX
for RATE in ${GR[@]}
do
    printf -v R "%06d" $RATE
    DIR_NAME="G${R}_P${P}_M${D}_ERR${E}"

    echo "Compelling new case!"
    mkdir "$DIR_NAME"
    cp -r G001_P100_M030_ERR${E}/. $DIR_NAME/

    cd $DIR_NAME
    sed -i "s/    ERR = 1 ;/    ERR = $ERR ;/" BATCH_TEST.m
    sed -i "s/    PIGN                     = 100;/    PIGN                     = $PIGN;/" BATCH_TEST.m
    sed -i "s/    NEMBERS_MIN              = 1;/    NEMBERS_MIN              = $RATE;/" BATCH_TEST.m
    sed -i "s/    NEMBERS_MAX              = 1;/    NEMBERS_MAX              = $RATE;/" BATCH_TEST.m
    sed -i "s/    delX          = 5;            % Cell size, m/    delX          = $DELX;            % Cell size, m/" BATCH_TEST.m
    cd ..
done
cd G001_P100_M030_ERR${E}
sed -i "s/    ERR = 1 ;/    ERR = $ERR ;/" BATCH_TEST.m
sed -i "s/    PIGN                     = 100; /    PIGN                     = $PIGN;/" BATCH_TEST.m
sed -i "s/    delX          = 5;            % Cell size, m/    delX          = $DELX;            % Cell size, m/" BATCH_TEST.m
cd ..

GR_0=1
printf -v R "%06d" ${GR_0}
DIR_NAME="G${R}_P${P}_M${D}_ERR${E}"
mv G001_P100_M030_ERR${E} ${DIR_NAME}
