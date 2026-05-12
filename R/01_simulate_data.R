# 01_simulate_data.R
# Simulate a small longitudinal PET/MRI/cognition dataset for portfolio demonstration.
# No real participant data are used.

set.seed(20260512)

n_participants <- 120

participants <- data.frame(
  participant_id = sprintf("P%03d", 1:n_participants),
  age_baseline = round(runif(n_participants, 45, 80), 1),
  sex = sample(c("Female", "Male"), n_participants, replace = TRUE),
  scanner_site = sample(c("Site_A", "Site_B"), n_participants, replace = TRUE)
)

long_data <- do.call(
  rbind,
  lapply(1:n_participants, function(i) {
    baseline_age <- participants$age_baseline[i]
    sex_i <- participants$sex[i]
    site_i <- participants$scanner_site[i]
    id_i <- participants$participant_id[i]

    data.frame(
      participant_id = id_i,
      timepoint = c("T1", "T2"),
      time_numeric = c(0, 1),
      age_baseline = baseline_age,
      sex = sex_i,
      scanner_site = site_i
    )
  })
)

# Simulate generic PET and MRI markers
long_data$pet_marker_bpnd <- round(
  2.2 -
    0.008 * long_data$age_baseline -
    0.06 * long_data$time_numeric +
    rnorm(nrow(long_data), 0, 0.12),
  3
)

long_data$mri_volume_index <- round(
  1.0 -
    0.003 * long_data$age_baseline -
    0.015 * long_data$time_numeric +
    rnorm(nrow(long_data), 0, 0.05),
  3
)

# Simulate cognitive score related to age, PET marker, MRI marker and time
long_data$memory_score <- round(
  55 -
    0.18 * long_data$age_baseline +
    4.5 * long_data$pet_marker_bpnd +
    5.0 * long_data$mri_volume_index -
    0.8 * long_data$time_numeric +
    rnorm(nrow(long_data), 0, 4),
  2
)

# Simulate simple QC flags
long_data$registration_qc <- sample(
  c("pass", "review", "fail"),
  nrow(long_data),
  replace = TRUE,
  prob = c(0.88, 0.08, 0.04)
)

long_data$motion_qc <- sample(
  c("pass", "review", "fail"),
  nrow(long_data),
  replace = TRUE,
  prob = c(0.85, 0.10, 0.05)
)

long_data$processing_qc <- ifelse(
  long_data$registration_qc == "fail" | long_data$motion_qc == "fail",
  "exclude",
  "include"
)

# Save simulated data
if (!dir.exists("data_simulated")) {
  dir.create("data_simulated")
}

write.csv(
  long_data,
  "data_simulated/simulated_pet_mri_cognition.csv",
  row.names = FALSE
)

message("Simulated PET/MRI/cognition dataset saved to data_simulated/")
