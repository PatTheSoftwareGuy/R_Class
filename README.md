# R_Class

R coursework workspace with a VS Code devcontainer for running R and Jupyter notebooks.

## Quick start (VS Code)

1. Open this repo in either:
   - **Dev Containers** in Visual Studio Code (`F1` -> **Dev Containers: Reopen in Container**), or
   - **GitHub Codespaces**.
2. In a **bash** terminal, run:

   ```bash
   ./scripts/setup_r_jupyter.sh
   ```

3. Create a new `.ipynb` notebook in VS Code, then select the kernel:
   - **R (IRkernel)**

That is the required setup flow for this repository.

## What this environment provides

- Base image: `rocker/tidyverse` with R 4.4.x
- R packages for editing/debugging workflows (`languageserver`, `lintr`, `styler`, `vscDebugger`, etc.)
- Jupyter support configured by `./scripts/setup_r_jupyter.sh`:
  - Python venv at `.venv-jupyter`
  - Jupyter + nbconvert installed in that venv
  - R kernel registered as **R (IRkernel)**
- PDF export dependencies in the container (`pandoc`, `xelatex`)

## Prerequisites

If you use **Dev Containers** locally:

1. [Visual Studio Code](https://code.visualstudio.com/)
2. [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Docker Engine)
3. Dev Containers extension (`ms-vscode-remote.remote-containers`)

If you use **GitHub Codespaces**, Docker is not required on your machine.

## Verify setup

After running `./scripts/setup_r_jupyter.sh`, you can verify tools from bash:

```bash
source .venv-jupyter/bin/activate
jupyter --version
Rscript -e "IRkernel::installspec(user = TRUE, name = 'ir', displayname = 'R (IRkernel)')"
```

## Working with R in VS Code

- **Send a line / selection to the R terminal:** `Ctrl+Enter`
- **Run the whole file:** `Ctrl+Shift+S` (source) or `Ctrl+Shift+Enter` (source with echo)
- **Plot Viewer:** available through the VS Code R extension
- **Environment / Workspace viewer:** side panel shows live variables; `View(df)` opens a data grid
- **Help:** `?function_name` renders in the side panel
- **Debugger:** set a breakpoint in the gutter, then **Run and Debug** → *R-Debugger*
- **Format on save:** enabled for `.R` files (via `styler`)
- **Lint:** `lintr` diagnostics show inline

## Project layout

```
.devcontainer/
├── devcontainer.json   # VS Code dev-container config (extensions, settings, ports)
├── Dockerfile          # R + system deps + R packages
└── Rprofile.site       # Sets httpgd as default graphics device, etc.
scripts/
└── setup_r_jupyter.sh  # Installs Jupyter in .venv-jupyter and registers R (IRkernel)
examples/
└── hello_plot.R        # Smoke test: console output + ggplot chart
README.md
LICENSE
```

## Customizing

- **Add CRAN packages:** edit the `install2.r` block in [.devcontainer/Dockerfile](.devcontainer/Dockerfile) and rebuild (`F1` -> *Dev Containers: Rebuild Container*).
- **Per-project pinning:** run `renv::init()` in the R terminal to create a project lockfile.
