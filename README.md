# R_Class

My R Class for MBA — with a ready-to-use **VS Code R development environment** in a dev container.

## What you get

A reproducible Linux container with everything a mid-level R data scientist needs:

| Component | Purpose |
|---|---|
| **R 4.4.x** (rocker/tidyverse) | R + the full tidyverse, devtools, rmarkdown, knitr |
| **radian** | Modern R REPL — syntax highlighting, multi-line editing, history search |
| **languageserver** | IntelliSense, hover docs, go-to-definition, lint-as-you-type |
| **httpgd** | Live graphics device that streams plots into the VS Code Plot Viewer |
| **vscDebugger** | Step-through debugger (breakpoints, call stack, watch) |
| **IRkernel** | Run R inside Jupyter notebooks (`.ipynb`) |
| **renv** | Project-pinned package versions, with a cache mounted across rebuilds |
| **Extras** | `data.table`, `plotly`, `DT`, `skimr`, `janitor`, `gtsummary`, `tidymodels`, `lintr`, `styler` |

### VS Code extensions installed automatically

- `REditorSupport.r` — core R language support
- `RDebugger.r-debugger` — debugger
- `quarto.quarto` — `.qmd` authoring
- `ms-toolsai.jupyter` (+ keymap, renderers) — R notebooks
- `mechatroner.rainbow-csv`, `grapecity.gc-excelviewer` — tabular data viewers
- `eamodio.gitlens`, `streetsidesoftware.code-spell-checker`, `editorconfig.editorconfig`

## Prerequisites

1. [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows / macOS / Linux)
2. [Visual Studio Code](https://code.visualstudio.com/)
3. The **Dev Containers** extension (`ms-vscode-remote.remote-containers`)

## Getting started

1. Clone this repo and open it in VS Code.
2. When prompted, click **Reopen in Container** — or press `F1` → **Dev Containers: Reopen in Container**.
3. First build takes a few minutes (downloads `rocker/tidyverse` and installs packages). Subsequent rebuilds are fast — the `renv` cache is mounted to a named Docker volume.
4. Once it opens, run the smoke test in the R terminal:

   ```r
   source("examples/hello_plot.R")
   ```

   - Console output appears in the integrated R terminal.
   - The ggplot chart opens in the **Plot Viewer** tab (powered by `httpgd`).

## Working with R in VS Code

- **Send a line / selection to the R terminal:** `Ctrl+Enter`
- **Run the whole file:** `Ctrl+Shift+S` (source) or `Ctrl+Shift+Enter` (source with echo)
- **Plot Viewer:** plots open automatically; toggle via the icon in the editor title bar
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
examples/
└── hello_plot.R        # Smoke test: console output + ggplot chart
README.md
LICENSE
```

## Customizing

- **Add CRAN packages:** edit the `install2.r` block in [.devcontainer/Dockerfile](.devcontainer/Dockerfile) and rebuild (`F1` → *Dev Containers: Rebuild Container*).
- **Per-project pinning:** run `renv::init()` in the R terminal to create a project lockfile.
- **Bump R version:** override the build arg in [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json) under `build.args.R_VERSION`.
