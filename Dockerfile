FROM jupyter/base-notebook:latest

# user JLab
ENV JUPYTER_ENABLE_LAB=true

USER root

# Install conda env from file
COPY environment.yml /tmp/
COPY fix_conda_env_ipykernel_install.py /tmp/
RUN mamba env update --name parcels --file /tmp/environment.yml && \
    # Build Jupyterlab extensions
    jupyter labextension install -y --clean --no-build \
    jupyterlab-jupytext dask-labextension && \
    jupyter lab build && \
    # clean conda cache, index and package tarballs
    conda clean -a && \
    # install kernel
    source /opt/conda/etc/profile.d/conda.sh && \
    conda activate base && \
    ipython kernel install --name "parcels" && \
    python /tmp/fix_conda_env_ipykernel_install.py --name "parcels" && \
    # fix file permissions
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# clean up home dir
RUN rm -rf $HOME/*

USER $NB_USER