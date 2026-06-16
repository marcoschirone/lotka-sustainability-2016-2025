# ============================================================================
# LOTKA ANALYSIS — Scopus Author IDs + EIDs
# Years: 2016–2025
# Poster STI 2026
# ============================================================================

library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(poweRlaw)

# ============================================================================
# MODULE 1 — LOAD & CLEAN DATA
# ============================================================================

# Raw Scopus export (proprietary — NOT included in this repository).
# Place your copy in data/ or edit this path to your local file location.
file_path <- "data/STI 2026 Poster Data 2016-2025.xlsx"

raw <- read_excel(file_path)

data <- raw %>%
  select(EID, `Scopus Author Ids`, Year) %>%
  filter(!is.na(EID),
         !is.na(`Scopus Author Ids`))

# ============================================================================
# MODULE 2 — EXPLODE AUTHOR IDS (ONE ROW PER AUTHOR × PAPER)
# ============================================================================

data_long <- data %>%
  mutate(AuthorID = str_split(`Scopus Author Ids`, "\\|")) %>%
  unnest(AuthorID) %>%
  mutate(AuthorID = str_trim(AuthorID)) %>%
  filter(AuthorID != "")

# Ensure each author–publication pair is counted only once
author_papers <- data_long %>%
  distinct(EID, AuthorID)

# ============================================================================
# MODULE 3 — AUTHOR PRODUCTIVITY
# ============================================================================

author_prod <- author_papers %>%
  count(AuthorID, name = "n_pubs")

lotka_freq <- author_prod %>%
  count(n_pubs, name = "n_authors") %>%
  arrange(n_pubs)

# ============================================================================
# MODULE 4 — SUMMARY STATISTICS
# ============================================================================

total_authors <- sum(lotka_freq$n_authors)
total_papers  <- sum(lotka_freq$n_pubs * lotka_freq$n_authors)
mean_prod     <- total_papers / total_authors

cat("Total authors:", total_authors, "\n")
cat("Total unique papers:", length(unique(author_papers$EID)), "\n")
cat("Total authored counts:", total_papers, "\n")
cat("Mean productivity:", round(mean_prod, 3), "\n\n")

# ============================================================================
# MODULE 5 — LOG–LOG PRODUCTIVITY PLOT
# ============================================================================

p1 <- ggplot(lotka_freq, aes(x = n_pubs, y = n_authors)) +
  geom_point(colour = "#F46821", size = 2.2, alpha = 0.85) +
  scale_x_log10() +
  scale_y_log10() +
  labs(
    x = "Papers per author (n)",
    y = "Number of authors",
    title = "Author Productivity Distribution (2016–2025)",
    subtitle = paste0("N = ", total_authors,
                      " | Mean = ", round(mean_prod, 2))
  ) +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(face = "bold"))

print(p1)

ggsave("lotka_loglog_2016_2025.png",
       p1, width = 7, height = 5, dpi = 300)

# ============================================================================
# MODULE 6 — POWER-LAW FIT (poweRlaw)
# ============================================================================

m <- displ$new(author_prod$n_pubs)

est <- estimate_xmin(m)
m$setXmin(est)
m$setPars(estimate_pars(m))

xmin  <- m$getXmin()
alpha <- m$getPars()

cat("Estimated xmin:", xmin, "\n")
cat("Estimated alpha:", alpha, "\n\n")

# Goodness-of-fit
set.seed(123)
gof <- bootstrap_p(m, no_of_sims = 500)

cat("GOF p-value:", gof$p, "\n\n")

# ============================================================================
# MODULE 7 — COMPARE WITH LOGNORMAL
# ============================================================================

ln <- dislnorm$new(author_prod$n_pubs)
ln$setXmin(xmin)
ln$setPars(estimate_pars(ln))

comp <- compare_distributions(m, ln)

cat("Vuong test statistic:", comp$test_statistic, "\n")
cat("Vuong two-sided p-value:", comp$p_two_sided, "\n\n")

# ============================================================================
# MODULE 8 — OBSERVED VS POWER-LAW OVERLAY
# ============================================================================

pred <- lotka_freq %>%
  filter(n_pubs >= xmin) %>%
  mutate(
    weight = n_pubs^(-alpha),
    pred_authors = sum(n_authors) * weight / sum(weight)
  )

p2 <- ggplot(pred, aes(x = n_pubs)) +
  geom_point(aes(y = n_authors),
             colour = "#F46821", size = 2.2) +
  geom_line(aes(y = pred_authors),
            colour = "#29BEFD", linewidth = 1.2) +
  geom_vline(xintercept = xmin,
             linetype = "dashed",
             colour = "grey40") +
  scale_x_log10() +
  scale_y_log10() +
  labs(
    x = "Papers per author (n)",
    y = "Number of authors",
    title = paste0("Observed vs Power-Law Fit (xmin = ",
                   xmin, ", α = ", round(alpha, 2), ")"),
    subtitle = paste0("GOF p = ", round(gof$p, 3),
                      " | Vuong p = ", round(comp$p_two_sided, 3))
  ) +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(face = "bold"))

