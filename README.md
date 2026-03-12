# KAUST TDP-43 chr20 RNA-seq Study

This repository contains an RNA-seq analysis pipeline developed as part of the **KAUST Bioinformatics Program**.  
The project investigates transcriptomic changes associated with **TDP-43 knockout (KO)**, with a specific focus on **chromosome 20 (chr20)**.

The workflow covers the major stages of RNA-seq analysis, including quality control, read trimming, transcript quantification, differential expression analysis, and downstream visualization.

---

## Project Overview

TDP-43 is an RNA-binding protein implicated in multiple neurodegenerative diseases.  
In this study, we analyze RNA-seq data from **TDP-43 knockout (KO)** and **wild-type (WT)** samples to identify gene expression changes associated with loss of TDP-43 function.

The analysis specifically emphasizes genes located on **chromosome 20**, enabling a targeted investigation of transcriptomic alterations within this genomic region.

---

## Related Preprint

This repository is associated with our preprint:

**Chromosome 20 RNA-seq Analysis: TDP-43 Knockout vs Wild-Type Rescue**  
Research Square (Preprint)  
[Read the paper on Research Square](https://www.researchsquare.com/article/rs-9077001/v1)

[View PDF](docs/tdp43_chr20_paper.pdf)
---

## Dataset

The RNA-seq dataset consists of paired-end sequencing reads from:

- **KO samples:** `KO_1`, `KO_2`, `KO_3`
- **WT samples:** `WT_1`, `WT_2`, `WT_3`

Sample metadata can be found in:

- `data/sample_metadata.csv`

Raw sequencing reads and reference genome files are not included in this repository due to size limitations. However, the analysis can be reproduced using the provided scripts and metadata.

---

## Analysis Workflow

The pipeline consists of the following steps:

1. **Quality Control**
   - Raw read quality assessment using **FastQC**
   - Aggregated QC summary using **MultiQC**

2. **Read Trimming**
   - Adapter removal and quality trimming using **fastp**

3. **Transcript Quantification**
   - Transcript-level quantification using **Salmon**

4. **Differential Expression Analysis**
   - Import of transcript quantifications using **tximport**
   - Differential expression analysis using **DESeq2**

5. **Chromosome 20 Filtering**
   - Extraction of genes located on **chr20** for focused downstream analysis

6. **Visualization**
   - PCA plot for sample clustering
   - MA plot for differential expression overview
   - Volcano plot for significance vs fold change visualization

---

## Repository Structure

```text
kaust_tdp43_chr20_rnaseq_study/
│
├── data/
│   └── sample_metadata.csv
│
├── qc_reports/
│   ├── fastqc_raw/
│   ├── fastqc_trimmed/
│   ├── fastp/
│   └── multiqc/
│
├── salmon_quant/
│   ├── KO_1/
│   ├── KO_2/
│   ├── KO_3/
│   ├── WT_1/
│   ├── WT_2/
│   └── WT_3/
│
├── results/
│   ├── tables/
│   ├── figures/
│   └── plots/
│
├── scripts/
│   ├── 00_setup_kaust_20CH.sh
│   ├── 01_qc_fastqc.sh
│   ├── 02_trimming_fastp.sh
│   ├── 03_quant_salmon.sh
│   ├── 05_deseq2.R
│   └── analysis_utilities/
│
└── README.md
```

---

## Key Results

Differential expression analysis identified several genes significantly affected by **TDP-43 knockout**.

Main outputs include:

- **DESeq2 differential expression tables**
- **PCA plot**
- **MA plot**
- **Volcano plot**

Result files can be found in:

- `results/tables/`
- `results/figures/`
- `results/plots/`

### PCA Plot

Principal Component Analysis (PCA) was performed on variance-stabilized counts to visualize sample clustering and transcriptomic differences between conditions.

![PCA Plot](results/plots/PCA_VST.png)

### MA Plot

The MA plot illustrates the relationship between mean gene expression and log2 fold change, highlighting significantly differentially expressed genes.

![MA Plot](results/figures/MA_plot.png)

### Volcano Plot

The volcano plot summarizes differential expression results by combining statistical significance and magnitude of gene expression change.

![Volcano Plot](results/figures/Volcano_plot.png)

---

## Tools Used

The analysis pipeline uses the following tools:

- **FastQC**
- **fastp**
- **MultiQC**
- **Salmon**
- **tximport**
- **DESeq2**
- **R**
- **Python**

---

## Reproducibility

The scripts in the `scripts/` directory allow the workflow to be reproduced step-by-step, starting from raw FASTQ files through transcript quantification and differential expression analysis.

Large files such as raw sequencing data and genome references are excluded from the repository.

---

## Citation

If you use this repository or build upon this work, please cite the following preprint:

**Aljarodi, A. A. S., Babasit, A. Y., Abdullah, A. E., & Bukhamsin, A. A. A.**  
*Chromosome 20 RNA-seq Analysis: TDP-43 Knockout vs Wild-Type Rescue.*  
Research Square (Preprint), 2025.  
DOI: [10.21203/rs.3.rs-9077001/v1](https://doi.org/10.21203/rs.3.rs-9077001/v1)  
License: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)

> ⚠️ This is a preprint and has not yet been peer reviewed.

---

## Authors

- Ammar Yasir Babasit
- Almokhtar Akeel S. Aljarodi
- Abdullah Eyad Abdullah
- Ahmad Abdullah A. Bukhamsin

**KAUST Bioinformatics Program**
