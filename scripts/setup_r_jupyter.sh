#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VENV_DIR="${VENV_DIR:-$ROOT_DIR/.venv-jupyter}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
JUPYTER_PACKAGES=(jupyterlab notebook ipykernel nbconvert)

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Missing required command: $command_name" >&2
        exit 1
    fi
}

  warn_missing_command() {
    local command_name="$1"
    local install_hint="$2"

    if command -v "$command_name" >/dev/null 2>&1; then
      return 0
    fi

    echo "Warning: $command_name is not available on PATH. $install_hint" >&2
    return 1
  }

echo "Checking local prerequisites..."
require_command "$PYTHON_BIN"
require_command Rscript

if [[ ! -d "$VENV_DIR" ]]; then
    echo "Creating Python virtual environment at $VENV_DIR"
    "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

echo "Installing Jupyter into $VENV_DIR"
"$VENV_DIR/bin/python" -m pip install --upgrade pip setuptools wheel
"$VENV_DIR/bin/python" -m pip install "${JUPYTER_PACKAGES[@]}"

export PATH="$VENV_DIR/bin:$PATH"

echo "Installing the R IRkernel package if needed"
Rscript -e "options(repos = c(CRAN = 'https://cloud.r-project.org')); if (!requireNamespace('IRkernel', quietly = TRUE)) install.packages('IRkernel')"

echo "Registering the R kernel with Jupyter"
Rscript -e "IRkernel::installspec(user = TRUE, name = 'ir', displayname = 'R (IRkernel)')"

echo "Validating notebook export prerequisites"
missing_tools=0

if ! command -v jupyter >/dev/null 2>&1; then
  echo "Warning: jupyter is not available from $VENV_DIR/bin even after installation." >&2
  missing_tools=1
fi

if ! "$VENV_DIR/bin/python" -m jupyter nbconvert --version >/dev/null 2>&1; then
  echo "Warning: nbconvert is not installed or not runnable from $VENV_DIR." >&2
  missing_tools=1
fi

if ! warn_missing_command xelatex "Rebuild the dev container after installing the TeX packages in .devcontainer/Dockerfile."; then
  missing_tools=1
fi

if ! warn_missing_command pandoc "Rebuild the dev container after installing pandoc in .devcontainer/Dockerfile."; then
  missing_tools=1
fi

cat <<EOF

R support for Jupyter is configured.

PDF export readiness: $(if [[ "$missing_tools" -eq 0 ]]; then echo "ready"; else echo "missing dependencies"; fi)

Use these commands when needed:
  source "$VENV_DIR/bin/activate"
  jupyter lab

In VS Code, reopen the notebook and select the kernel named:
  R (IRkernel)
EOF