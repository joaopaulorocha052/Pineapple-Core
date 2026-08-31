#! /bin/bash


ImageFilePath=./init.txt
NewImagePath=$1

cp "$NewImagePath" ../"$ImageFilePath"


if [[$2 == "-d"]]; then
    Revision="Pinapple-Core_DEBUG"
else
    Revision="Pineapple-Core"
fi

cd ..
quartus_sh --set_global_assignment -name FAMILY "Cyclone IV E"
quartus_sh --flow compile Pineapple-Core -c "$Revision"

