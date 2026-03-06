import pandas as pd

base_path = "/home/babas/kaust_20CH/results/tables"

counts = pd.read_csv(f"{base_path}/counts_matrix.csv")
counts_no_zeros = pd.read_csv(f"{base_path}/counts_matrix_no_allzeros.csv")
deseq_all = pd.read_csv(f"{base_path}/DESeq2_all_genes.csv")
deseq_sig = pd.read_csv(f"{base_path}/DESeq2_significant_padj0.05_log2fc1.csv")

print("Samples:", counts.shape[1] - 1)
print("Genes:", counts.shape[0])
print("Conditions: WT vs KO")


