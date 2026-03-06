#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

mkdir -p qc_reports/fastqc_raw qc_reports/multiqc_raw

fastqc -o qc_reports/fastqc_raw raw_data/*.fastq.gz
multiqc -o qc_reports/multiqc_raw qc_reports/fastqc_raw
