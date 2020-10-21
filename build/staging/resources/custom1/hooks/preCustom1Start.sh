#!/bin/bash
ROOT_DIR=/home/vcap/app/
export APPNAME=`echo ${VCAP_APPLICATION} | sed -e 's/,\"/&\n\"/g;s/\"//g;s/,//g'| grep application_name | cut -d: -f2`
echo "PreCustom1Start script is in $ROOT_DIR"
SCRIPT_DIR=`pwd`


mkdir /home/vcap/opt
cp /home/vcap/app/APP-INF/.wls/custom1/wlsec/lib/*.tgz /home/vcap/opt
echo "Copied tar balls into/home/vcap/opt"
cd /home/vcap/opt
for i in `ls *.tgz`
do
  tar -zxvf $i 2>/dev/null
done
export DR_CUSTOM1_TYPE1=/home/vcap/opt/custom1_type1
source /home/vcap/opt/custom1_type1/setenv.sh
echo "Sourced custom1_type1 env script..."
export DR_CUSTOM1_TYPE2=/home/vcap/opt/custom1_type2
source /home/vcap/opt/custom1_type2/setenv.sh
echo "Sourced DR_CUSTOM1_TYPE2 env script..."
source $ROOT_DIR/csCommon.sh
# kick off some functions...
env
source $ROOT_DIR/custom1Start.sh
echo "Sourced custom1Start env script..."

cd $SCRIPT_DIR