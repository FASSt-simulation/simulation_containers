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

ARG ELM_BRANCH='v2.0.0'
RUN echo $ELM_BRANCH

# setting gmake
RUN ln -s /usr/bin/make /usr/bin/gmake

# Download public key for github.com
RUN mkdir ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

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

## Checkout ELM model
RUN echo "*** Checkout ELM model"
RUN cd /
RUN --mount=type=ssh git clone -b ${ELM_BRANCH} --single-branch --depth 1 https://github.com/E3SM-Project/E3SM.git \
    && cd /E3SM \
    && git submodule update --init --recursive \
    && git tag
#    && chown -R $USER:dockerusers /home/$USER/E3SM && \


git -c http.sslVerify=false clone -b ${ELM_BRANCH} --single-branch --depth 1 https://github.com/E3SM-Project/E3SM.git

sed -i 's|git@github.com:|https://github.com/|g' .gitmodules

git config --global ssh.sslVerify false
git submodule update --init --recursive