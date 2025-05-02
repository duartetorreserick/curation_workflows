Certainly! Here's a GitHub-style `README.md` you can include directly in your repository:

---

# 🧬 get_submission_report.sh

This Bash script performs a structured post-curation process for two genome assemblies (haplotypes). It compresses inputs, identifies chromosome-scale scaffolds, subsets sequences, and generates summary statistics using `seqtk` and `gfastats`. Designed to run on SLURM-based HPC systems.

---

## 🚀 Quick Start

```bash
sbatch report.sh -a hap1.fasta -b hap2.fasta
```

> ⚠️ Input FASTA files must follow the format: `tolid.hap#.cur.[date].fasta`

---
Modify these parameters as needed for your HPC environment.
---

## 📥 Options

| Flag | Description                      |
|------|----------------------------------|
| `-a` | Path to haplotype 1 FASTA file   |
| `-b` | Path to haplotype 2 FASTA file   |
| `-h` | Show help message                |

---

## 🔄 Workflow Overview

1. **Input Parsing**  
   Validates the input files and extracts TOLID and filenames.

2. **Compression**  
   Compresses the original FASTA files using `gzip`.

3. **Environment Activation**  
   Loads Conda environment for running post-curation scripts.

4. **Post-Curation Chromosome Analysis**  
   Uses `chr_submission.py` to identify chromosome-scale scaffolds.

5. **Sequence Subsetting**  
   Extracts identified scaffolds from each haplotype with `seqtk`.

6. **Statistical Reporting**  
   Generates `.stats` reports with `gfastats` for both full and subset sequences.

7. **Logging**  
   Logs progress and timestamps in `report.log`.

---

## 📂 Output Files

- `*.gz` – Compressed input FASTA files  
- `*.chromosomes.csv` – Scaffold summary from post-curation script  
- `*.name.lst` – List of chromosome-scale scaffold names  
- `*.SUPERS.fa` – FASTA files with only chromosome-scale scaffolds  
- `*.SUPERS.stats` – Stats for SUPERS sequences  
- `*.stats` – Stats for full haplotype assemblies  
- `report.log` – Log file with step-by-step progress  

---

## 📦 Dependencies

Ensure the following tools are available and paths are correctly set within the script:

- [`seqtk`](https://github.com/lh3/seqtk)
- [`gfastats`](https://github.com/vgl-hub/gfastats)
- Conda environment with `chr_submission.py` and its dependencies

---
