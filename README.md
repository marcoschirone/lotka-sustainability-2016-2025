# Revisiting Lotka's Law: Patterns of Author Productivity in Sustainability Science (2016–2025)

[![License: MIT](https://img.shields.io/badge/Code%20License-MIT-blue.svg)](#license)
[![License: CC BY 4.0](https://img.shields.io/badge/Content%20License-CC%20BY%204.0-lightgrey.svg)](#license)

> Analysis code and derived outputs for a centenary re-examination of Alfred J. Lotka's (1926) inverse-square law of scientific productivity, applied to author productivity across sustainability science journals (2016–2025).

**Authors**

- **Marco Schirone** — ORCID [0000-0002-4166-153X](https://orcid.org/0000-0002-4166-153X) — Chalmers University of Technology and the Swedish School of Library and Information Science, University of Borås, Sweden — `marco.schirone@chalmers.se`
- **A. I. M. Jakaria Rahman** — ORCID [0000-0001-7876-4631](https://orcid.org/0000-0001-7876-4631) — Chalmers University of Technology, Sweden — `jakaria.rahman@chalmers.se`

---

## Overview

This repository contains the R analysis pipeline and the derived results behind a study that revisits Lotka's law one century after its original formulation. Using a Scopus dataset of publications from 29 sustainability science journals (2016–2025), the analysis characterises the distribution of publications per author and tests whether it conforms to a classical inverse-square power law.

The workflow:

1. Loads a Scopus export, explodes pipe-separated author identifiers into one record per author–publication pair, and computes per-author productivity.
2. Fits a discrete power-law model to the upper tail by maximum-likelihood estimation (`poweRlaw`), estimating the lower cutoff `xmin` and the scaling exponent `α`.
3. Assesses model adequacy with a parametric bootstrap goodness-of-fit test, and compares the power law against a lognormal alternative with a Vuong likelihood-ratio test.
4. Quantifies productivity inequality (Gini coefficient, top-decile and top-percentile output shares) and visualises it with a Lorenz curve.

All reported numerical results and figures are produced by a single script, [`Lotka.R`](Lotka.R).

---

## Repository Structure

The repository uses a flat layout with a single `sample_data/` subfolder. The proprietary Scopus input is not included; a synthetic sample is provided in its place.

```
lotka-sustainability-2016-2025/
├── Lotka.R                                   # Main analysis pipeline (Modules 1–10)
├── lotka-sustainability-2016-2025.Rproj      # RStudio project (sets the working directory)
├── README.md
├── CITATION.cff                              # Machine-readable citation
├── LICENSE                                   # MIT (code); CC BY 4.0 (content) — see License
├── DOIs_STI_2026_poster.txt                  # DOIs of the analysed publication set
│
│   # Derived outputs written by Lotka.R
├── lotka_frequency_table_2016_2025.csv       # Productivity frequency table (n_pubs, n_authors)
├── lotka_fit_summary_2016_2025.csv           # Power-law fit + model-comparison parameters
├── lotka_inequality_summary_2016_2025.csv    # Gini, top-10% and top-1% output shares
├── lotka_loglog_2016_2025.png                # Log–log productivity distribution
├── lotka_fit_overlay_2016_2025.png           # Observed vs. power-law fit
├── lorenz_curve_2016_2025.png                # Lorenz curve of author productivity
│
└── sample_data/                              # Synthetic sample for testing the pipeline
    ├── README.md                             # Describes the synthetic sample
    ├── STI_2026_Poster_Data_2016-2025_SYNTHETIC_SAMPLE.csv
    └── STI_2026_Poster_Data_2016-2025_SYNTHETIC_SAMPLE.xlsx
```

> **Not committed to the repository:**
> - The proprietary Scopus export (`STI 2026 Poster Data 2016-2025.xlsx`) — see [Data](#data). The synthetic sample in `sample_data/` stands in for it.
> - `author_productivity_2016_2025.csv` — this per-author table is *generated* by `Lotka.R` (Module 9) but is **not committed**, as it contains Scopus Author IDs. It is recreated whenever the script is run.

---

## Requirements

### Software

- **R** — a recent version (4.0 or later recommended). The analysis is not pinned to a specific R version; record the version you use under [Computational Environment](#computational-environment).
- No RStudio dependency: the script runs under plain `Rscript` or any R console. An RStudio project file (`lotka-sustainability-2016-2025.Rproj`) is included for convenience — opening it sets the working directory to the repository root.

### R packages

Declared via `library()` calls in `Lotka.R`:

| Package | Role |
|---|---|
| `readxl` | Read the Scopus `.xlsx` export |
| `dplyr` | Data manipulation |
| `tidyr` | Reshaping (`unnest`) |
| `stringr` | String splitting/trimming of author-ID fields |
| `ggplot2` | Figures |
| `poweRlaw` | Discrete power-law/lognormal fitting, GOF, model comparison |

### Operating system

The script is OS-independent in principle, but `Lotka.R` reads its input from a hard-coded absolute macOS path (`/Users/schirone/Library/CloudStorage/OneDrive-Chalmers/...`). This path **must be edited** before running on any other machine (see [Data](#data)).

---

## Installation

1. Install R (≥ 4.0) from <https://cran.r-project.org/>.
2. Clone the repository:
   ```bash
   git clone https://github.com/marcoschirone/lotka-sustainability-2016-2025.git
   cd lotka-sustainability-2016-2025
   ```
3. Install the required packages from an R session:
   ```r
   install.packages(c(
     "readxl", "dplyr", "tidyr",
     "stringr", "ggplot2", "poweRlaw"
   ))
   ```

> For stricter reproducibility, consider managing dependencies with [`renv`](https://rstudio.github.io/renv/) and committing the resulting `renv.lock` (see [Reproducibility Notes](#reproducibility-notes)).

---

## Data

### Primary input (not included)

| Item | Description |
|---|---|
| File | `STI 2026 Poster Data 2016-2025.xlsx` |
| Source | Scopus API export, with Scopus Author IDs matched via SciVal |
| Required columns | `EID`, `Scopus Author Ids` (pipe-`\|`-separated list of author IDs), `Year` |
| Scope | Articles and reviews from 29 sustainability science journals, 2016–2025 |
| Redistribution | **Not included.** Scopus is a proprietary database and the records cannot be openly redistributed. |

Because the source data are proprietary, the repository cannot be re-run end-to-end on the original data without independent Scopus access. To reproduce the published results, place an equivalently structured export on disk and update the `file_path` assignment near the top of `Lotka.R`.

### Synthetic sample (`sample_data/`)

So that the pipeline can be exercised without the proprietary export, the `sample_data/` folder provides a **synthetic sample** that mimics the structure of the Scopus input:

| File | Description |
|---|---|
| `STI_2026_Poster_Data_2016-2025_SYNTHETIC_SAMPLE.csv` | Synthetic records with the same columns as the real export |
| `STI_2026_Poster_Data_2016-2025_SYNTHETIC_SAMPLE.xlsx` | Same content in `.xlsx` form (matches the `readxl` input in `Lotka.R`) |
| `README.md` | Notes describing the synthetic sample |

Running `Lotka.R` against the synthetic sample reproduces the **workflow** (and produces all output files) but **not** the published figures, which depend on the full proprietary dataset. See [Reproducibility Workflow](#reproducibility-workflow).

### Publication DOIs (`DOIs_STI_2026_poster.txt`)

The DOIs of the analysed publication set are shared at the repository root in `DOIs_STI_2026_poster.txt`.

| Item | Description |
|---|---|
| File | `DOIs_STI_2026_poster.txt` |
| Format | Plain text: a `DOI` header line followed by one DOI per line |
| Purpose | Identifies the publications analysed, so others can retrieve the same records from the publishers/Scopus |

The DOI list identifies the analysed publication set but does **not** contain the **SciVal-derived Scopus Author IDs** used for author–publication matching, so it does not by itself reproduce the productivity counts.

### Preprocessing

No external preprocessing is required: cleaning, deduplication of author–publication pairs, and explosion of the pipe-separated author-ID field are performed inside `Lotka.R` (Modules 1–2).

---

## Reproducibility Workflow

From input data to final outputs:

1. **Choose your input.**
   - *To reproduce the published results:* obtain the Scopus `.xlsx` export (columns `EID`, `Scopus Author Ids`, `Year`) and place it on disk.
   - *To test the pipeline without proprietary data:* use the synthetic file in `sample_data/` (see [Data](#data)). Outputs will be produced, but the numbers will not match the paper.
2. **Set the input path.** Edit the `file_path <- "..."` line near the top of `Lotka.R` to point to your chosen file. Opening `lotka-sustainability-2016-2025.Rproj` first sets the working directory to the repository root, so outputs land alongside the script.
3. **Install dependencies** (see [Installation](#installation)).
4. **Run the full pipeline:**
   ```bash
   Rscript Lotka.R
   ```
   or, from an interactive session, `source("Lotka.R")`.

The script executes sequentially:

| Module | Step |
|---|---|
| 1–2 | Load, clean, and explode author IDs into author–publication pairs |
| 3 | Compute per-author productivity and the frequency table |
| 4 | Print summary statistics (totals, mean productivity) |
| 5 | Log–log productivity plot → `lotka_loglog_2016_2025.png` |
| 6 | Power-law fit (`xmin`, `α`) + parametric bootstrap GOF (`set.seed(123)`, 500 simulations) |
| 7 | Power-law vs. lognormal comparison (Vuong test) |
| 8 | Observed vs. fitted overlay → `lotka_fit_overlay_2016_2025.png` |
| 9 | Export productivity, frequency, and fit-summary CSVs |
| 10 | Inequality metrics (Gini, top shares) + Lorenz curve → `lorenz_curve_2016_2025.png` and inequality CSV |

A fixed random seed (`set.seed(123)`) precedes the bootstrap GOF test, so the goodness-of-fit *p*-value is reproducible given identical input data and package versions.

---

## Outputs

All files below are generated by `Lotka.R`. The CSV tables (except `author_productivity_2016_2025.csv`) and the three PNG figures are committed to the repository; `author_productivity_2016_2025.csv` is regenerated on each run but not committed (it contains Scopus Author IDs).

### Tables (CSV)

| File | Contents | In repo? |
|---|---|---|
| `author_productivity_2016_2025.csv` | One row per author: `AuthorID`, `n_pubs` | No — generated only |
| `lotka_frequency_table_2016_2025.csv` | Productivity frequency distribution: `n_pubs`, `n_authors` | Yes |
| `lotka_fit_summary_2016_2025.csv` | `xmin`, `alpha`, `gof_p_value`, `vuong_stat`, `vuong_p_two_sided`, `n_unique_authors`, `n_unique_papers`, `max_pubs_per_author` | Yes |
| `lotka_inequality_summary_2016_2025.csv` | `Gini`, `Top_10_percent_share`, `Top_1_percent_share` | Yes |

### Figures (PNG, 300 dpi)

| File | Contents |
|---|---|
| `lotka_loglog_2016_2025.png` | Author productivity distribution on log–log axes |
| `lotka_fit_overlay_2016_2025.png` | Observed counts vs. fitted power law, with `xmin` marked |
| `lorenz_curve_2016_2025.png` | Lorenz curve with Gini and top-share annotations |

> Reported numerical values (e.g., `xmin`, `α`, GOF and Vuong *p*-values, Gini) should be read from `lotka_fit_summary_2016_2025.csv` and `lotka_inequality_summary_2016_2025.csv`, which are the authoritative machine-readable record of the as-run analysis.

---

## Computational Environment

For full reproducibility, record your environment alongside any re-run. Generate it with:

```r
sessionInfo()
# or, more completely:
# sessioninfo::session_info()
```

Template to complete with your actual versions:

```
R version <X.Y.Z> (<YYYY-MM-DD>)
Platform: <platform>
Running under: <OS>

Attached packages:
  readxl_<version>
  dplyr_<version>
  tidyr_<version>
  stringr_<version>
  ggplot2_<version>
  poweRlaw_<version>
```

Package and R versions are not pinned in the code, so record them here when you run the analysis. The `poweRlaw` fitting/GOF API in particular can change between releases, so pinning its version (e.g., via `renv`) is recommended for exact reproduction.

---

## Citation

### How to cite this repository

If you use this code or the derived outputs, please cite the repository:

> Schirone, M., & Rahman, A. I. M. J. (2026). *Revisiting Lotka's Law: Patterns of Author Productivity in Sustainability Science (2016–2025)* [Software and data repository]. Version 1.0.0. GitHub. https://github.com/marcoschirone/lotka-sustainability-2016-2025 (a Zenodo DOI will be added once the repository is archived).

BibTeX:

```bibtex
@misc{schirone_rahman_lotka_repo_2026,
  author       = {Schirone, Marco and Rahman, A. I. M. Jakaria},
  title        = {Revisiting Lotka's Law: Patterns of Author Productivity
                  in Sustainability Science (2016--2025)},
  year         = {2026},
  version      = {1.0.0},
  howpublished = {GitHub repository},
  url          = {https://github.com/marcoschirone/lotka-sustainability-2016-2025},
  % doi        = {},  % add after Zenodo deposit
  note         = {Analysis code and derived outputs}
}
```

Once the repository is archived for a citable DOI via [Zenodo's GitHub integration](https://docs.github.com/en/repositories/archiving-a-github-repository/referencing-and-citing-content), add the DOI to the citation above.

### Related publication

The repository accompanies the conference contribution:

> Schirone, M., & Rahman, A. I. M. J. (2026). Revisiting Lotka's law: patterns of author productivity in sustainability science. In *Proceedings of the Conference on Science and Technology Indicators (STI 2026)*, Antwerp, Belgium (forthcoming).

Add the page range and DOI to this reference once the proceedings are published.

### Machine-readable citation

The repository includes a [`CITATION.cff`](https://citation-file-format.github.io/) file, so GitHub renders a "Cite this repository" button automatically. Its essential content:

```yaml
cff-version: 1.2.0
message: "If you use this repository, please cite it as below."
title: "Revisiting Lotka's Law: Patterns of Author Productivity in Sustainability Science (2016–2025)"
authors:
  - family-names: Schirone
    given-names: Marco
    orcid: "https://orcid.org/0000-0002-4166-153X"
  - family-names: Rahman
    given-names: "A. I. M. Jakaria"
    orcid: "https://orcid.org/0000-0001-7876-4631"
version: 1.0.0
date-released: "2026-06-12"
url: "https://github.com/marcoschirone/lotka-sustainability-2016-2025"
# doi: 10.5281/zenodo.XXXXXXX  # add after Zenodo deposit
```

---

## License

A split license is recommended, following common open-science practice:

- **Code** (`Lotka.R`): **MIT License** — a permissive license that maximises reuse of research software while requiring attribution and disclaiming warranty. See the `LICENSE` file.
- **Documentation, figures, and derived data tables** (this README, the PNG figures, the output CSVs): **Creative Commons Attribution 4.0 International (CC BY 4.0)** — the standard attribution license for scholarly content and data.

Rationale: separating a permissive *software* license from an attribution-based *content/data* license is the convention recommended by many repositories and journals, because software and scholarly artefacts have different reuse norms. MIT keeps the analysis pipeline broadly reusable; CC BY 4.0 ensures the figures, tables, and text are reusable with proper credit.

> **Important:** the proprietary Scopus input data are **not** covered by these licenses and cannot be relicensed or redistributed by the authors. Only the analysis code and the outputs derived from it are released here. The shared `DOIs_STI_2026_poster.txt` lists identifiers only and does not redistribute Scopus records.

---

## Reproducibility Notes

- **Proprietary data dependency.** The primary input is a Scopus/SciVal export that cannot be redistributed; full end-to-end reproduction requires independent Scopus access. The DOI list and the synthetic sample in `sample_data/` let others identify the publication set and exercise the pipeline, but not reproduce the SciVal author-ID matching.
- **Synthetic sample.** `sample_data/` lets the pipeline run without proprietary data. Point `file_path` at the synthetic file to verify the workflow end to end; the resulting figures are illustrative, not the published values.
- **Hard-coded path.** `Lotka.R` reads the input from an absolute macOS OneDrive path. This **must** be edited for any other environment. Opening `lotka-sustainability-2016-2025.Rproj` sets a portable working directory at the repository root; consider also replacing the absolute `file_path` with a relative one (e.g., `sample_data/...`).
- **Output locations.** Outputs are written to the working directory (the repository root in the flat layout), which is why the generated CSVs and PNGs sit alongside `Lotka.R`.
- **Stochastic steps.** `set.seed(123)` is set before the bootstrap GOF test, making its *p*-value reproducible; results may still vary across different `poweRlaw` versions. Pin package versions (e.g., via `renv`) for exact reproduction.
- **Authoritative values.** Treat the exported summary CSVs (`lotka_fit_summary_*`, `lotka_inequality_summary_*`) as the canonical record of reported figures.
- **DOI file format.** `DOIs_STI_2026_poster.txt` should be plain text. If it originated as a rich-text/RTF export, convert it to plain text before committing (this also keeps it well under GitHub's 25 MB browser-upload limit).
- **Suggested release checklist:** (1) convert the DOI file to plain text and confirm one DOI per line; (2) edit or relativise the hard-coded `file_path`; (3) verify `LICENSE` and `CITATION.cff` are present (both included); (4) optionally add `renv.lock`; (5) tag a release and mint a Zenodo DOI.