print(p2)

ggsave("lotka_fit_overlay_2016_2025.png",
       p2, width = 7, height = 5, dpi = 300)

# ============================================================================
# MODULE 9 — EXPORT RESULTS
# ============================================================================

write.csv(author_prod,
          "author_productivity_2016_2025.csv",
          row.names = FALSE)

write.csv(lotka_freq,
          "lotka_frequency_table_2016_2025.csv",
          row.names = FALSE)

results <- data.frame(
  parameter = c("xmin", "alpha", "gof_p_value",
                "vuong_stat", "vuong_p_two_sided",
                "n_unique_authors", "n_unique_papers",
                "max_pubs_per_author"),
  value = c(xmin, alpha, gof$p,
            comp$test_statistic, comp$p_two_sided,
            nrow(author_prod),
            length(unique(author_papers$EID)),
            max(author_prod$n_pubs))
)

write.csv(results,
          "lotka_fit_summary_2016_2025.csv",
          row.names = FALSE)

cat("\n--- Files exported ---\n")
cat("  author_productivity_2016_2025.csv\n")
cat("  lotka_frequency_table_2016_2025.csv\n")
cat("  lotka_fit_summary_2016_2025.csv\n")
cat("  lotka_loglog_2016_2025.png\n")
cat("  lotka_fit_overlay_2016_2025.png\n")
cat("\nDone.\n")

# ============================================================================
# MODULE 10 — INEQUALITY METRICS
# ============================================================================

# ---- 10.1 Compute Gini from grouped data ----

# Compute Gini from the grouped distribution using cumulative weighted shares
freq_sorted <- lotka_freq %>%
  arrange(n_pubs)

N <- sum(freq_sorted$n_authors)
T_output <- sum(freq_sorted$n_pubs * freq_sorted$n_authors)

# Cumulative shares
freq_sorted <- freq_sorted %>%
  mutate(
    cum_authors = cumsum(n_authors),
    cum_output  = cumsum(n_pubs * n_authors),
    F = cum_authors / N,
    S = cum_output  / T_output
  )

# Add (0,0) origin for Lorenz integration
lorenz_x <- c(0, freq_sorted$F)
lorenz_y <- c(0, freq_sorted$S)

# Area under the Lorenz curve via trapezoidal integration
lorenz_area <- sum(
  (lorenz_y[-1] + lorenz_y[-length(lorenz_y)]) / 2 *
    diff(lorenz_x)
)

gini <- 1 - 2 * lorenz_area

cat("Gini coefficient:", round(gini, 4), "\n\n")

# ---- 10.2 Compute Top 10% and Top 1% shares ----

# Create cumulative distribution from top
freq_desc <- freq_sorted %>%
  arrange(desc(n_pubs)) %>%
  mutate(
    cum_authors_desc = cumsum(n_authors),
    cum_output_desc  = cumsum(n_pubs * n_authors)
  )

top_10_threshold <- 0.10 * N
top_1_threshold  <- 0.01 * N

top10_output <- freq_desc %>%
  filter(cum_authors_desc <= top_10_threshold) %>%
  summarise(sum_output = sum(n_pubs * n_authors)) %>%
  pull(sum_output)

top1_output <- freq_desc %>%
  filter(cum_authors_desc <= top_1_threshold) %>%
  summarise(sum_output = sum(n_pubs * n_authors)) %>%
  pull(sum_output)

top10_share <- top10_output / T_output
top1_share  <- top1_output / T_output

cat("Top 10% share:", round(top10_share, 4), "\n")
cat("Top 1% share:", round(top1_share, 4), "\n\n")

# ---- 10.3 Lorenz curve plot ----

lorenz_df <- data.frame(
  authors_share = lorenz_x,
  output_share  = lorenz_y
)

p3 <- ggplot(lorenz_df, aes(x = authors_share, y = output_share)) +
  geom_line(color = "#29BEFD", linewidth = 1.2) +
  geom_abline(intercept = 0, slope = 1,
              linetype = "dashed", color = "grey40") +
  labs(
    x = "Cumulative share of authors",
    y = "Cumulative share of output",
    title = paste0("Lorenz Curve (Gini = ", round(gini, 2), ")"),
    subtitle = paste0("Top 10% share = ", round(top10_share*100,1), "% | ",
                      "Top 1% share = ", round(top1_share*100,1), "%")
  ) +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(face = "bold"))

print(p3)

ggsave("lorenz_curve_2016_2025.png",
       p3, width = 7, height = 5, dpi = 300)

# ---- 10.4 Export inequality summary ----

ineq_summary <- data.frame(
  metric = c("Gini",
             "Top_10_percent_share",
             "Top_1_percent_share"),
  value = c(gini,
            top10_share,
            top1_share)
)

write.csv(ineq_summary,
          "lotka_inequality_summary_2016_2025.csv",
          row.names = FALSE)

cat("\n--- Inequality results exported ---\n")
cat("  lorenz_curve_2016_2025.png\n")
cat("  lotka_inequality_summary_2016_2025.csv\n\n")
