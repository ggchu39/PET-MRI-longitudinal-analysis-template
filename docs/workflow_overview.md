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
