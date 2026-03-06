	#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."


test -f "data/sample_metadata.csv"
test -f "references/tx2gene.tsv"


Rscript scripts/05_deseq2.R
