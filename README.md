# Revisiting Lotka's law: patterns of author productivity in sustainability science

*Replication code and derived data for the STI 2026 poster (publication period 2016–2025).*

**Repository:** https://github.com/marcoschirone/lotka-sustainability-2016-2025

---

## Overview

On the centenary of Alfred J. Lotka's 1926 paper on the frequency distribution of scientific productivity, this study revisits the classical inverse-square law using a Scopus dataset covering 29 sustainability science journals published between 2016 and 2025.

Author productivity is analysed with modern statistical methods for heavy-tailed data: a discrete power-law model is fitted by maximum-likelihood estimation, model adequacy is assessed with a parametric bootstrap goodness-of-fit (GOF) test, and the power law is compared against a lognormal alternative using the Vuong likelihood-ratio test. Inequality in scientific output is summarised with the Gini coefficient and visualised with the Lorenz curve.

The study addresses two research questions:

**RQ1.** Does the productivity distribution across sustainability science journals conform to a power-law model consistent with the classical inverse-square law?

**RQ2.** How concentrated is scientific output, and what does the degree of inequality imply for the structure of the field?

Headline results reported in the poster: the estimated lower cutoff is xmin = 13 and the scaling exponent is α = 3.42 — substantially steeper than the classical Lotka value of approximately 2; the bootstrap GOF test rejects the pure power law (p = 0.002); the Vuong test favours the lognormal model (statistic = −2.45, p = 0.014); and inequality is moderate (Gini = 0.37, with the top 10% of authors accounting for 33.5% and the top 1% for 9.6% of output). The corpus comprises 143,183 publications (articles and reviews) and 398,085 unique authors identified via Scopus Author IDs.

The underlying Scopus data are proprietary and cannot be redistributed. To support transparency and reproducibility, the repository provides the complete analysis code, the derived aggregate data, the figures, and the list of publication DOIs.

---

## Repository structure

```text
lotka-sustainability-2016-2025/
├── README.md
├── LICENSE
├── CITATION.cff
├── Lotka.R                                        # Single analysis script (Modules 1–10)
├── DOIs_publications.txt                          # DOI list of the analysed publication corpus
│
├── data/
│   ├── README.md                                  # Description of the synthetic sample data
│   ├── STI_2026_Poster_Data_2016-2025_SYNTHETIC_SAMPLE.xlsx
│   ├── STI_2026_Poster_Data_2016-2025_SYNTHETIC_SAMPLE.csv
│   └── STI 2026 Poster Data 2016-2025.xlsx        # Proprietary Scopus export (user supplied; not included)
│
├── author_productivity_2016_2025.csv              # Derived output
├── lotka_frequency_table_2016_2025.csv            # Derived output
├── lotka_fit_summary_2016_2025.csv                # Derived output
├── lotka_inequality_summary_2016_2025.csv         # Derived output
├── lotka_loglog_2016_2025.png                     # Derived figure
├── lotka_fit_overlay_2016_2025.png                # Derived figure
└── lorenz_curve_2016_2025.png                     # Derived figure
```

> **Note on paths.** `Lotka.R` reads its single input from `data/` and writes all seven output
> files to the **working directory**. Set the working directory to the repository root before
> running the script so that outputs are written alongside the code, as committed here. *(The
> grouping above reflects how the generated files are provided in the repository; the script
> itself does not create an `output/` subdirectory.)*

---

## Script structure

The entire analysis is contained in a single script, `Lotka.R`, organised into ten sequential modules.

| Module | Purpose |
|--------|---------|
| 1 | Load and clean the Scopus export; select `EID`, `Scopus Author Ids`, `Year` |
| 2 | Explode the pipe-separated author IDs to one row per author × paper; de-duplicate author–paper pairs |
| 3 | Compute author productivity (publications per unique author) and the frequency table |
| 4 | Summary statistics: total authors, unique papers, authored counts, mean productivity |
| 5 | Log–log productivity scatter (exploratory figure) |
| 6 | Discrete power-law fit via MLE; xmin estimation; bootstrap GOF test (500 simulations, `set.seed(123)`) |
| 7 | Lognormal fit; Vuong likelihood-ratio test (power law vs. lognormal) |
| 8 | Observed vs. power-law overlay with the xmin marker (Figure 1) |
| 9 | Export three result CSVs; print a console summary |
| 10 | Gini coefficient and Lorenz curve (10.1–10.4); top 10% and top 1% output shares; Lorenz figure (Figure 2); export the inequality-summary CSV |

