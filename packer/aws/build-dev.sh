#!/bin/bash

SCRIPT_DIR=$(dirname $0)

# Functions
#----------------------------------
usage()
{
   echo ""
   echo "Usage build.sh -v <HPCC Version> [-r <regsion> | -i <region file>] [options] -c <codename> -P <gpg passphrase>  "
   echo "   -a <value>: arch: amd64 or x86_64"
   echo "   -c <value>: Linux distro codename. For example, xenial, trusty, el7"
   echo "   -i <value>: region file. One region per line."
   echo "   -n no run. Generate build script only."
   echo "   -p use subnet template for VPC setting."
   echo "   -P GPG passphrase."
   echo "   -r <value>: one region."
   echo "   -s <value>: file_server."
   echo "   -t <value>: amazone ec2 type: instance or ebs."
   echo "   -u <value>: Linux user. 'ubuntu' for Ubuntu and 'centos' for CentOS"
   echo ""
   exit 3
}

configure_file()
{

   echo "Template: ${build_script_in}"
   echo "Generated file ${build_script}" 
   sed "s|@CODENAME@|${codename}|g; \
        s|@ARCH@|${arch}|g; \
        s|@BUILD_TYPE@|${type2}|g; \
        s|@SUBNET_ID@|${subnet_id}|g; \
        s|@BASE_AMI@|${base_ami}|g; \
        s|@USER@|${os_user}|g; \
        s|@AWS_REGION@|${region}|g"   < ${build_script_in} > ${build_script}
}

configure_provision()
{
   sed "s|@RINSIDE_URL@|${RINSIDE_URL}|g; \
        s|@CMAKE_URL@|${CMAKE_URL}|g; \
        s|@GPG_URL@|${GPG_URL}|g; \
        s|@GPG_PASSPHRASE@|${gpg_passphrase}|g"   < ${provision_script}.in > ${provision_script} 
   chmod +x ${provision_script}
}

run_packer_build()
{
  now=$(date -u +%Y%m%d-%H%M)
  log=ami-${region}-log-${now}.log
  num_of_build=$(expr $num_of_build \+ 1)
  build_script=ami-build-json-${region}
  base_ami=$(cat ${wk_dir}/${codename}/base-${type}-ami | grep -v "^#" |  grep ${region} | cut -d' ' -f2)
  subnet_id=$(cat ${wk_dir}/subnet-ids | grep ${region} | cut -d' ' -f2)
  
  configure_file

  [ "$dry_run_only" = "true" ] && return
  
  if [ "$quiet" = "true" ]
  then
     echo "Build for $region with $build_script"
     packer build ${build_script} > $log 2>&1
     rc=$?
  else
     echo ""
     echo "Build for $region with $build_script"
     packer build ${build_script} 2>&1 | tee -a $log ; rc=${PIPESTATUS[0]}

     # To debug usig following. When error happens the instance will be kept in AWS EC2 region instances
     # Use hpcc-build key file ssh to the instance to debug the problem
     #packer build -on-error=abort -debug ${build_script} 2>&1 | tee -a $log ; rc=${PIPESTATUS[0]}
  fi

  if [ ${rc} -eq 0 ] 
  then
     num_of_success=$(expr $num_of_success \+ 1)
     cat $log | tail -n 2 | head -n 1 >> ${ami_list}
  else
     num_of_failure=$(expr $num_of_failure \+ 1)
     echo "${region} $log" >> $err_file_list
  fi

}

# Variables
#----------------------------------
arch=amd64
codename=
type=ebs
build_script=aws-build.json
region_file=
err_file_list=log_list
quiet=false
file_server=10.240.32.242

wk_dir=
gpg_passphrase=
os_user=ubuntu

num_of_failure=0
num_of_success=0
num_of_build=0
dry_run_only=false
use_subnet=false
log=

# Parse input parameters
#----------------------------------
while getopts "*a:c:d:i:npP:qr:s:t:v:u:" arg
do
    case "$arg" in
       a) arch="$OPTARG"
          ;;
       c) codename="$OPTARG"
          ;;
       i) region_file="$OPTARG"
          ;;
       n) dry_run_only=true
          ;;
       p) use_subnet=true
          ;;
       P) gpg_passphrase="$OPTARG"
          ;;
       q) quiet=true
          ;;
       r) region="$OPTARG"
          ;;
       s) file_server="$OPTARG"
          ;;
       t) type="aws_$OPTARG"
          ;;
       u) os_user="$OPTARG"
          ;;
       ?) usage
          ;;
    esac
done

if [ -z "$gpg_passphrase" ]
then
  echo "Missing GPG passphrase"
  usage
fi

RINSIDE_URL="http://${file_server}/data3/software/R"
GPG_URL="http://${file_server}/data3/build/gpg"
CMAKE_URL="http://${file_server}/data3/software/cmake"

# Check variables
#----------------------------------
[ -z "${wk_dir}" ] && wk_dir=${SCRIPT_DIR}

if [ -z ${codename} ]
then
   echo "Miss Linux codename. For example  xenial, el7, etc." 
   exit 1
fi

if [ -z ${region} ] && [ -z ${region_file} ] 
then
   echo "Miss region. Provide either region with -r or region list file with -i." 
   exit 1
fi

if [ "$use_subnet" = "true" ]
then
   build_script_in=${wk_dir}/${type}/aws-hpcc-dev-build-vpc.json.in
else
   build_script_in=${wk_dir}/${type}/aws-hpcc-dev-build.json.in
fi


if [ ! -e ${build_script_in} ]
then
   echo "Cannot find build script template ${build_script_in}" 
   exit 1
fi

ami_list="ami_dev_${type}_${arch}"

type2="amazon-$type"
provision_script="hpcc-dev-${codename}-${arch}.sh"
cp ${wk_dir}/${codename}/${provision_script}.in .

configure_provision

if [ -e ${ami_list} ]
then
  rm -rf  ${ami_list}
fi

[ -e ${err_file_list} ] && rm -rf ${err_file_list}

# Build AMI 
#----------------------------------
if [ -n "$region" ] 
then
   run_packer_build
else
  if [ ! -e ${region_file} ]
  then
     echo "Region file $region_file doesn't exists"
     exit 1
  fi

  for line in $(cat ${region_file} )
  do 
    line=$(echo $line | sed 's/[[:space:]]//g')
    [[ $line == \#* ]] && continue
    region=$(echo $line | cut -d' ' -f1 )
    run_packer_build 
  done

fi

[ "$dry_run_only" = "true" ] && exit 0

# Summary
#----------------------------------
echo ""
echo "  Total number of region build: $num_of_build"
echo "  Total number of sucess      : $num_of_success"
echo "  Total number of failure     : $num_of_failure"
echo ""

if [ ${num_of_failure} -gt 0 ]
then
   echo "Error logs:"
   cat ${err_file_list}
   echo ""
fi

if [ ${num_of_success} -gt 0 ]
then
  echo "Generated AMI list:"
  cat ${ami_list}
  echo ""
fi

# End
#----------------------------------
