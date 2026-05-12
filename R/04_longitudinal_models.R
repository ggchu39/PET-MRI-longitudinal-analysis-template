# 04_longitudinal_models.R
# Longitudinal mixed-effects models for the simulated PET/MRI/cognition dataset.
# This script demonstrates repeated-measures brain–behaviour modelling using simulated data only.

# ---- Setup ----

input_file <- "data_simulated/simulated_pet_mri_cognition_qc_paired.csv"

if (!file.exists(input_file)) {
  stop(
    "Input file not found. Please run R/01_simulate_data.R, R/02_qc_checks.R, and R/03_descriptives.R first."
  )
}

if (!dir.exists("outputs/tables")) {
  dir.create("outputs/tables", recursive = TRUE)
}

if (!dir.exists("outputs/figures")) {
  dir.create("outputs/figures", recursive = TRUE)
}

analysis_data <- read.csv(input_file)

# ---- Check required package ----

if (!requireNamespace("lme4", quietly = TRUE)) {
  stop(
    "Package 'lme4' is required for this script. Please install it using install.packages('lme4')."
  )
}

# ---- Prepare variables ----

analysis_data$participant_id <- factor(analysis_data$participant_id)
analysis_data$timepoint <- factor(
  analysis_data$timepoint,
  levels = c("T1", "T2")
)

analysis_data$sex <- factor(analysis_data$sex)
analysis_data$scanner_site <- factor(analysis_data$scanner_site)

# Centre continuous predictors for interpretability

analysis_data$age_baseline_c <- scale(
  analysis_data$age_baseline,
  center = TRUE,
  scale = FALSE
)[, 1]

analysis_data$pet_marker_bpnd_c <- scale(
  analysis_data$pet_marker_bpnd,
  center = TRUE,
  scale = FALSE
)[, 1]

analysis_data$mri_volume_index_c <- scale(
  analysis_data$mri_volume_index,
  center = TRUE,
  scale = FALSE
)[, 1]

# ---- Within-person and between-person decomposition ----
# This separates within-person PET variation over time from between-person differences.

participant_pet_mean <- aggregate(
  pet_marker_bpnd ~ participant_id,
  data = analysis_data,
  FUN = mean
)

names(participant_pet_mean)[2] <- "pet_marker_person_mean"

analysis_data <- merge(
  analysis_data,
  participant_pet_mean,
  by = "participant_id"
)

analysis_data$pet_marker_within_person <- analysis_data$pet_marker_bpnd -
  analysis_data$pet_marker_person_mean

analysis_data$pet_marker_between_person <- scale(
  analysis_data$pet_marker_person_mean,
  center = TRUE,
  scale = FALSE
)[, 1]

# Save modelling-ready dataset

write.csv(
  analysis_data,
  "data_simulated/simulated_pet_mri_cognition_model_ready.csv",
  row.names = FALSE
)

# ---- Model 1: Basic longitudinal model ----
# Memory as a function of time, PET marker, age, sex, MRI volume, and scanner site.

model_basic <- lme4::lmer(
  memory_score ~
    time_numeric +
    pet_marker_bpnd_c +
    mri_volume_index_c +
    age_baseline_c +
    sex +
    scanner_site +
    (1 | participant_id),
  data = analysis_data,
  REML = FALSE
)

# ---- Model 2: Within-person / between-person PET model ----
# This is the stronger longitudinal specification.

model_within_between <- lme4::lmer(
  memory_score ~
    time_numeric +
    pet_marker_within_person +
    pet_marker_between_person +
    mri_volume_index_c +
    age_baseline_c +
    sex +
    scanner_site +
    (1 | participant_id),
  data = analysis_data,
  REML = FALSE
)

# ---- Model 3: PET by age interaction model ----
# This tests whether the PET-memory association differs by baseline age.

model_pet_age_interaction <- lme4::lmer(
  memory_score ~
    time_numeric +
    pet_marker_bpnd_c * age_baseline_c +
    mri_volume_index_c +
    sex +
    scanner_site +
    (1 | participant_id),
  data = analysis_data,
  REML = FALSE
)

# ---- Extract model summaries ----

extract_lmer_fixed_effects <- function(model, model_name) {
  coef_table <- as.data.frame(summary(model)$coefficients)
  coef_table$term <- rownames(coef_table)
  rownames(coef_table) <- NULL

  names(coef_table) <- c(
    "estimate",
    "std_error",
    "t_value",
    "term"
  )

  coef_table$model <- model_name

  coef_table <- coef_table[
    ,
    c("model", "term", "estimate", "std_error", "t_value")
  ]

  coef_table$estimate <- round(coef_table$estimate, 4)
  coef_table$std_error <- round(coef_table$std_error, 4)
  coef_table$t_value <- round(coef_table$t_value, 3)

  return(coef_table)
}

