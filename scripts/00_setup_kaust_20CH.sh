#!/bin/bash
set -euo pipefail

# =========================
# Project name + location
# =========================
PROJECT_DIR="$HOME/kaust_20CH"

# =========================
# Create main project directory
# (This includes your exact folder-structure code)
# =========================
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

mkdir -p subsampled_data
mkdir -p trimmed_data
mkdir -p references
mkdir -p qc_reports/fastqc_raw qc_reports/fastqc_trimmed qc_reports/fastp
mkdir -p alignment
mkdir -p salmon_quant
mkdir -p counts
mkdir -p results/tables results/figures results/enrichment
mkdir -p logs
mkdir -p raw_data
mkdir -p data

# =========================
# Quick tool check (simple)
# =========================
for t in wget unzip gunzip awk; do
  if ! command -v "$t" >/dev/null 2>&1; then
    echo "ERROR: missing tool: $t"
    echo "Install it then re-run."
    exit 1
  fi
done

echo "✅ Folder structure ready at: $PROJECT_DIR"
echo

# =========================
# 1) Download RNA-seq data (chr20_data.zip) and unzip
# =========================
DATA_URL="https://zenodo.org/records/18481303/files/chr20_data.zip?download=1"
DATA_ZIP="data/chr20_data.zip"

if [ ! -f "$DATA_ZIP" ]; then
  echo "⬇️ Downloading data zip..."
  wget -O "$DATA_ZIP" --content-disposition --trust-server-names "$DATA_URL"	
  echo "Checking downloaded file type..."
  file "$DATA_ZIP"

else
  echo "⏭️ Data zip already exists: $DATA_ZIP"
fi

echo "📦 Unzipping data..."
unzip -o "$DATA_ZIP" -d .

echo

# =========================
# 2) Download references (Ensembl release 115)
#    - chr20 genome FASTA
#    - full GTF + subset chr20
#    - transcriptome cDNA for Salmon
# =========================

# 2A) chr20 genome FASTA
CHR20_DNA_URL="https://ftp.ensembl.org/pub/release-115/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.chromosome.20.fa.gz"
CHR20_DNA_GZ="references/Homo_sapiens.GRCh38.dna.chromosome.20.fa.gz"
CHR20_DNA_FA="references/Homo_sapiens.GRCh38.dna.chromosome.20.fa"

if [ ! -f "$CHR20_DNA_FA" ]; then
  echo "⬇️ Downloading chr20 genome FASTA..."
  wget -O "$CHR20_DNA_GZ" "$CHR20_DNA_URL"
  gunzip -f "$CHR20_DNA_GZ"
else
  echo "⏭️ chr20 genome FASTA already exists"
fi

# 2B) GTF (full) + chr20-only GTF
GTF_URL="https://ftp.ensembl.org/pub/release-115/gtf/homo_sapiens/Homo_sapiens.GRCh38.115.gtf.gz"
GTF_GZ="references/Homo_sapiens.GRCh38.115.gtf.gz"
GTF_FILE="references/Homo_sapiens.GRCh38.115.gtf"
GTF_CHR20="references/Homo_sapiens.GRCh38.115.chr20.gtf"

if [ ! -f "$GTF_FILE" ]; then
  echo "⬇️ Downloading GTF..."
  wget -O "$GTF_GZ" "$GTF_URL"
  gunzip -f "$GTF_GZ"
else
  echo "⏭️ GTF already exists"
fi

if [ ! -f "$GTF_CHR20" ]; then
  echo "✂️ Creating chr20-only GTF..."
  awk 'BEGIN{OFS="\t"} $0 ~ /^#/ {print; next} $1=="20" {print}' "$GTF_FILE" > "$GTF_CHR20"
else
  echo "⏭️ chr20 GTF already exists"
fi

# 2C) Transcriptome (cDNA) for Salmon
CDNA_URL="https://ftp.ensembl.org/pub/release-115/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz"
CDNA_GZ="references/Homo_sapiens.GRCh38.cdna.all.fa.gz"
CDNA_FA="references/Homo_sapiens.GRCh38.cdna.all.fa"

if [ ! -f "$CDNA_FA" ]; then
  echo "⬇️ Downloading transcriptome (cDNA) for Salmon..."
  wget -O "$CDNA_GZ" "$CDNA_URL"
  gunzip -f "$CDNA_GZ"
else
  echo "⏭️ Transcriptome already exists"
fi

echo
echo "✅ All downloads complete."
echo "📌 Project: $PROJECT_DIR"
echo "📌 Data zip: $DATA_ZIP"
echo "📌 chr20 FASTA: $CHR20_DNA_FA"
echo "📌 GTF full: $GTF_FILE"
echo "📌 GTF chr20: $GTF_CHR20"
echo "📌 cDNA: $CDNA_FA"
echo
echo "📁 Current tree (top-level):"
ls -1

