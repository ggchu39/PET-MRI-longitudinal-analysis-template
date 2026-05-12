# 05_change_score_models.R
# Change-score sensitivity models for the simulated PET/MRI/cognition dataset.
# This script demonstrates a simple longitudinal change analysis using simulated data only.

# ---- Setup ----

input_file <- "data_simulated/simulated_pet_mri_cognition_model_ready.csv"

if (!file.exists(input_file)) {
  stop(
    "Input file not found. Please run R/01_simulate_data.R, R/02_qc_checks.R, R/03_descriptives.R, and R/04_longitudinal_models.R first."
  )
}

if (!dir.exists("outputs/tables")) {
  dir.create("outputs/tables", recursive = TRUE)
}

if (!dir.exists("outputs/figures")) {
  dir.create("outputs/figures", recursive = TRUE)
}

analysis_data <- read.csv(input_file)

# ---- Check paired structure ----

timepoint_counts <- aggregate(
  timepoint ~ participant_id,
  data = analysis_data,
  FUN = function(x) length(unique(x))
)

names(timepoint_counts)[2] <- "n_timepoints"

if (any(timepoint_counts$n_timepoints != 2)) {
  stop(
    "Not all participants have exactly two timepoints. Please check the QC-paired dataset."
  )
}

# ---- Build wide-format change-score dataset ----

t1_data <- subset(analysis_data, timepoint == "T1")
t2_data <- subset(analysis_data, timepoint == "T2")

wide_data <- merge(
  t1_data,
  t2_data,
  by = "participant_id",
  suffixes = c("_T1", "_T2")
)

# ---- Compute change scores ----
# Change is calculated as T2 minus T1.

wide_data$delta_memory <- wide_data$memory_score_T2 -
  wide_data$memory_score_T1

wide_data$delta_pet_marker <- wide_data$pet_marker_bpnd_T2 -
  wide_data$pet_marker_bpnd_T1

wide_data$delta_mri_volume <- wide_data$mri_volume_index_T2 -
  wide_data$mri_volume_index_T1

# Percentage change is included as a simple sensitivity-style metric.

wide_data$percent_change_memory <- (
  wide_data$delta_memory / wide_data$memory_score_T1
) * 100

wide_data$percent_change_pet_marker <- (
  wide_data$delta_pet_marker / wide_data$pet_marker_bpnd_T1
) * 100

wide_data$percent_change_mri_volume <- (
  wide_data$delta_mri_volume / wide_data$mri_volume_index_T1
) * 100

# ---- Centre predictors ----

wide_data$age_baseline_c <- scale(
  wide_data$age_baseline_T1,
  center = TRUE,
  scale = FALSE
)[, 1]

wide_data$delta_pet_marker_c <- scale(
  wide_data$delta_pet_marker,
  center = TRUE,
  scale = FALSE
)[, 1]

wide_data$delta_mri_volume_c <- scale(
  wide_data$delta_mri_volume,
  center = TRUE,
  scale = FALSE
)[, 1]

wide_data$sex <- factor(wide_data$sex_T1)
wide_data$scanner_site <- factor(wide_data$scanner_site_T1)

# ---- Save wide change-score dataset ----

write.csv(
  wide_data,
  "data_simulated/simulated_pet_mri_cognition_change_scores.csv",
  row.names = FALSE
)

# ---- Change-score models ----

model_change_basic <- lm(
  delta_memory ~
    delta_pet_marker_c +
    delta_mri_volume_c +
    age_baseline_c +
    sex +
    scanner_site,
  data = wide_data
)

model_change_interaction <- lm(
  delta_memory ~
    delta_pet_marker_c * age_baseline_c +
    delta_mri_volume_c +
    sex +
    scanner_site,
  data = wide_data
)

model_percent_change <- lm(
  percent_change_memory ~
    percent_change_pet_marker +
    percent_change_mri_volume +
    age_baseline_c +
    sex +
    scanner_site,
  data = wide_data
)

# ---- Extract model summaries ----

extract_lm_fixed_effects <- function(model, model_name) {
  coef_table <- as.data.frame(summary(model)$coefficients)
  coef_table$term <- rownames(coef_table)
  rownames(coef_table) <- NULL

  names(coef_table) <- c(
    "estimate",
    "std_error",
    "t_value",
    "p_value",
    "term"
  )

  coef_table$model <- model_name

  coef_table <- coef_table[
    ,
    c("model", "term", "estimate", "std_error", "t_value", "p_value")
  ]

  coef_table$estimate <- round(coef_table$estimate, 4)
  coef_table$std_error <- round(coef_table$std_error, 4)
  coef_table$t_value <- round(coef_table$t_value, 3)
  coef_table$p_value <- signif(coef_table$p_value, 3)

  return(coef_table)
}