fixed_basic <- extract_lmer_fixed_effects(
  model_basic,
  "Model 1: Basic longitudinal model"
)

fixed_within_between <- extract_lmer_fixed_effects(
  model_within_between,
  "Model 2: Within-person / between-person PET model"
)

fixed_interaction <- extract_lmer_fixed_effects(
  model_pet_age_interaction,
  "Model 3: PET by age interaction model"
)

fixed_effects_all <- rbind(
  fixed_basic,
  fixed_within_between,
  fixed_interaction
)

write.csv(
  fixed_effects_all,
  "outputs/tables/longitudinal_model_fixed_effects.csv",
  row.names = FALSE
)

# ---- Model comparison table ----

model_comparison <- data.frame(
  model = c(
    "Model 1: Basic longitudinal model",
    "Model 2: Within-person / between-person PET model",
    "Model 3: PET by age interaction model"
  ),
  n_observations = c(
    nobs(model_basic),
    nobs(model_within_between),
    nobs(model_pet_age_interaction)
  ),
  aic = c(
    AIC(model_basic),
    AIC(model_within_between),
    AIC(model_pet_age_interaction)
  ),
  bic = c(
    BIC(model_basic),
    BIC(model_within_between),
    BIC(model_pet_age_interaction)
  ),
  log_likelihood = c(
    as.numeric(logLik(model_basic)),
    as.numeric(logLik(model_within_between)),
    as.numeric(logLik(model_pet_age_interaction))
  )
)

model_comparison$aic <- round(model_comparison$aic, 2)
model_comparison$bic <- round(model_comparison$bic, 2)
model_comparison$log_likelihood <- round(model_comparison$log_likelihood, 2)

write.csv(
  model_comparison,
  "outputs/tables/longitudinal_model_comparison.csv",
  row.names = FALSE
)

# ---- Save model summaries as text ----

sink("outputs/tables/longitudinal_model_summaries.txt")

cat("Model 1: Basic longitudinal model\n")
cat("=================================\n\n")
print(summary(model_basic))

cat("\n\nModel 2: Within-person / between-person PET model\n")
cat("=================================================\n\n")
print(summary(model_within_between))

cat("\n\nModel 3: PET by age interaction model\n")
cat("=====================================\n\n")
print(summary(model_pet_age_interaction))

sink()

# ---- Diagnostic-style observed vs predicted plot ----

analysis_data$predicted_memory_basic <- predict(model_basic)

png(
  filename = "outputs/figures/figure_06_observed_vs_predicted_memory.png",
  width = 1600,
  height = 1200,
  res = 200
)

plot(
  analysis_data$memory_score,
  analysis_data$predicted_memory_basic,
  main = "Observed vs predicted memory score",
  xlab = "Observed memory score",
  ylab = "Predicted memory score",
  pch = 19
)

abline(
  a = 0,
  b = 1,
  lwd = 2,
  lty = 2
)

dev.off()

# ---- Prediction plot across PET marker ----

new_data <- data.frame(
  time_numeric = 0,
  pet_marker_bpnd_c = seq(
    min(analysis_data$pet_marker_bpnd_c),
    max(analysis_data$pet_marker_bpnd_c),
    length.out = 100
  ),
  mri_volume_index_c = 0,
  age_baseline_c = 0,
  sex = levels(analysis_data$sex)[1],
  scanner_site = levels(analysis_data$scanner_site)[1],
  participant_id = analysis_data$participant_id[1]
)

new_data$predicted_memory <- predict(
  model_basic,
  newdata = new_data,
  re.form = NA
)

png(
  filename = "outputs/figures/figure_07_predicted_memory_by_pet_marker.png",
  width = 1600,
  height = 1200,
  res = 200
)

plot(
  new_data$pet_marker_bpnd_c,
  new_data$predicted_memory,
  type = "l",
  lwd = 2,
  main = "Predicted memory score by simulated PET marker",
  xlab = "Centred simulated PET marker BPND",
  ylab = "Predicted memory score"
)

dev.off()

# ---- Console messages ----

message("Longitudinal mixed-effects models completed.")
message("Model fixed effects saved to outputs/tables/longitudinal_model_fixed_effects.csv")
message("Model comparison saved to outputs/tables/longitudinal_model_comparison.csv")
message("Model summaries saved to outputs/tables/longitudinal_model_summaries.txt")
message("Figures saved to outputs/figures/")
