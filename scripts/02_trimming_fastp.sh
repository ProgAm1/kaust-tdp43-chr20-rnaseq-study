#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

cd "$(dirname "$0")/.."

mkdir -p trimmed_data qc_reports/fastp qc_reports/fastqc_trimmed qc_reports/multiqc_trimmed

SAMPLES=(WT_1 WT_2 WT_3 KO_1 KO_2 KO_3)

for s in "${SAMPLES[@]}"; do
  R1=(raw_data/${s}_*_1.fastq.gz)
  R2=(raw_data/${s}_*_2.fastq.gz)

  if [ ! -f "${R1[0]:-}" ] || [ ! -f "${R2[0]:-}" ]; then
    echo "ERROR: Missing FASTQ pair for sample ${s}."
    echo "Expected: raw_data/${s}_*_1.fastq.gz and raw_data/${s}_*_2.fastq.gz"
    echo "Found R1: ${R1[*]:-NONE}"
    echo "Found R2: ${R2[*]:-NONE}"
    exit 1
  fi

  fastp \
    --in1 "${R1[0]}" \
    --in2 "${R2[0]}" \
    --out1 "trimmed_data/${s}_1.trim.fastq.gz" \
    --out2 "trimmed_data/${s}_2.trim.fastq.gz" \
    --qualified_quality_phred 20 \
    --length_required 36 \
    --detect_adapter_for_pe \
    --overrepresentation_analysis \
    --thread 4 \
    --json "qc_reports/fastp/${s}.json" \
    --html "qc_reports/fastp/${s}.html"
done

fastqc -o qc_reports/fastqc_trimmed trimmed_data/*.fastq.gz
multiqc -o qc_reports/multiqc_trimmed qc_reports/fastqc_trimmed qc_reports/fastp
