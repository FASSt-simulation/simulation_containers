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
    && mkdir -p ctsm_example_data \
    && mkdir -p ctsm_output \
    && mkdir -p scripts \
    && mkdir -p tools \
    && mkdir -p baselines \
    && mkdir -p .cime \
    && mkdir -p home/$USER/.cime \
    && chown $USER inputdata \
    && chown $USER data \
    && chown $USER ctsm_example_data \
    && chown $USER ctsm_output \
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
    && mkdir -p ctsm_run_scripts \
    && cd ctsm_run_scripts \
    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/ctsm_run_scripts/create_case_1pt_example_USNR1.sh \
    && chmod 775 create_case_1pt_example_USNR1.sh \
    && cd /.cime \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/docker/ctsm/cime_config/config \ 
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/docker/ctsm/cime_config/config_compilers.xml \
    && wget https://raw.githubusercontent.com/FASSt-simulation/simulation_containers/main/docker/ctsm/cime_config/config_machines.xml

## Create US-NR1 example data directory
RUN cd / \
    && cd ctsm_example_data \
    && wget https://github.com/serbinsh/ctsm_containers/raw/master/ctsm_example_data/USNR1/USNR1_CTSM_Example_Data.tar.gz \
    && tar -zxvf USNR1_CTSM_Example_Data.tar.gz \
    && rm USNR1_CTSM_Example_Data.tar.gz

## Create tools directory for helper functions
#RUN cd / \
#    && cd tools \
#    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/tools/create_single_point/python3/config.cfg \
#    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/tools/create_single_point/create_GSWP3.0.5d.v1_single_point_forcing_data.py \
#    && chmod 775 config.cfg \
#    && chmod 775 create_GSWP3.0.5d.v1_single_point_forcing_data.py

## setup clmuser to use with docker
RUN export USER=$USER

### EOF