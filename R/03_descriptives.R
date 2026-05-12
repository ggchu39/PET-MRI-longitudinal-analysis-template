# 03_descriptives.R
# Descriptive summaries and figures for the simulated PET/MRI/cognition dataset.
# This script uses the QC-cleaned paired dataset created by R/02_qc_checks.R.

# ---- Setup ----

input_file <- "data_simulated/simulated_pet_mri_cognition_qc_paired.csv"

if (!file.exists(input_file)) {
  stop(
    "Input file not found. Please run R/01_simulate_data.R and R/02_qc_checks.R first."
  )
}

if (!dir.exists("outputs/tables")) {
  dir.create("outputs/tables", recursive = TRUE)
}

if (!dir.exists("outputs/figures")) {
  dir.create("outputs/figures", recursive = TRUE)
}

analysis_data <- read.csv(input_file)

# ---- Basic sample summary ----

n_participants <- length(unique(analysis_data$participant_id))
n_rows <- nrow(analysis_data)

sample_summary <- data.frame(
  metric = c(
    "Participants with paired QC-included data",
    "Rows in paired analysis dataset",
    "Mean baseline age",
    "SD baseline age",
    "Minimum baseline age",
    "Maximum baseline age"
  ),
  value = c(
    n_participants,
    n_rows,
    round(mean(analysis_data$age_baseline), 2),
    round(sd(unique(analysis_data[, c("participant_id", "age_baseline")])$age_baseline), 2),
    min(analysis_data$age_baseline),
    max(analysis_data$age_baseline)
  )
)

write.csv(
  sample_summary,
  "outputs/tables/descriptive_sample_summary.csv",
  row.names = FALSE
)

# ---- Sex and site summaries ----

participant_level <- analysis_data[!duplicated(analysis_data$participant_id), ]

sex_summary <- as.data.frame(table(participant_level$sex))
names(sex_summary) <- c("sex", "n_participants")

sex_summary$percent <- round(
  sex_summary$n_participants / sum(sex_summary$n_participants) * 100,
  2
)

write.csv(
  sex_summary,
  "outputs/tables/descriptive_sex_summary.csv",
  row.names = FALSE
)

site_summary <- as.data.frame(table(participant_level$scanner_site))
names(site_summary) <- c("scanner_site", "n_participants")

site_summary$percent <- round(
  site_summary$n_participants / sum(site_summary$n_participants) * 100,
  2
)

write.csv(
  site_summary,
  "outputs/tables/descriptive_scanner_site_summary.csv",
  row.names = FALSE
)

# ---- Numeric summaries by timepoint ----

numeric_vars <- c(
  "pet_marker_bpnd",
  "mri_volume_index",
  "memory_score"
)

summary_by_timepoint <- do.call(
  rbind,
  lapply(numeric_vars, function(var_name) {
    do.call(
      rbind,
      lapply(split(analysis_data[[var_name]], analysis_data$timepoint), function(x) {
        data.frame(
          variable = var_name,
          n = length(x),
          mean = round(mean(x, na.rm = TRUE), 3),
          sd = round(sd(x, na.rm = TRUE), 3),
          median = round(median(x, na.rm = TRUE), 3),
          min = round(min(x, na.rm = TRUE), 3),
          max = round(max(x, na.rm = TRUE), 3)
        )
      })
    )
  })
)

summary_by_timepoint$timepoint <- rownames(summary_by_timepoint)
rownames(summary_by_timepoint) <- NULL

summary_by_timepoint <- summary_by_timepoint[
  ,
  c("variable", "timepoint", "n", "mean", "sd", "median", "min", "max")
]

write.csv(
  summary_by_timepoint,
  "outputs/tables/descriptive_numeric_by_timepoint.csv",
  row.names = FALSE
)

# ---- Figure 1: PET marker distribution ----

png(
  filename = "outputs/figures/figure_01_pet_marker_distribution.png",
  width = 1600,
  height = 1200,
  res = 200
)

hist(
  analysis_data$pet_marker_bpnd,
  breaks = 20,
  main = "Distribution of simulated PET marker",
  xlab = "Simulated PET marker BPND",
  ylab = "Frequency"
)

dev.off()

# ---- Figure 2: MRI volume index distribution ----

png(
  filename = "outputs/figures/figure_02_mri_volume_distribution.png",
  width = 1600,
  height = 1200,
  res = 200
)

hist(
  analysis_data$mri_volume_index,
  breaks = 20,
  main = "Distribution of simulated MRI volume index",
  xlab = "Simulated MRI volume index",
  ylab = "Frequency"
)

dev.off()

# ---- Figure 3: Memory score by timepoint ----

png(
  filename = "outputs/figures/figure_03_memory_by_timepoint.png",
  width = 1600,
  height = 1200,
  res = 200
)

boxplot(
  memory_score ~ timepoint,
  data = analysis_data,
  main = "Simulated memory score by timepoint",
  xlab = "Timepoint",
  ylab = "Memory score"
)

dev.off()

# ---- Figure 4: PET marker and memory score ----

png(
  filename = "outputs/figures/figure_04_pet_memory_scatter.png",
  width = 1600,
  height = 1200,
  res = 200
)

plot(
  analysis_data$pet_marker_bpnd,
  analysis_data$memory_score,
  main = "Simulated PET marker and memory score",
  xlab = "Simulated PET marker BPND",
  ylab = "Memory score",
  pch = 19
)

abline(
  lm(memory_score ~ pet_marker_bpnd, data = analysis_data),
  lwd = 2
)

dev.off()

# ---- Figure 5: Violin-style density plot of memory score by timepoint ----
# This uses base R density curves to avoid adding extra package dependencies.
# A ggplot2 violin version can be added later in the Quarto report.

png(
  filename = "outputs/figures/figure_05_memory_density_by_timepoint.png",
  width = 1600,
  height = 1200,
  res = 200
)

density_t1 <- density(
  analysis_data$memory_score[analysis_data$timepoint == "T1"],
  na.rm = TRUE
)

density_t2 <- density(
  analysis_data$memory_score[analysis_data$timepoint == "T2"],
  na.rm = TRUE
)

plot(
  density_t1,
  main = "Distribution of simulated memory score by timepoint",
  xlab = "Memory score",
  ylab = "Density",
  lwd = 2
)

lines(
  density_t2,
  lwd = 2,
  lty = 2
)

legend(
  "topright",
  legend = c("T1", "T2"),
  lty = c(1, 2),
  lwd = 2,
  bty = "n"
)

dev.off()


# ---- Console messages ----

message("Descriptive summaries completed.")
message("Tables saved to outputs/tables/")
message("Figures saved to outputs/figures/")
