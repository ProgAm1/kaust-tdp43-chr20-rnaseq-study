# =========================
# Lab 5: tximport + DESeq2
# Project: kaust_20CH
# =========================

suppressPackageStartupMessages({
  library(tximport)
  library(DESeq2)
  library(readr)
  library(dplyr)
  library(ggplot2)
})

# ---- paths ----
project_dir <- path.expand("~/kaust_20CH")
quant_dir   <- file.path(project_dir, "salmon_quant")
tx2gene_fp  <- file.path(project_dir, "references", "tx2gene.tsv")
meta_fp     <- file.path(project_dir, "data", "sample_metadata.csv")

out_tables  <- file.path(project_dir, "results", "tables")
out_figures <- file.path(project_dir, "results", "figures")
dir.create(out_tables,  showWarnings = FALSE, recursive = TRUE)
dir.create(out_figures, showWarnings = FALSE, recursive = TRUE)

# ---- metadata ----
meta <- read_csv(meta_fp, show_col_types = FALSE) %>%
  mutate(condition = factor(condition, levels = c("WT","KO")))

# ---- quant.sf files ----
files <- file.path(quant_dir, meta$sample, "quant.sf")
names(files) <- meta$sample

# checks
stopifnot(file.exists(tx2gene_fp))
missing_files <- files[!file.exists(files)]
if (length(missing_files) > 0) {
  stop("Missing quant.sf for samples:\n", paste(names(missing_files), missing_files, sep=" => ", collapse="\n"))
}

# ---- tx2gene ----
tx2gene <- read_tsv(tx2gene_fp, col_names = c("TXNAME","GENEID"), show_col_types = FALSE)

# ---- tximport (gene-level counts) ----
txi <- tximport(files, type = "salmon", tx2gene = tx2gene, ignoreTxVersion = TRUE)

# ---- DESeq2 ----
dds <- DESeqDataSetFromTximport(txi, colData = meta, design = ~ condition)

# optional small filter: remove genes with tiny counts
dds <- dds[rowSums(counts(dds)) >= 10, ]

dds <- DESeq(dds)

res <- results(dds, contrast = c("condition","KO","WT")) %>%
  as.data.frame() %>%
  tibble::rownames_to_column("gene_id")

# sort by padj
res_sorted <- res %>% arrange(padj)

# save tables
write_csv(res_sorted, file.path(out_tables, "DESeq2_all_genes.csv"))

sig <- res_sorted %>%
  filter(!is.na(padj)) %>%
  filter(padj < 0.05) %>%
  filter(abs(log2FoldChange) >= 1)

write_csv(sig, file.path(out_tables, "DESeq2_significant_padj0.05_log2fc1.csv"))

# ---- Plots ----

# MA plot
pdf(file.path(out_figures, "MA_plot.pdf"))
plotMA(results(dds, contrast = c("condition","KO","WT")), ylim = c(-5, 5))
dev.off()

# Volcano plot
vol <- res_sorted %>%
  mutate(sig = ifelse(!is.na(padj) & padj < 0.05 & abs(log2FoldChange) >= 1, "sig", "ns"))

p <- ggplot(vol, aes(x = log2FoldChange, y = -log10(padj))) +
  geom_point(alpha = 0.5) +
  theme_minimal() +
  labs(title = "Volcano plot (KO vs WT)",
       x = "log2 Fold Change",
       y = "-log10(adjusted p-value)") +
  coord_cartesian(xlim = c(-8, 8)) +
  scale_y_continuous(limits = c(0, NA))

ggsave(file.path(out_figures, "Volcano_plot.pdf"), p, width = 7, height = 5)

# quick summary
cat("\n✅ Lab 5 complete\n")
cat("Total genes tested:", nrow(res_sorted), "\n")
cat("Significant genes (padj<0.05 & |log2FC|>=1):", nrow(sig), "\n")
cat("Tables:", out_tables, "\n")
cat("Figures:", out_figures, "\n")
