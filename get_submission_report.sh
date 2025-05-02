#!/bin/bash

#SBATCH --job-name=report     # Job name
#SBATCH --output=/dev/null
#SBATCH --error=/dev/null
#SBATCH --partition=vgl_a # Partition/queue to use
#SBATCH --account=vgl_condo_bank
#SBATCH --time=10:00:00
#SBATCH --mem=100G
#SBATCH --cpus-per-task=16


set -e  # Exit on any error

exec >"$LOGFILE" 2>&1
LOGFILE="report.log"

log() {
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[$timestamp] $1" | tee -a "$LOGFILE"
}

show_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Provide the files with the name format: tolid.hap#.cur.[date].fasta"
    echo
    echo "Options:"
    echo "  -a       hap1.fasta"
    echo "  -b       hap2.fasta"
    echo "  -h       Show this help message"
}

hap1=""
hap2=""

seqtk="/rugpfs/fs0/vgl/store/vglshare/tools/VGP-tools/seqtk/seqtk"
gfastats="/lustre/fs5/vgl/store/eduarte/programs/gfastats/build/bin/gfastats"

while getopts "a:b:h" opt; do
    case $opt in
        a) hap1=$OPTARG ;;
        b) hap2=$OPTARG ;;
        h) show_help; exit 0 ;;
        \?) echo "Invalid Option: -$OPTARG" >&2; show_help; exit 1 ;;
    esac
done

if [[ -z "$hap1" || -z "$hap2" ]]; then
    echo "Error: Both -a and -b options are required."
    show_help
    exit 1
fi

name1=$(basename "$hap1" | sed -E 's/\.(fasta|fa)$//')
name2=$(basename "$hap2" | sed -E 's/\.(fasta|fa)$//')
tolid=$(echo "$name1" | awk -F. '{print $1}')

log "Compressing input files..."
gzip -c "$hap1" > "$name1.gz"
gzip -c "$hap2" > "$name2.gz"

log "Activating conda environment..."
source /lustre/fs5/vgl/scratch/eduarte/miniconda3/etc/profile.d/conda.sh
conda activate /ru-auth/local/home/vgl_soft/miniconda3/envs/postcuration

log "Running post-curation script on hap1..."
python /lustre/fs4/vgl/store/vgl_soft/programs/curation/post-curation/chr_submission.py "$hap1" > "$name1.chromosomes.csv"

log "Running post-curation script on hap2..."
python /lustre/fs4/vgl/store/vgl_soft/programs/curation/post-curation/chr_submission.py "$hap2" > "$name2.chromosomes.csv"

log "Extracting scaffold names..."
awk -F, '{print $1}' "$name1.chromosomes.csv" > "$tolid.hap1.name.lst"
awk -F, '{print $1}' "$name2.chromosomes.csv" > "$tolid.hap2.name.lst"

log "Subsetting sequences with seqtk..."
$seqtk subseq "$hap1" "$tolid.hap1.name.lst" > "$tolid.hap1.SUPERS.fa"
$seqtk subseq "$hap2" "$tolid.hap2.name.lst" > "$tolid.hap2.SUPERS.fa"

log "Generating stats for SUPERS sequences..."
$gfastats "$tolid.hap1.SUPERS.fa" > "$tolid.hap1.SUPERS.stats"
$gfastats "$tolid.hap2.SUPERS.fa" > "$tolid.hap2.SUPERS.stats"

log "Generating stats for full haplotypes..."
$gfastats "$hap1" > "$name1.stats"
$gfastats "$hap2" > "$name2.stats"

log "Finished successfully!"
