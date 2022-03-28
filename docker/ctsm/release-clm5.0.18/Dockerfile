# ----------------------------------------------------------------------
# Debian container
# CTSM land model docker container
# ----------------------------------------------------------------------

FROM fasstsimulation/baseos:gcc650ompi316-latest
LABEL maintainer.name="Shawn P. Serbin" \
      maintainer.email="sserbin@bnl.gov" \
      author.name="Shawn P. Serbin" \
      author.email="sserbin@bnl.gov" \
      description="CTSM host land model" \
      version.hlm="release-clm5.0.18" \
      version.baseos="gcc6.5"

# setting gmake
RUN ln -s /usr/bin/make /usr/bin/gmake

# Setup environment variables.  This is necessary for os.environ calls from case.py in CIME
ENV USER=modeluser

# Add user directory structure.  This is necessary for CIME
RUN useradd -ms /bin/bash $USER -u 9001
RUN echo "export USER=${USER}" > /etc/environment

ARG CTSM_BRANCH='release-clm5.0.18'
RUN echo $CTSM_BRANCH

## create data mount point in container
## could change this to /mnt or something more generic in machines files
RUN cd / \
    && mkdir -p inputdata \
    && mkdir -p data \
    && mkdir -p example_inputs \
    && mkdir -p output \
    && mkdir -p scripts \
    && mkdir -p tools \
    && mkdir -p baselines \
    && mkdir -p .cime \
    && mkdir -p home/$USER/.cime \
    && chown $USER inputdata \
    && chown $USER data \
    && chown $USER example_inputs \
    && chown $USER output \
    && chown $USER scripts \
    && chown $USER tools \
    && chown $USER baselines \
    && chown $USER .cime \
    && chown $USER /home/$USER/.cime

## Checkout CTSM model
RUN echo "*** Checkout CTSM model"
RUN cd / \
    && git -c http.sslVerify=false clone -b ${CTSM_BRANCH} --single-branch --depth 1 https://github.com/ESCOMP/ctsm.git \
    && cd ctsm \
    && git tag \
    && ./manage_externals/checkout_externals \
    && cd / \
    && mkdir -p ctsm_parameter_files \
    && cd ctsm_parameter_files \
    && wget --no-check-certificate https://svn-ccsm-inputdata.cgd.ucar.edu/trunk/inputdata/lnd/clm2/paramdata/clm5_params.c171117.nc \
    && cd / \
    && cd scripts \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/scripts/hlm-fates/run_scripts/create_case_1pt_example_USNR1.sh \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/scripts/hlm-fates/run_scripts/ctsm_docker_1x1brazil.sh \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/scripts/hlm-fates/run_scripts/output_vars.txt \
    && chmod 775 create_case_1pt_example_USNR1.sh \
    && chmod 775 ctsm_docker_1x1brazil.sh \
    && chmod 775 output_vars.txt \
    && cd /.cime \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/docker/ctsm/cime_config/config \ 
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/docker/ctsm/cime_config/config_compilers.xml \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/docker/ctsm/cime_config/config_machines.xml

## Create US-NR1 example data directory
RUN cd / \
    && cd example_inputs \
    && wget https://github.com/FASSt-simulation/simulation_containers/raw/main/example_inputs/USNR1_CTSM_Example_Data.tar.gz \
    && tar -zxvf USNR1_CTSM_Example_Data.tar.gz \
    && rm USNR1_CTSM_Example_Data.tar.gz

## setup clmuser to use with docker
RUN export USER=$USER

### EOF