---

## Requirements

### Software

- **R.** The analysis was developed and run under R 4.x; a recent release is recommended.
  *(Assumption: the code does not enforce a specific minimum version. It uses the magrittr pipe
  `%>%` supplied by `dplyr`, not the native `|>` pipe, so no R 4.1+ requirement applies.)*
- RStudio is recommended but not required.

### R packages

| Package | Purpose |
|---------|---------|
| `readxl` | Import the Scopus Excel export |
| `dplyr` | Data manipulation |
| `tidyr` | Unnesting the pipe-separated author IDs |
| `stringr` | String splitting and trimming |
| `ggplot2` | Figures |
| `poweRlaw` | Discrete power-law fitting, GOF testing, and model comparison |

All packages are available on CRAN; no development versions are required.

### Operating system

The script uses standard R functionality and relative paths and is expected to run on Windows, macOS, and Linux without modification.

---

## Installation

```bash
git clone https://github.com/marcoschirone/lotka-sustainability-2016-2025.git
cd lotka-sustainability-2016-2025
```

```r
install.packages(c("readxl", "dplyr", "tidyr", "stringr", "ggplot2", "poweRlaw"))
```

---

## Data

### Input file

The analysis requires a single input file:

```text
data/STI 2026 Poster Data 2016-2025.xlsx
```

The `data/` directory is included in the repository as an empty placeholder. Users must place the proprietary Scopus export file in this directory before running the analysis.

| Column | Description |
|--------|-------------|
| `EID` | Scopus publication identifier |
| `Scopus Author Ids` | Pipe-separated (`\|`) list of Scopus Author IDs per publication |
| `Year` | Publication year |

**This file is proprietary and is not included in the repository.** It was retrieved via the Scopus API and is subject to Elsevier's licensing terms. A researcher with Scopus access can reconstruct the corpus from `DOIs_publications.txt` and export the columns above.


### Publication DOI list

```text
DOIs_publications.txt
```

Contains the DOIs of the publications in the analysed corpus. DOIs are identifiers rather than licensed records and are provided to enable independent verification and corpus reconstruction.

### Derived data (included)

| File | Description |
|------|-------------|
| `author_productivity_2016_2025.csv` | One row per unique author; columns `AuthorID`, `n_pubs` |
| `lotka_frequency_table_2016_2025.csv` | Frequency table: number of authors by publication count |
| `lotka_fit_summary_2016_2025.csv` | Fit parameters: xmin, α, GOF p-value, Vuong statistic and two-sided p-value, author and paper counts, maximum publications per author |
| `lotka_inequality_summary_2016_2025.csv` | Gini coefficient, top 10% share, top 1% share |

---

## Data availability

The repository does not redistribute proprietary Scopus records. It provides the complete analysis code, all derived aggregate data, all figures, and the publication DOI list. Researchers with Scopus access can reconstruct the input file from the DOI list and reproduce the full analysis.

---

## Reproducibility workflow

The entire analysis runs as a single script:

```r
setwd("path/to/lotka-sustainability-2016-2025")
source("Lotka.R")
```

This executes Modules 1–10 in order and writes the seven output files to the working directory. The proprietary input file must be present at `data/STI 2026 Poster Data 2016-2025.xlsx`.

> **Bootstrap reproducibility.** Module 6 calls `set.seed(123)` before the bootstrap GOF test
> (`bootstrap_p`, 500 simulations). Exact reproduction of the GOF p-value requires this seed and
> the same R and `poweRlaw` versions used originally (see *Computational environment*). The seed
> does not affect the MLE parameter estimates (xmin, α) or the Vuong statistic.

---

## Outputs

### Figures (300 dpi, 7 × 5 in)

| File | Description | Role |
|------|-------------|------|
| `lotka_loglog_2016_2025.png` | Log–log scatter of the author productivity distribution | Exploratory (Module 5) |
| `lotka_fit_overlay_2016_2025.png` | Observed distribution vs. power-law fit; dashed line at xmin | Figure 1 |
| `lorenz_curve_2016_2025.png` | Lorenz curve annotated with Gini, top 10%, and top 1% shares | Figure 2 |

### Tables

| File | Expected key values |
|------|---------------------|
| `lotka_fit_summary_2016_2025.csv` | xmin = 13; α = 3.42; GOF p = 0.002; Vuong stat = −2.45; Vuong p = 0.014 |
| `lotka_inequality_summary_2016_2025.csv` | Gini = 0.37; top 10% share = 33.5%; top 1% share = 9.6% |
| `author_productivity_2016_2025.csv` | 398,085 rows (one per unique author) |
| `lotka_frequency_table_2016_2025.csv` | Frequency distribution used for all model fitting |

