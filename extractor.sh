#!/bin/bash

set -euo pipefail

count=1

OUT_FILE=./_dump_extract

find "$1" -type f \( -not -path '*/__pycache__/*' \
                  -not -path '*/.mypy_cache/*' \
                  -not -path '*/.pytest_cache/*' \
                  -not -path '*.pyc' \
                  -not -path '*.pyo' \
                  -not -path '*.so' \
                  -not -path '*.egg-info/*' \
                  -not -path '*.egg/*' \
                  -not -path '*.git/*' \
                  -not -path '*.svn/*' \
                  -not -path '*.hg/*' \
                  -not -path '*.venv/*' \
                  -not -path '*.tox/*' \
                  -not -path '*.tmp/*' \
                  -not -path '*.swp' \
                  -not -path '*.swo' \
                  -not -path '*.bak' \
                  -not -path '*.log' \
                  -not -path '*.rst' \
                  -not -path '*.rst.txt' \
                  -not -path '*.rst.html' \
                  -not -path '*.rst.css' \
                  -not -path '*.rst.js' \
                  -not -path '*.rst.json' \
                  -not -path '*.rst.yaml' \
                  -not -path '*.rst.yml' \
                  -not -path '*.rst.rst' \
                  -not -path '*.rst.rst.txt' \
                  -not -path '*.rst.rst.html' \
                  -not -path '*.rst.rst.css' \
                  -not -path '*.rst.rst.js' \
                  -not -path '*.rst.rst.json' \
                  -not -path '*.rst.rst.yaml' \
                  -not -path '*.rst.rst.yml' \
                  -not -path '*.rst.rst.xml' \
                  -not -path '*.rst.rst.ini' \
                  -not -path '*.rst.rst.conf' \
                  -not -path '*.rst.rst.toml' \
                  -not -path '*.bak' \
                  -not -path '*.old' \
                  -not -path '*.orig' \
                  -not -path '*.backup' \
                  -not -path '*.swp' \
                  -not -path '*.swo' \
                  -not -path '*.~' \
                  -not -path '*~' \
                  -not -path '#*#' \
                  -not -path '._*' \
                  -not -path '.DS_Store' \
                  -not -path '.Spotlight*' \
                  -not -path '.Trashes' \
                  -not -path '*/.git/*' \
                  -not -path '*.ipynb_checkpoints/*' \) \
                  -print0 | while IFS= read -r -d '' file; do
                  ((count++))

                  echo "[FILE#${count}] ; PATH: ["$file"]" >> $OUT_FILE
                  echo "<><><><>" >> $OUT_FILE
                  cat "$file" >> $OUT_FILE 
                  echo "<><><><>" >>$OUT_FILE
                  echo >> $OUT_FILE
                  echo >> $OUT_FILE
                done
