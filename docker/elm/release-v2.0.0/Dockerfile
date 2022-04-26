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
      version.hlm="v2.0.0" \
      version.baseos="gcc8.5"

ARG ELM_BRANCH='v2.0.0'
RUN echo $ELM_BRANCH

# setting gmake - not sure we need this
#RUN ln -s /usr/bin/make /usr/bin/gmake

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
    && mkdir -p tools/cprnc \
    && mkdir -p baselines \
    && mkdir -p .cime \
    && mkdir -p home/$USER/.cime \
    && chown $USER inputdata \
    && chown $USER example_inputs \
    && chown $USER output \
    && chown $USER scripts \
    && chown $USER tools \
    && chown $USER tools/cprnc \
    && chown $USER baselines \
    && chown $USER .cime \
    && chown $USER /home/$USER/.cime \
    && cd /

## Checkout ELM model
## /root/.cime/config_machines.xml
## For now, copy in source code instead of pulling into container; issues with github ssh and submodules
RUN echo "*** Copy in ELM v2.0.0"
## https://www.geeksforgeeks.org/docker-copy-instruction/
#COPY --chown=modeluser:dockerusers ./e3sm_source/e3sm_v2.0.0.tar.gz /.
RUN wget https://github.com/FASSt-simulation/simulation_containers/raw/main/docker/elm/release-v2.0.0/e3sm_source/e3sm_v2.0.0.tar.gz 
RUN tar -zxvf e3sm_v2.0.0.tar.gz \
    && rm e3sm_v2.0.0.tar.gz \
    && cd /E3SM \
    && git log \
    && git branch \
    && cd /.cime \
    && echo $ELM_BRANCH \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/docker/elm/cime_config/config \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/docker/elm/cime_config/config_compilers.xml \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/docker/elm/cime_config/config_machines.xml \
    && cd /home/$USER/.cime \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/docker/elm/cime_config/config \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/docker/elm/cime_config/config_compilers.xml \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/docker/elm/cime_config/config_machines.xml \
    && cd /

# Switch to using modeluser for test build (so it can find the ~/.cime docker machine configuration files)
USER ${USER}
RUN export USER=${USER}

## Build example case as a test
RUN cd /E3SM/cime/scripts \
    && export CASE_NAME=/output/f19_g16.IGSWELMBGC \
    && cd /E3SM/cime/scripts \
    && ./create_newcase --case ${CASE_NAME} --res f19_g16 --compset IGSWELMBGC --mach docker --compiler gnu \
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

RUN echo "*** ELM test build completed successfully ***"

## Remove test build
RUN cd / \
    && rm -rf /output/f19_g16.IGSWELMBGC
## END