change_basic_effects <- extract_lm_fixed_effects(
  model_change_basic,
  "Model 1: Raw change-score model"
)

change_interaction_effects <- extract_lm_fixed_effects(
  model_change_interaction,
  "Model 2: Change-score PET by age interaction model"
)

percent_change_effects <- extract_lm_fixed_effects(
  model_percent_change,
  "Model 3: Percent-change sensitivity model"
)

change_model_effects_all <- rbind(
  change_basic_effects,
  change_interaction_effects,
  percent_change_effects
)

write.csv(
  change_model_effects_all,
  "outputs/tables/change_score_model_fixed_effects.csv",
  row.names = FALSE
)

# ---- Model comparison table ----

change_model_comparison <- data.frame(
  model = c(
    "Model 1: Raw change-score model",
    "Model 2: Change-score PET by age interaction model",
    "Model 3: Percent-change sensitivity model"
  ),
  n_observations = c(
    nobs(model_change_basic),
    nobs(model_change_interaction),
    nobs(model_percent_change)
  ),
  r_squared = c(
    summary(model_change_basic)$r.squared,
    summary(model_change_interaction)$r.squared,
    summary(model_percent_change)$r.squared
  ),
  adjusted_r_squared = c(
    summary(model_change_basic)$adj.r.squared,
    summary(model_change_interaction)$adj.r.squared,
    summary(model_percent_change)$adj.r.squared
  ),
  aic = c(
    AIC(model_change_basic),
    AIC(model_change_interaction),
    AIC(model_percent_change)
  ),
  bic = c(
    BIC(model_change_basic),
    BIC(model_change_interaction),
    BIC(model_percent_change)
  )
)

change_model_comparison$r_squared <- round(
  change_model_comparison$r_squared,
  3
)

change_model_comparison$adjusted_r_squared <- round(
  change_model_comparison$adjusted_r_squared,
  3
)

change_model_comparison$aic <- round(
  change_model_comparison$aic,
  2
)

change_model_comparison$bic <- round(
  change_model_comparison$bic,
  2
)

write.csv(
  change_model_comparison,
  "outputs/tables/change_score_model_comparison.csv",
  row.names = FALSE
)

# ---- Save model summaries as text ----

sink("outputs/tables/change_score_model_summaries.txt")

cat("Model 1: Raw change-score model\n")
cat("================================\n\n")
print(summary(model_change_basic))

cat("\n\nModel 2: Change-score PET by age interaction model\n")
cat("==================================================\n\n")
print(summary(model_change_interaction))

cat("\n\nModel 3: Percent-change sensitivity model\n")
cat("=========================================\n\n")
print(summary(model_percent_change))

sink()

# ---- Figure 8: Change in PET marker and change in memory ----

png(
  filename = "outputs/figures/figure_08_delta_pet_delta_memory.png",
  width = 1600,
  height = 1200,
  res = 200
)

plot(
  wide_data$delta_pet_marker,
  wide_data$delta_memory,
  main = "Change in simulated PET marker and change in memory",
  xlab = "Change in simulated PET marker BPND",
  ylab = "Change in memory score",
  pch = 19
)

abline(
  lm(delta_memory ~ delta_pet_marker, data = wide_data),
  lwd = 2
)

dev.off()

# ---- Figure 9: Change in MRI volume and change in memory ----

png(
  filename = "outputs/figures/figure_09_delta_mri_delta_memory.png",
  width = 1600,
  height = 1200,
  res = 200
)

plot(
  wide_data$delta_mri_volume,
  wide_data$delta_memory,
  main = "Change in simulated MRI volume index and change in memory",
  xlab = "Change in simulated MRI volume index",
  ylab = "Change in memory score",
  pch = 19
)

abline(
  lm(delta_memory ~ delta_mri_volume, data = wide_data),
  lwd = 2
)

dev.off()

# ---- Figure 10: Percent change in PET marker and memory ----

png(
  filename = "outputs/figures/figure_10_percent_change_pet_memory.png",
  width = 1600,
  height = 1200,
  res = 200
)

plot(
  wide_data$percent_change_pet_marker,
  wide_data$percent_change_memory,
  main = "Percent change in simulated PET marker and memory",
  xlab = "Percent change in simulated PET marker",
  ylab = "Percent change in memory score",
  pch = 19
)

abline(
  lm(percent_change_memory ~ percent_change_pet_marker, data = wide_data),
  lwd = 2
)

dev.off()

# ---- Console messages ----

message("Change-score models completed.")
message("Change-score dataset saved to data_simulated/simulated_pet_mri_cognition_change_scores.csv")
message("Model fixed effects saved to outputs/tables/change_score_model_fixed_effects.csv")
message("Model comparison saved to outputs/tables/change_score_model_comparison.csv")
message("Model summaries saved to outputs/tables/change_score_model_summaries.txt")
message("Figures saved to outputs/figures/")
