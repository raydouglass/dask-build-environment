ARG CUDA_VER=11.2
ARG LINUX_VER=ubuntu18.04

FROM gpuci/miniconda-cuda:$CUDA_VER-devel-$LINUX_VER

ARG CUDA_VER=11.2
ARG PYTHON_VER=3.8
ARG RAPIDS_VER=21.08


ADD https://raw.githubusercontent.com/dask/dask/main/continuous_integration/environment-$PYTHON_VER-dev.yaml /dask_environment.yaml

RUN conda config --set ssl_verify false

RUN conda install -c gpuci gpuci-tools

RUN gpuci_conda_retry install -c conda-forge mamba

RUN mamba env create -n dask --file /dask_environment.yaml

RUN mamba install -y -n dask -c rapidsai -c rapidsai-nightly -c nvidia -c conda-forge \
    cudf=$RAPIDS_VER \
    cupy \
    cudatoolkit=$CUDA_VER

# Clean up pkgs to reduce image size and chmod for all users
RUN chmod -R ugo+w /opt/conda \
    && conda clean -tipy \
    && chmod -R ugo+w /opt/conda

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
