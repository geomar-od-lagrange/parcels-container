FROM jupyter/base-notebook:latest

# user JLab
ENV JUPYTER_ENABLE_LAB=true

# Install conda env from file
COPY environment.yml /tmp/
RUN mamba env update --name base --file /tmp/environment.yml && \
    # Build Jupyterlab extensions
    jupyter labextension install -y --clean --no-build \
    jupyterlab-jupytext dask-labextension && \
    jupyter lab build && \
    # clean conda cache, index and package tarballs
    conda clean -a && \
    # fix file permissions
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
