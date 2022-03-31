# ----------------------------------------------------------------------
# Debian container - gcc8.5
# E3SM/ELM land model docker container
# ----------------------------------------------------------------------

FROM fasstsimulation/baseos:gcc850ompi316-latest
LABEL maintainer.name="Shawn P. Serbin" \
      maintainer.email="sserbin@bnl.gov" \
      author.name="Shawn P. Serbin" \
      author.email="sserbin@bnl.gov" \
      description="ELM host land model" \
      version.hlm="v1.2.0_ngeearctic" \
      version.baseos="gcc8.5"

ARG ELM_BRANCH='bsulman/lnd/NGEE-arctic-PFTs3'
RUN echo $ELM_BRANCH

# setting gmake
RUN ln -s /usr/bin/make /usr/bin/gmake

# Setup environment variables.  This is necessary for os.environ calls from case.py in CIME
ENV USER=modeluser

# Add new group, user, and user directory with user permissions
RUN groupadd -r dockerusers \
    && useradd -ms /bin/bash $USER -u 1001 -g dockerusers \
    && chown $USER:dockerusers /home/$USER

## create data mount point in container
## could change this to /mnt or something more generic in machines files
RUN cd / \
    && mkdir -p inputdata \
    && mkdir -p example_inputs \
    && mkdir -p output \
    && mkdir -p scripts \
    && mkdir -p tools \
    && mkdir -p baselines \
    && mkdir -p .cime \
    && mkdir -p home/$USER/.cime \
    && chown $USER inputdata \
    && chown $USER example_inputs \
    && chown $USER output \
    && chown $USER scripts \
    && chown $USER tools \
    && chown $USER baselines \
    && chown $USER .cime \
    && chown $USER /home/$USER/.cime

## Checkout ELM model
RUN echo "*** Checkout ELM model"
RUN cd /
RUN git -c http.sslVerify=false clone -b ${ELM_BRANCH} --single-branch --depth 1 https://github.com/E3SM-Project/E3SM.git \
    && cd /E3SM \
    && git config http.sslVerify false \
    && git log \
    && git branch \
    && sed -i 's|git@github.com:|https://github.com/|g' .gitmodules \
    && git submodule update --init --recursive \
    && cd /.cime \
    && echo $ELM_BRANCH \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/docker/elm/cime_config_ngeearctic/config \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/docker/elm/cime_config_ngeearctic/config_compilers.xml \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/docker/elm/cime_config_ngeearctic/config_machines.xml \
    && cd /home/$USER/.cime \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/docker/elm/cime_config_ngeearctic/config \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/docker/elm/cime_config_ngeearctic/config_compilers.xml \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/docker/elm/cime_config_ngeearctic/config_machines.xml \
    && cd /

# Switch to using modeluser for test build (so it can find the ~/.cime docker machine configuration files)
USER ${USER}
RUN export USER=${USER}

# copy in some example scripts
RUN cd scripts \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/scripts/hlm-fates/elm_run_scripts/1x1pt_US-Brw_test_case_e3sm.sh \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/scripts/hlm-fates/elm_run_scripts/1x1pt_US-Brw_test_case_e3sm_cpl_bypass.sh \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/scripts/hlm-fates/download_elm_singlesite_forcing_data.sh \
    && chmod 775 1x1pt_US-Brw_test_case_e3sm_cpl_bypass.sh \
    && chmod 775 1x1pt_US-Brw_test_case_e3sm.sh \
    && chmod 775 download_elm_singlesite_forcing_data.sh

## Build example case as a test
RUN cd /E3SM/cime/scripts \
    && export CASE_NAME=/output/f19_g16.IGSWCLM45 \
    && cd /E3SM/cime/scripts \
    && ./create_newcase --case ${CASE_NAME} --res f19_g16 --compset IGSWCLM45 --mach docker --compiler gnu \
    && cd ${CASE_NAME} \
    && ./xmlchange DATM_CLMNCEP_YR_END=1995 \
    && ./xmlchange PIO_TYPENAME=netcdf \
    && ./xmlchange RUNDIR=${PWD}/run \
    && ./xmlchange EXEROOT=${PWD}/bld \
    && ./xmlchange NTASKS=1 \
    && ./xmlchange DIN_LOC_ROOT=$PWD \
    && cd ${CASE_NAME} \
    && ./case.setup \
    && ./case.build
    
## Remove test build
RUN cd /output \
    && rm -r /output/f19_g16.IGSWCLM45
## END