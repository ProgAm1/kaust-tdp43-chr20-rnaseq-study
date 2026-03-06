import pandas as pd
import numpy as np

# عدّل المسار حسب ملفك الصحيح (counts_matrix أفضل من DESeq2_all_genes)
INPUT_CSV = "results/tables/counts_matrix.csv"  # <- غيّره لو ملفك اسمه مختلف

df = pd.read_csv(INPUT_CSV)

# إذا أول عمود هو gene_id/Unnamed: 0 خله index
first_col = df.columns[0]
if first_col.lower() in ["gene", "gene_id", "geneid", "unnamed: 0"]:
    df = df.set_index(first_col)

# أعمدة ليست عينات (استبعدها لو كانت موجودة)
non_sample_cols = {
    "baseMean", "log2FoldChange", "lfcSE", "stat", "pvalue", "padj",
    "gene", "gene_id", "Geneid", "symbol", "chr", "start", "end", "strand"
}

candidate_cols = [c for c in df.columns if c not in non_sample_cols]

# حاول تحويل كل الأعمدة المرشّحة لأرقام حتى لو كانت نصوص
numeric_sample_cols = []
for c in candidate_cols:
    s = (df[c].astype(str)
              .str.replace(",", "", regex=False)   # يشيل فاصلة الآلاف 1,234
              .str.strip()
              .replace({"nan": np.nan, "NA": np.nan, "NaN": np.nan, "": np.nan}))
    s_num = pd.to_numeric(s, errors="coerce")
    # اعتبره عمود عينة إذا فيه قيم رقمية كفاية
    if s_num.notna().sum() > 0:
        df[c] = s_num
        numeric_sample_cols.append(c)

if not numeric_sample_cols:
    raise ValueError(
        "No numeric sample columns detected after coercion.\n"
        f"Columns found: {list(df.columns)[:30]}\n"
        "If this is a DESeq2 results table (baseMean/log2FoldChange/padj...), "
        "it won't contain sample counts. Use a counts matrix instead."
    )

print("Detected sample columns:", numeric_sample_cols)

# استخدم فقط أعمدة العينات في أي QC بعد كذا
counts = df[numeric_sample_cols].fillna(0)

# مثال: library size per sample
lib_sizes = counts.sum(axis=0)
print("Library sizes:\n", lib_sizes.sort_values(ascending=False))

