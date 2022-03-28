# ----------------------------------------------------------------------
# Debian container
# CTSM land model docker container
# ----------------------------------------------------------------------

FROM fasstsimulation/baseos:gcc850ompi316-latest
LABEL maintainer.name="Shawn P. Serbin" \
      maintainer.email="sserbin@bnl.gov" \
      author.name="Shawn P. Serbin" \
      author.email="sserbin@bnl.gov" \
      description="ELM host land model" \
      version.hlm="v2.0.0" \
      version.baseos="gcc8.5"

ARG ELM_BRANCH='v1.0.0'
RUN echo $ELM_BRANCH

# setting gmake
RUN ln -s /usr/bin/make /usr/bin/gmake

# Download public key for github.com
#RUN mkdir ~/.ssh && \
#    ssh-keyscan github.com >> ~/.ssh/known_hosts

# Setup environment variables.  This is necessary for os.environ calls from case.py in CIME
ENV USER=modeluser

# Add user directory structure.  This is necessary for CIME
#RUN useradd -ms /bin/bash $USER -u 9001
#RUN echo "export USER=${USER}" > /etc/environment

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
    && git tag \
    && sed -i 's|git@github.com:|https://github.com/|g' .gitmodules \
    && git submodule update --init --recursive \
    && cd /.cime \
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

# copy in some example scripts
RUN cd scripts \
    && wget https://raw.githubusercontent.com/serbinsh/elm_containers/master/elm_run_scripts/basic_f19_g16_ICLM45_test_case.sh \
    && chmod 775 basic_f19_g16_ICLM45_test_case.sh

## Build example case as a test
RUN cd /E3SM/cime/scripts \
#    && echo $(head -1 /etc/hosts | cut -f1) docker >> /etc/hosts \
    && ./create_newcase --case /output/f19_g16.ICLM45 --res f19_g16 --compset ICLM45 --mach docker --compiler gnu \
    && cd /output/f19_g16.ICLM45 \
    && ./xmlchange DATM_CLMNCEP_YR_END=1972 \
    && ./xmlchange PIO_TYPENAME=netcdf \
    && ./xmlchange RUNDIR=${PWD}/run \
    && ./xmlchange EXEROOT=${PWD}/bld \
    && ./xmlchange NTASKS=1 \
    && ./xmlchange DIN_LOC_ROOT=$PWD \
    && cd /output/f19_g16.ICLM45 \
    && ./case.setup
    #&& ./case.build

## Remove test build
RUN cd /output \
    && rm -r f19_g16.ICLM45/