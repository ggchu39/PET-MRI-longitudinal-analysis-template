
# 00_run_all.R
# Run the full simulated PET/MRI longitudinal analysis workflow.
# This script executes all analysis steps in order.

# ---- Workflow overview ----
# 01_simulate_data.R        Simulates PET/MRI/cognition data
# 02_qc_checks.R           Runs QC checks and paired completeness checks
# 03_descriptives.R        Creates descriptive summaries and figures
# 04_longitudinal_models.R Runs mixed-effects longitudinal models
# 05_change_score_models.R Runs change-score sensitivity models

# ---- Check working directory ----

required_paths <- c(
  "R/01_simulate_data.R",
  "R/02_qc_checks.R",
  "R/03_descriptives.R",
  "R/04_longitudinal_models.R",
  "R/05_change_score_models.R"
)

missing_paths <- required_paths[!file.exists(required_paths)]

if (length(missing_paths) > 0) {
  stop(
    paste(
      "The following required scripts are missing. Please run this file from the repository root:",
      paste(missing_paths, collapse = ", ")
    )
  )
}

# ---- Create output folders if needed ----

dir.create("data_simulated", showWarnings = FALSE, recursive = TRUE)
dir.create("outputs/tables", showWarnings = FALSE, recursive = TRUE)
dir.create("outputs/figures", showWarnings = FALSE, recursive = TRUE)

# ---- Run workflow ----

message("Starting full PET/MRI longitudinal analysis template workflow...")

message("Step 1/5: Simulating data")
source("R/01_simulate_data.R")

message("Step 2/5: Running QC checks")
source("R/02_qc_checks.R")

message("Step 3/5: Creating descriptives")
source("R/03_descriptives.R")

message("Step 4/5: Running longitudinal models")
source("R/04_longitudinal_models.R")

message("Step 5/5: Running change-score models")
source("R/05_change_score_models.R")

message("Workflow completed successfully.")
message("Tables are available in outputs/tables/")
message("Figures are available in outputs/figures/")
message("The Quarto report is available in reports/")
