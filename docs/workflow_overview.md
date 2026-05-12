# Workflow Overview

To show how a longitudinal neuroimaging dataset can be organized, quality checked, analyzed, and reported in a transparent way without exposing real participant data or unpublished project materials.

## Repository purpose (portfolio template) designed to demonstrate:
- reproducible project organization;
- simulated PET/MRI/cognition data generation;
- neuroimaging-style quality-control logic;
- paired longitudinal completeness checks;
- descriptive summaries and figures;
- mixed-effects longitudinal modeling;
- within-person and between-person decomposition;
- change-score sensitivity analysis;
- Quarto-based reporting.

No real participant data, raw imaging files, private project outputs, or collaborator-owned results used.

## Workflow steps

The workflow is run from the repository root using:

```r
source("R/00_run_all.R")

**Step 1: Simulate data**
Script: R/01_simulate_data.R
The dataset includes generic variables representing:

participant ID;
timepoint;
baseline age;
sex;
scanner site;
simulated PET marker;
simulated MRI volume index;
simulated memory score;
registration QC flag;
motion QC flag;
processing QC flag.

Output: data_simulated/simulated_pet_mri_cognition.csv

**Step 2: Quality-control checks**
Script: R/02_qc_checks.R
It checks:

missingness;
implausible PET marker values;
implausible MRI volume values;
implausible memory scores;
registration QC failures;
motion QC failures;
processing QC exclusions;
paired T1/T2 completeness after QC.

Outputs include:
outputs/tables/qc_missingness_summary.csv
outputs/tables/qc_exclusion_summary.csv
outputs/tables/qc_paired_completeness_by_participant.csv
outputs/tables/qc_paired_summary.csv
data_simulated/simulated_pet_mri_cognition_with_qc.csv
data_simulated/simulated_pet_mri_cognition_qc_paired.csv

**Step 3: Descriptive summaries and figures**
Script: R/03_descriptives.R
This script creates sample summaries, scanner-site summaries, timepoint-specific descriptive statistics, and exploratory figures.

Outputs include:
outputs/tables/descriptive_sample_summary.csv
outputs/tables/descriptive_sex_summary.csv
outputs/tables/descriptive_scanner_site_summary.csv
outputs/tables/descriptive_numeric_by_timepoint.csv
outputs/figures/figure_01_pet_marker_distribution.png
outputs/figures/figure_02_mri_volume_distribution.png
outputs/figures/figure_03_memory_by_timepoint.png
outputs/figures/figure_04_pet_memory_scatter.png
outputs/figures/figure_05_memory_density_by_timepoint.png

**Step 4: Longitudinal mixed-effects models**
Script: R/04_longitudinal_models.R

This script fits mixed-effects models with participant-level random intercepts.

It demonstrates:

repeated-measures modelling;
PET/MRI/cognition brain–behaviour modelling;
adjustment for age, sex, and scanner site;
within-person and between-person PET marker decomposition;
PET marker by age interaction testing;
model comparison using AIC, BIC, and log-likelihood.

Outputs include:
data_simulated/simulated_pet_mri_cognition_model_ready.csv
outputs/tables/longitudinal_model_fixed_effects.csv
outputs/tables/longitudinal_model_comparison.csv
outputs/tables/longitudinal_model_summaries.txt
outputs/figures/figure_06_observed_vs_predicted_memory.png
outputs/figures/figure_07_predicted_memory_by_pet_marker.png

**Step 5: Change-score sensitivity analysis**
Script: R/05_change_score_models.R
This script restructures the paired longitudinal data into wide format and calculates change scores.

T2 minus T1 change-score calculation;
PET marker change;
MRI volume index change;
memory-score change;
percent-change sensitivity analysis;
PET-change by age interaction testing.

Outputs include:
data_simulated/simulated_pet_mri_cognition_change_scores.csv
outputs/tables/change_score_model_fixed_effects.csv
outputs/tables/change_score_model_comparison.csv
outputs/tables/change_score_model_summaries.txt
outputs/figures/figure_08_delta_pet_delta_memory.png
outputs/figures/figure_09_delta_mri_delta_memory.png
outputs/figures/figure_10_percent_change_pet_memory.png

**Step 6: Quarto report**
Report: reports/pet_mri_longitudinal_analysis_template.qmd

The Quarto report brings together the workflow outputs into a readable report.
It includes:
repository scope;
data protection statement;
QC summaries;
descriptive summaries;
figures;
longitudinal model tables;
change-score sensitivity model tables;
interpretation;
limitations.

This workflow is relevant because it:
organising longitudinal imaging-derived data;
documenting QC exclusions;
checking paired repeated-measures completeness;
modeling brain–behavior associations;
separating within-person and between-person effects;
reporting sensitivity analyses transparently;
producing reproducible reports.


**Limitations:**
This repository does not perform raw image preprocessing.
It does not include:
NIfTI files;
BIDS validation;
PET kinetic modeling;
PET partial-volume correction;
MRI segmentation;
image registration;
scanner harmonization;
FreeSurfer, FSL, AFNI, or SPM preprocessing scripts.

Instead, it focuses on the downstream statistical workflow after imaging-derived measures have been extracted and quality checked.

**The intended workflow is:**

source("R/00_run_all.R")

quarto render reports/pet_mri_longitudinal_analysis_template.qmd











