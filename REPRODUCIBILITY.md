# Reproducibility

This repository is designed as a reproducible R/Quarto workflow using simulated data only.

No real participant data, clinical data, raw PET/MRI files, unpublished project outputs, or collaborator-owned results are included.

## Software requirements

The workflow requires:

- R
- Quarto
- R package: `lme4`

Optional but useful:

- RStudio
- Git
- GitHub Desktop

## How to regenerate the workflow

From the repository root, run:

```r
source("R/00_run_all.R")

This will regenerate:

simulated data files in data_simulated/;
quality-control summaries in outputs/tables/;
descriptive summaries in outputs/tables/;
model summaries in outputs/tables/;
figures in outputs/figures/.

After running the full R workflow, render the report with:
quarto render reports/pet_mri_longitudinal_analysis_template.qmd

The rendered report summarises the simulated dataset, QC workflow, descriptive outputs, longitudinal models, change-score sensitivity analyses, interpretation, and limitations.

Reproducibility design

The workflow is intentionally organised as separate scripts:

| Script                       | Purpose                                   |
| ---------------------------- | ----------------------------------------- |
| `R/00_run_all.R`             | Runs the full workflow                    |
| `R/01_simulate_data.R`       | Simulates the dataset                     |
| `R/02_qc_checks.R`           | Applies QC checks                         |
| `R/03_descriptives.R`        | Creates descriptive summaries and figures |
| `R/04_longitudinal_models.R` | Fits longitudinal mixed-effects models    |
| `R/05_change_score_models.R` | Runs change-score sensitivity models      |

**Random seed**
The simulated dataset is generated with a fixed random seed in R/01_simulate_data.R.

Data protection

All data are simulated.

The repository does not include:

real participant-level data;
clinical information;
raw neuroimaging files;
NIfTI images;
protected screenshots;
unpublished collaborator materials;
supervisor-specific files;
private analysis outputs.
Limitations

This repository demonstrates downstream statistical workflow structure.

It does not perform:

raw PET preprocessing;
PET kinetic modelling;
partial-volume correction;
MRI segmentation;
image registration;
BIDS validation;
scanner harmonisation;
FreeSurfer, FSL, AFNI, or SPM preprocessing.

The purpose is to demonstrate transparent organisation, QC tracking, longitudinal modelling, sensitivity analysis, and Quarto-based reporting using simulated data.








