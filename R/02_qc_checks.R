

# 02_qc_checks.R
# Quality-control checks for the simulated PET/MRI/cognition dataset.
# This script demonstrates neuroimaging-style QC logic using simulated data only.

# ---- Setup ----

input_file <- "data_simulated/simulated_pet_mri_cognition.csv"

if (!file.exists(input_file)) {
  stop(
    "Input file not found. Please run R/01_simulate_data.R first."
  )
}

if (!dir.exists("outputs")) {
  dir.create("outputs")
}

if (!dir.exists("outputs/tables")) {
  dir.create("outputs/tables", recursive = TRUE)
}

qc_data <- read.csv(input_file)

# ---- Basic structure checks ----

required_vars <- c(
  "participant_id",
  "timepoint",
  "time_numeric",
  "age_baseline",
  "sex",
  "scanner_site",
  "pet_marker_bpnd",
  "mri_volume_index",
  "memory_score",
  "registration_qc",
  "motion_qc",
  "processing_qc"
)

missing_vars <- setdiff(required_vars, names(qc_data))

if (length(missing_vars) > 0) {
  stop(
    paste(
      "The following required variables are missing:",
      paste(missing_vars, collapse = ", ")
    )
  )
}

# ---- Missingness checks ----

missingness_summary <- data.frame(
  variable = names(qc_data),
  n_missing = sapply(qc_data, function(x) sum(is.na(x))),
  percent_missing = round(
    sapply(qc_data, function(x) mean(is.na(x)) * 100),
    2
  )
)

write.csv(
  missingness_summary,
  "outputs/tables/qc_missingness_summary.csv",
  row.names = FALSE
)

# ---- Implausible value checks ----
# These are generic demonstration thresholds, not clinical or scanner-specific thresholds.

qc_data$flag_implausible_pet <- qc_data$pet_marker_bpnd < 0 |
  qc_data$pet_marker_bpnd > 5

qc_data$flag_implausible_mri <- qc_data$mri_volume_index < 0.4 |
  qc_data$mri_volume_index > 1.4

qc_data$flag_implausible_memory <- qc_data$memory_score < 0 |
  qc_data$memory_score > 100

# ---- Neuroimaging-style QC exclusion logic ----

qc_data$exclude_registration <- qc_data$registration_qc == "fail"
qc_data$exclude_motion <- qc_data$motion_qc == "fail"
qc_data$exclude_processing <- qc_data$processing_qc == "exclude"

qc_data$exclude_implausible_value <- qc_data$flag_implausible_pet |
  qc_data$flag_implausible_mri |
  qc_data$flag_implausible_memory

qc_data$exclude_any <- qc_data$exclude_registration |
  qc_data$exclude_motion |
  qc_data$exclude_processing |
  qc_data$exclude_implausible_value

qc_data$qc_status <- ifelse(qc_data$exclude_any, "exclude", "include")

# ---- QC summary table ----

qc_summary <- data.frame(
  qc_reason = c(
    "Registration QC fail",
    "Motion QC fail",
    "Processing QC exclude",
    "Implausible PET marker",
    "Implausible MRI marker",
    "Implausible memory score",
    "Excluded for any reason",
    "Included after QC"
  ),
  n_rows = c(
    sum(qc_data$exclude_registration),
    sum(qc_data$exclude_motion),
    sum(qc_data$exclude_processing),
    sum(qc_data$flag_implausible_pet),
    sum(qc_data$flag_implausible_mri),
    sum(qc_data$flag_implausible_memory),
    sum(qc_data$exclude_any),
    sum(qc_data$qc_status == "include")
  )
)

qc_summary$percent_rows <- round(
  qc_summary$n_rows / nrow(qc_data) * 100,
  2
)

write.csv(
  qc_summary,
  "outputs/tables/qc_exclusion_summary.csv",
  row.names = FALSE
)

# ---- Paired longitudinal completeness checks ----

included_data <- subset(qc_data, qc_status == "include")

participant_time_counts <- aggregate(
  timepoint ~ participant_id,
  data = included_data,
  FUN = function(x) length(unique(x))
)

names(participant_time_counts)[2] <- "n_valid_timepoints"

participant_time_counts$paired_complete <- participant_time_counts$n_valid_timepoints == 2

write.csv(
  participant_time_counts,
  "outputs/tables/qc_paired_completeness_by_participant.csv",
  row.names = FALSE
)

paired_summary <- data.frame(
  metric = c(
    "Participants in raw dataset",
    "Participants with at least one QC-included timepoint",
    "Participants with complete paired QC-included data",
    "Rows in raw dataset",
    "Rows included after QC",
    "Rows excluded after QC"
  ),
  value = c(
    length(unique(qc_data$participant_id)),
    length(unique(included_data$participant_id)),
    sum(participant_time_counts$paired_complete),
    nrow(qc_data),
    nrow(included_data),
    sum(qc_data$qc_status == "exclude")
  )
)

write.csv(
  paired_summary,
  "outputs/tables/qc_paired_summary.csv",
  row.names = FALSE
)

# ---- Save QC-cleaned data ----

write.csv(
  qc_data,
  "data_simulated/simulated_pet_mri_cognition_with_qc.csv",
  row.names = FALSE
)

paired_ids <- participant_time_counts$participant_id[
  participant_time_counts$paired_complete
]

paired_clean_data <- subset(
  included_data,
  participant_id %in% paired_ids
)

write.csv(
  paired_clean_data,
  "data_simulated/simulated_pet_mri_cognition_qc_paired.csv",
  row.names = FALSE
)

# ---- Console messages ----

message("QC checks completed.")
message("QC summary saved to outputs/tables/qc_exclusion_summary.csv")
message("Paired completeness summary saved to outputs/tables/qc_paired_summary.csv")
message("QC-cleaned paired dataset saved to data_simulated/simulated_pet_mri_cognition_qc_paired.csv")
