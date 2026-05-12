# Data Dictionary

This repository uses simulated data only. The dataset is designed to demonstrate a reproducible PET/MRI-style longitudinal analysis workflow using generic variables.

No real participant data, clinical data, raw neuroimaging files, private project outputs, or unpublished collaborator materials are included.

## Simulated dataset

Main file:

```text
data_simulated/simulated_pet_mri_cognition.csv


data_simulated/simulated_pet_mri_cognition_with_qc.csv
data_simulated/simulated_pet_mri_cognition_qc_paired.csv
data_simulated/simulated_pet_mri_cognition_model_ready.csv
data_simulated/simulated_pet_mri_cognition_change_scores.csv


| Variable                    | Description                           | Type        | Notes                                           |
| --------------------------- | ------------------------------------- | ----------- | ----------------------------------------------- |
| `participant_id`            | Simulated participant identifier      | Character   | Artificial ID only; not linked to real people   |
| `timepoint`                 | Assessment timepoint                  | Categorical | `T1` and `T2`                                   |
| `time_numeric`              | Numeric time variable                 | Numeric     | `0 = T1`, `1 = T2`                              |
| `age_baseline`              | Simulated baseline age                | Numeric     | Generated for demonstration                     |
| `sex`                       | Simulated sex variable                | Categorical | `Female` or `Male`; used as a generic covariate |
| `scanner_site`              | Simulated scanner/site label          | Categorical | `Site_A` or `Site_B`                            |
| `pet_marker_bpnd`           | Simulated PET marker                  | Numeric     | Generic binding-potential-style variable        |
| `mri_volume_index`          | Simulated MRI-derived volume index    | Numeric     | Generic structural MRI-style measure            |
| `memory_score`              | Simulated cognitive score             | Numeric     | Generic memory-style outcome                    |
| `registration_qc`           | Simulated registration QC flag        | Categorical | `pass`, `review`, or `fail`                     |
| `motion_qc`                 | Simulated motion QC flag              | Categorical | `pass`, `review`, or `fail`                     |
| `processing_qc`             | Simulated processing inclusion flag   | Categorical | `include` or `exclude`                          |
| `qc_status`                 | Final QC inclusion status             | Categorical | Created in `R/02_qc_checks.R`                   |
| `flag_implausible_pet`      | Implausible PET marker flag           | Logical     | Demonstration threshold only                    |
| `flag_implausible_mri`      | Implausible MRI marker flag           | Logical     | Demonstration threshold only                    |
| `flag_implausible_memory`   | Implausible memory score flag         | Logical     | Demonstration threshold only                    |
| `pet_marker_person_mean`    | Participant mean PET marker           | Numeric     | Used for between-person decomposition           |
| `pet_marker_within_person`  | PET deviation from participant mean   | Numeric     | Used for within-person modelling                |
| `pet_marker_between_person` | Centred participant mean PET marker   | Numeric     | Used for between-person modelling               |
| `delta_memory`              | Change in memory score                | Numeric     | T2 minus T1                                     |
| `delta_pet_marker`          | Change in PET marker                  | Numeric     | T2 minus T1                                     |
| `delta_mri_volume`          | Change in MRI volume index            | Numeric     | T2 minus T1                                     |
| `percent_change_memory`     | Percentage change in memory score     | Numeric     | Used for sensitivity analysis                   |
| `percent_change_pet_marker` | Percentage change in PET marker       | Numeric     | Used for sensitivity analysis                   |
| `percent_change_mri_volume` | Percentage change in MRI volume index | Numeric     | Used for sensitivity analysis                   |

**QC logic: **
Exclude if registration QC failed.
Exclude if motion QC failed.
Exclude if processing QC indicates exclusion.
Flag implausible PET, MRI, or memory values using generic thresholds.
Check whether each participant has complete paired T1/T2 data after QC.

**Analysis scope:**
Descriptive summaries and figures.
Longitudinal mixed-effects models.
Change-score sensitivity models.







