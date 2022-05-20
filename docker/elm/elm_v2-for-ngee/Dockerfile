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

# where to get the ELM source code
ENV REPOSITORY_URL=https://github.com/FASSt-simulation/simulation_containers
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
## https://www.geeksforgeeks.org/docker-copy-instruction/
#COPY --chown=modeluser:dockerusers ./e3sm_source/e3sm_v2.0.0.tar.gz /.
RUN wget $REPOSITORY_URL/raw/main/docker/elm/elm_v2-for-ngee/e3sm_source/e3sm_v2.0.0_ngee.tar.gz 
RUN tar -zxvf e3sm_v2.0.0_ngee.tar.gz \
    && rm e3sm_v2.0.0_ngee.tar.gz \
    && cd /E3SM \
    && git log \
    && git branch \
    && cd /.cime \
    && echo $ELM_BRANCH \
    && wget $REPOSITORY_URL/main/docker/elm/cime_config/config \
    && wget $REPOSITORY_URL/main/docker/elm/cime_config/config_compilers.xml \
    && wget $REPOSITORY_URL/main/docker/elm/cime_config/config_machines.xml \
    && cd /home/$USER/.cime \
    && wget $REPOSITORY_URL/main/docker/elm/cime_config/config \
    && wget $REPOSITORY_URL/main/docker/elm/cime_config/config_compilers.xml \
    && wget $REPOSITORY_URL/main/docker/elm/cime_config/config_machines.xml \
    && cd /

# Provide a symlink between ncap and ncap2 for OLMT 
# Switch to using modeluser for test build (so it can find the ~/.cime docker machine configuration files)
RUN ln -s /usr/bin/ncap2 /usr/bin/ncap \
    && chown $USER:dockerusers /E3SM \
    && chmod -R 777 /E3SM \
    && USER ${USER} \
    && export USER=${USER}

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

## Install OLMT tool into the container to use with site or ensemble simulations
RUN cd /tools \
    && git -c http.sslVerify=false clone -b Arctic-userpft --single-branch --depth 1 https://github.com/FASSt-simulation/OLMT.git \
    && chown $USER:dockerusers -R /tools/OLMT \
    && chmod -R 777 /tools/OLMT

USER ${USER}
RUN export USER=${USER}
## END