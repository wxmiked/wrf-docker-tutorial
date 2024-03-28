FROM nvcr.io/nvidia/nvhpc:24.1-devel-cuda_multi-ubuntu22.04

WORKDIR /build
RUN wget https://github.com/wrf-model/WRF/releases/download/v4.5.2/v4.5.2.tar.gz -O wrf.tar.gz
RUN wget https://github.com/wrf-model/WPS/archive/refs/tags/v4.5.tar.gz -O wps.tar.gz
RUN tar xvzf wrf.tar.gz --transform 's!^[^/]\+\($\|/\)!wrf\1!' && tar xvzf wps.tar.gz --transform 's!^[^/]\+\($\|/\)!wps\1!'
RUN apt-get update
RUN apt-get -y install less csh libnetcdf-mpi-dev libnetcdff-dev libxml2-dev

# netCDF C
RUN wget https://downloads.unidata.ucar.edu/netcdf-c/4.9.2/netcdf-c-4.9.2.tar.gz -O netcdf.tar.gz
RUN tar xvzf netcdf.tar.gz --transform 's!^[^/]\+\($\|/\)!netcdf-c\1!'
RUN cd netcdf-c && CC=pgcc CXX=pgc++ ./configure --prefix=/build/netcdf --disable-hdf5 --enable-parallel && make -j 8 && make install && cd ..

# netCDF Fortran
RUN wget https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.6.1.tar.gz -O netcdf-fortran.tar.gz
RUN tar xvzf netcdf-fortran.tar.gz --transform 's!^[^/]\+\($\|/\)!netcdf-f\1!'
RUN cd netcdf-f && CC=pgcc CXX=pgc++ FC=pgf90 ./configure --prefix=/build/netcdf --disable-hdf5 --enable-parallel && make -j 8 && make install && cd ..

RUN cd /build/wrf && echo 53 1 > wrf-config && NETCDF_classic=1 NETCDF=/build/netcdf ./configure < wrf-config && ./compile -j 4 em_real
