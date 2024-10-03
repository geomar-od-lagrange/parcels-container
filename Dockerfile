FROM quay.io/jupyter/base-notebook:2024-10-02

# user JLab
ENV JUPYTER_ENABLE_LAB=true

USER root

# Install parcels env from file
COPY environment.yml /tmp/
RUN mamba env update --name base --file /tmp/environment.yml && \
    # clean conda cache, index and package tarballs
    conda clean -a && \
    # fix file permissions
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    rm -f /tmp/environment.yml

# clean up home dir
RUN rm -rf $HOME/*

USER $NB_USER