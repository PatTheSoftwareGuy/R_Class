# R Data Science dev container for VS Code
# Base: rocker/tidyverse ships R + the full tidyverse, devtools, RStudio toolchain,
# and a non-root `rstudio` user — a strong starting point for a mid-level data scientist.
ARG R_VERSION=4.4.2
FROM rocker/tidyverse:${R_VERSION}

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    RENV_PATHS_CACHE=/home/rstudio/.cache/R/renv \
    R_LIBS_USER=/home/rstudio/R/library

# ---------------------------------------------------------------------------
# System packages
#   - python3 + pipx        : radian (better R REPL) and IRkernel deps
#   - libxml2/curl/ssl/...  : common CRAN package build deps (already mostly in base)
#   - libcairo2/libxt       : high-quality graphics device support
#   - libsodium / libsecret : credential storage, used by some pkgs
#   - git, ssh, less, vim, htop, sudo : everyday dev ergonomics
# ---------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-venv \
    python3-jupyter-core \
    python3-jupyter-client \
        pipx \
        git \
        openssh-client \
        less \
        vim \
        htop \
        sudo \
        libxml2-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        libgit2-dev \
        libsodium-dev \
        libsecret-1-dev \
        libcairo2-dev \
        libxt-dev \
        libfontconfig1-dev \
        libharfbuzz-dev \
        libfribidi-dev \
        libfreetype6-dev \
        libpng-dev \
        libtiff5-dev \
        libjpeg-dev \
        libzmq3-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Give the default rstudio user passwordless sudo for dev container convenience
RUN echo "rstudio ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/rstudio \
    && chmod 0440 /etc/sudoers.d/rstudio

# ---------------------------------------------------------------------------
# Radian — a modern R REPL with syntax highlighting and multi-line editing.
# Installed system-wide via pipx so it's on PATH for all users.
# ---------------------------------------------------------------------------
ENV PIPX_HOME=/opt/pipx \
    PIPX_BIN_DIR=/usr/local/bin
RUN pipx install --global radian || pipx install radian

# ---------------------------------------------------------------------------
# R packages required by the VS Code R extension + R Debugger + plot viewer,
# plus a handful of staples a mid-level data scientist will reach for daily.
# rocker/tidyverse already provides: tidyverse, devtools, rmarkdown, knitr.
# ---------------------------------------------------------------------------
RUN install2.r --error --skipinstalled --ncpus -1 \
        languageserver \
        lintr \
        styler \
        rlang \
        jsonlite \
        rmarkdown \
        knitr \
        IRkernel \
        renv \
        here \
        janitor \
        data.table \
        plotly \
        DT \
        skimr \
        gtsummary \
        tidymodels \
    && rm -rf /tmp/downloaded_packages

# httpgd is optional and can require lengthy source builds depending on R/CRAN
# availability. Skip it during image build to keep rebuilds deterministic.
RUN R -e "message('Skipping httpgd during build; install later in-session if desired.')"

# vscDebugger (R Debugger backend) is not on CRAN — install from GitHub.
RUN R -e "remotes::install_github('ManuelHentschel/vscDebugger', upgrade='never')"

# Register the IRkernel so R notebooks work in the Jupyter extension.
RUN R -e "if (nzchar(Sys.which('jupyter'))) { \
        IRkernel::installspec(user = FALSE) \
    } else { \
        message('Skipping IRkernel::installspec during build because jupyter is not available on PATH.') \
    }"

# Prep user-owned dirs the dev container will write into.
RUN mkdir -p /home/rstudio/R/library /home/rstudio/.cache/R/renv \
    && chown -R rstudio:rstudio /home/rstudio/R /home/rstudio/.cache

USER rstudio
WORKDIR /home/rstudio/project

# Copy in user-level R profile so httpgd + radian behave well inside VS Code.
COPY --chown=rstudio:rstudio .devcontainer/Rprofile.site /home/rstudio/.Rprofile
