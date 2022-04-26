#!/bin/bash

# =======================================================================================
# ELM create_newcase template for docker container
# --- This example builds a basic single-site case using default GSWP3 met forcing,
#     created using interim met forcing script "create_GSWP3.0.5d.v1_single_point_forcing_data.py"
# --- User selectable options are provided below
# 
# ELM version: 2.0.0
#
# Example usage:
#./create_newcase_elm_1pt_custom_site.sh --case_root=/output \
#--site_name=US-xTA --start_year='1985-01-01' --num_years=6 \
#--output_vars=output_vars.txt --met_start=1985 --met_end=2015 \
#--resolution=0.9x1.25 --compset=IGSWELMBGC
#
# Script details:
# =======================================================================================

echo $PWD

# =======================================================================================
# get the user inputs
for i in "$@"
do
case $i in
    -ms=*|--model_source=*)
    model_source="${i#*=}"
    shift
    ;;
    -cr=*|--case_root=*)
    case_root="${i#*=}"
    shift # past argument=value
    ;;
    -sn=*|--site_name=*)
    site_name="${i#*=}"
    shift # past argument=value
    ;;
    -sy=*|--start_year=*)
    start_year="${i#*=}"
    shift # past argument=value
    ;;
    -ny=*|--num_years=*)
    num_years="${i#*=}"
    shift # past argument=value
    ;;
    -ov=*|--output_vars=*)
    output_vars="${i#*=}"
    shift # past argument=value
    ;;
    -rt=*|--run_type=*)
    run_type="${i#*=}"
    shift # past argument=value
    ;;
    -so=*|--stop_option=*)
    stop_option="${i#*=}"
    shift # past argument=value
    ;;
    -mets=*|--met_start=*)
    met_start="${i#*=}"
    shift # past argument with no value
    ;;
    -mete=*|--met_end=*)
    met_end="${i#*=}"
    shift # past argument with no value
    ;;
    -com=*|--compset=*)
    compset="${i#*=}"
    shift # past argument with no value
    ;;
    -res=*|--resolution=*)
    resolution="${i#*=}"
    shift # past argument with no value
    ;;
    *)
          # unknown option
    ;;
esac
done
# =======================================================================================

# =======================================================================================
# check for missing inputs and set defaults
model_source="${model_source:-/E3SM}"
case_root="${case_root:-/output}"
site_name="${site_name:-US-xTA}"
start_year="${start_year:-'1985-01-01'}"
num_years="${num_years:-5}"
output_vars="${output_vars:-/scripts/output_vars.txt}"
run_type="${run_type:-startup}"
stop_option="${stop_option:-nyears}"
# add rest options here too
met_start="${met_start:-1985}"
met_end="${met_end:-2015}"
resolution="${resolution:-0.9x1.25}"
compset="${compset:-IGSWELMBGC}"

# get the desired output vars from the file
out_vars=$(cat "$output_vars")
out_vars="${out_vars//\\/}"

echo "Selected output variables: "${out_vars}
echo " "
echo " "
# =======================================================================================

# =======================================================================================
# DEFAULT OUTPUT VARIABLES - USED IF NOT SET AS A FLAG
default_vars='NEP','GPP','NPP','AR','HR','AGB','TLAI','ALBD','QVEGT',\
'EFLX_LH_TOT','WIND','ZBOT','RH','TBOT','PBOT','QBOT','RAIN','FSR','FSDS','FLDS'
# =======================================================================================

# =======================================================================================
# Create a new case
export MODEL_SOURCE=${model_source}
export date_var=$(date +%s)
export CASEROOT=${case_root}
export SITE_NAME=${site_name}
export MODEL_VERSION=ELM
export RESOLUTION=${resolution}
export COMPSET=${compset}
export CASE_NAME=${CASEROOT}/${SITE_NAME}.${MODEL_VERSION}.${COMPSET}.${date_var}

cd /E3SM/cime/scripts
./create_newcase --case ${CASE_NAME} --res ${RESOLUTION} --compset ${COMPSET} --mach docker --compiler gnu
cd ${CASE_NAME}
# =======================================================================================


# =======================================================================================
# Define forcing and surfice file data for run:
export datmdata_dir=${datm_data_root}/datmdata/atm_forcing.datm7.GSWP3.0.5d.v1.c170516
echo "DATM forcing data directory:"
echo ${datmdata_dir}

pattern=${datmdata_dir}/"domain.lnd.360x720_*"
datm_domain_lnd=( $pattern )
echo "DATM land domain file:"
echo "${datm_domain_lnd[0]}"
export CLM5_DATM_DOMAIN_LND=${datm_domain_lnd[0]}

pattern=${datm_data_root}/"domain.lnd.fv${resolution}*"
domain_lnd=( $pattern )
echo "Land domain file:"
echo "${domain_lnd[0]}"
export CLM5_USRDAT_DOMAIN=${domain_lnd[0]}

pattern=${datm_data_root}/"surfdata_${resolution}_78pfts*"
surfdata=( $pattern )
echo "Surface file:"
echo "${surfdata[0]}"
export CLM5_SURFDAT=${surfdata[0]}
# =======================================================================================