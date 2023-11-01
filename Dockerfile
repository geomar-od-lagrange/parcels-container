FROM jupyter/base-notebook:2023-08-28

# user JLab
ENV JUPYTER_ENABLE_LAB=true

USER root

# Install parcels env from file
COPY environment.yml /tmp/
COPY fix_conda_env_ipykernel_install.py /tmp/
RUN mamba env update --name parcels --file /tmp/environment.yml && \
    # clean conda cache, index and package tarballs
    conda clean -a && \
    # install kernel
    source /opt/conda/etc/profile.d/conda.sh && \
    conda activate base && \
    ipython kernel install --name "parcels" && \
    python /tmp/fix_conda_env_ipykernel_install.py --name "parcels" && \
    # fix file permissions
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    rm -f /tmp/environment.yml /tmp/fix_conda_env_ipykernel_install.py

# update base env from file
COPY environment_base.yml /tmp/
RUN mamba env update --name base --file /tmp/environment_base.yml && \
    # clean conda cache, index and package tarballs
    conda clean -a && \
    # install kernel
    source /opt/conda/etc/profile.d/conda.sh && \
    # fix file permissions
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    rm -f /tmp/environment_base.yml

# clean up home dir
RUN rm -rf $HOME/*

USER $NB_USER