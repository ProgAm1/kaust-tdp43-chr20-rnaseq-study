#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

REF_DIR="references"
TRIM_DIR="trimmed_data"
INDEX_DIR="${REF_DIR}/salmon_index"
OUT_DIR="salmon_quant"
TRANSCRIPTS_FA="${REF_DIR}/Homo_sapiens.GRCh38.cdna.all.fa"

THREADS="${THREADS:-8}"

mkdir -p "${INDEX_DIR}" "${OUT_DIR}"

if [ ! -f "${TRANSCRIPTS_FA}" ]; then
  echo "ERROR: Missing transcriptome FASTA: ${TRANSCRIPTS_FA}"
  exit 1
fi

if [ ! -f "${INDEX_DIR}/versionInfo.json" ]; then
  echo "Building Salmon index..."
  salmon index -t "${TRANSCRIPTS_FA}" -i "${INDEX_DIR}" -p "${THREADS}"
else
  echo "Salmon index exists: ${INDEX_DIR}"
fi

SAMPLES=(WT_1 WT_2 WT_3 KO_1 KO_2 KO_3)

for s in "${SAMPLES[@]}"; do
  R1="${TRIM_DIR}/${s}_1.trim.fastq.gz"
  R2="${TRIM_DIR}/${s}_2.trim.fastq.gz"
  SAMPLE_OUT="${OUT_DIR}/${s}"

  if [ ! -f "${R1}" ] || [ ! -f "${R2}" ]; then
    echo "ERROR: Missing trimmed reads for ${s}:"
    echo "  ${R1}"
    echo "  ${R2}"
    exit 1
  fi

  echo "Quantifying ${s} ..."
  salmon quant \
    -i "${INDEX_DIR}" \
    -l A \
    -1 "${R1}" \
    -2 "${R2}" \
    -p "${THREADS}" \
    -o "${SAMPLE_OUT}"
done

echo "Done ✅ Results in: ${OUT_DIR}"