Each export block (Modules 9 and 10.4) prints a confirmation of the files it has written to the console.

---

## Statistical approach

**Power-law fitting.** A discrete power-law model is fitted by maximum-likelihood estimation using the `poweRlaw` package (Gillespie, 2015). The lower cutoff xmin is estimated by minimising the Kolmogorov–Smirnov statistic between the empirical and fitted distributions.

**Goodness-of-fit.** Model adequacy is assessed with a parametric bootstrap GOF test (500 simulations; `set.seed(123)`).

**Model comparison.** The power law is compared with a discrete lognormal alternative using the Vuong likelihood-ratio test, applied to the tail (n ≥ xmin).

**Inequality.** The Gini coefficient is computed from the grouped frequency distribution by trapezoidal integration of the Lorenz curve. The top 10% and top 1% output shares are computed by accumulating authors from the most productive downward until the respective author-count threshold is reached.

---

## Computational environment

The analysis was conducted in R. For exact reproducibility, record the output of `sessionInfo()` alongside any reproduced run:

```r
source("Lotka.R")
writeLines(capture.output(sessionInfo()), "sessionInfo.txt")
```

Details to record:

```text
R version:         <e.g. 4.x.x>
Platform:          <e.g. aarch64-apple-darwin / x86_64-pc-linux-gnu>
Operating system:  <OS and version>

Attached packages (record installed versions):
  readxl       <version>
  dplyr        <version>
  tidyr        <version>
  stringr      <version>
  ggplot2      <version>
  poweRlaw     <version>

Random seed (GOF test): 123
Bootstrap simulations:  500
Data snapshot:          Scopus, retrieved <date>
```

Scopus is continuously updated; re-extracting the data later may yield slightly different counts and therefore slightly different estimates.

---

## Citation

If you use this code or the derived data, please cite the repository:

> Schirone, M., & Rahman, A. I. M. J. (2026). *Revisiting Lotka's law: patterns of author productivity in sustainability science* (Version 1.0.0) [Computer software]. GitHub. https://github.com/marcoschirone/lotka-sustainability-2016-2025

To cite the underlying research, please cite the poster:

> Schirone, M., & Rahman, A. I. M. J. (2026). Revisiting Lotka's law: patterns of author productivity in sustainability science [Poster]. Proceedings of the International Conference on Science and Technology Indicators (STI 2026). https://doi.org/\<DOI — placeholder\>

Machine-readable metadata are provided in `CITATION.cff`. Complete the DOI placeholder once the proceedings (and any Zenodo deposit) provide one.

---

## License

The repository is distributed under the **MIT License** (see `LICENSE`), covering the source code, documentation, and derived data files. The underlying Scopus export is proprietary and is not covered by this license.

MIT is appropriate here because the primary deliverable is a self-contained analysis script rather than a library or a dataset. It permits unrestricted reuse, adaptation, and integration into other workflows, maximising the scientific value of sharing analysis code alongside a published poster, while the copyright notice preserves attribution.

---

## Reproducibility notes

- **Proprietary input.** `STI 2026 Poster Data 2016-2025.xlsx` cannot be redistributed. Full reproduction requires Scopus access or an equivalent dataset reconstructed from `DOIs_publications.txt`.
- **Author identification.** Unique authors are identified by Scopus Author IDs; the accuracy of the productivity distribution depends on Scopus author disambiguation, which can vary across authors and institutions.
- **Bootstrap stochasticity.** The GOF p-value is subject to simulation variance; `set.seed(123)` ensures reproducibility within the same software environment, but different R or `poweRlaw` versions may produce slightly different p-values.
- **Top-share computation.** Top 10% and top 1% shares are accumulated over a frequency distribution grouped by integer publication count, so the effective author threshold may fall slightly below the nominal 10% or 1% at a group boundary.
- **Working directory.** `Lotka.R` writes outputs to the R working directory; set it to the repository root before sourcing so files are written to the expected location.

---

## Acknowledgements

The authors acknowledge the use of Scopus data in the preparation of this study. The `poweRlaw` package (Gillespie, 2015) provided the statistical infrastructure for power-law fitting and model comparison.

---

## Contact

Questions, comments, and bug reports are welcome through GitHub Issues.
