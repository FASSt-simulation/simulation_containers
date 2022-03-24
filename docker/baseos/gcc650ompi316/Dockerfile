# ----------------------------------------------------------------------
# Debian baseOS docker container to use with CTSM/ELM builds
# ----------------------------------------------------------------------

FROM gcc:6.5

LABEL maintainer.name="Shawn P. Serbin" \
      maintainer.email="sserbin@bnl.gov" \
      author.name="Shawn P. Serbin" \
      author.email="sserbin@bnl.gov" \
      description="GCC-based image loaded with necessary dependencies for building HLM/HLM-FATES images"

# Set a few variables that can be used to control the docker build
ARG OPENMPI_VERSION=3.1.6
ARG HDF5_VERSION=1.12.1
ARG NETCDF_VERSION=4.8.1
ARG NETCDF_FORTRAN_VERSION=4.5.4

# echo back options
RUN echo $NCPUS
RUN echo $OPENMPI_VERSION
RUN echo $HDF5_VERSION
RUN echo $NETCDF_VERSION
RUN echo $NETCDF_FORTRAN_VERSION

ENV PATH=/usr/local/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH
ENV PATH=/usr/local/hdf5/bin:$PATH
ENV PATH=/usr/local/netcdf/bin:$PATH
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/hdf5/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/netcdf/lib

# Update the system and install initial dependencies
RUN apt-get update -y \
    && apt-get install -y \
    cmake \
    git \
    subversion \
    bzip2 \
    libgmp3-dev \
    m4 \
    wget \
    libcurl4-openssl-dev \
    zlib1g-dev \
    libncurses5-dev \
    libxml2 \
    libxml2-dev \
    csh \
    liblapack-dev \
    libblas-dev \
    liblapack-dev \
    libffi6 \
    libffi-dev \
    libxml-libxml-perl \
    libxml2-utils \
    vim \
    libudunits2-0 \
    libudunits2-dev \
    udunits-bin \
    htop \
    python2.7 \
    python-dev \
    python-pip \
    python3 \
    python3-pip \
    apt-utils \
    ftp \
    apt-transport-https \
    locales

## Install program to configure locales
RUN dpkg-reconfigure locales && \
  locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
      locale-gen
## Set default locale for the environment
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

## check locales
RUN locale -a

## compile openMPI
RUN echo "*** Compiling openMPI " ${OPENMPI_VERSION}
RUN cd / \
    && wget https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-${OPENMPI_VERSION}.tar.gz \
    && tar -zxvf openmpi-${OPENMPI_VERSION}.tar.gz \
    && cd openmpi-${OPENMPI_VERSION} \
    && export PATH=/usr/local/bin:$PATH \
    && export LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH \
    && ./configure --enable-static \
    && make \
    && make install \
    && cd / \
    && rm -r openmpi-${OPENMPI_VERSION} \
    && rm openmpi-${OPENMPI_VERSION}.tar.gz \
    && ldconfig

## Compile Expat XML parser
RUN echo "*** Compiling Expat XML parser"
RUN cd / \
    && wget https://github.com/libexpat/libexpat/releases/download/R_2_4_7/expat-2.4.7.tar.bz2 \
    && tar -xvjf expat-2.2.6.tar.bz2 \
    && cd expat-2.2.6 \
    && ./configure \
    && make \
    && make install \
    && cd / \
    && rm -r expat-2.2.6 \
    && rm expat-2.2.6.tar.bz2

## HDF5
RUN echo "*** Compiling HDF5 " ${HDF5_VERSION}
RUN cd / \
    && mkdir -p /usr/local/hdf5 \
    && wget https://s3.amazonaws.com/hdf-wordpress-1/wp-content/uploads/manual/HDF5/HDF5_1_10_4/hdf5-1.10.4.tar.gz \
    && tar -zxvf hdf5-1.10.4.tar.gz \
    && cd hdf5-1.10.4 \
    && CC=mpicc ./configure --enable-fortran --enable-parallel --prefix=/usr/local/hdf5 \
    && make \
    && make install \
    && export PATH=/usr/local/hdf5/bin:$PATH \
    && export LD_LIBRARY_PATH=/usr/local/hdf5/lib/libhdf5 \
    && cd / \
    && rm -r hdf5-1.10.4 \
    && rm hdf5-1.10.4.tar.gz