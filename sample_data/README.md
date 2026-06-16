# Synthetic data sample

The files in this folder are **entirely synthetic**. They contain no records,
identifiers, metrics, or text from Scopus or SciVal. All titles, author names,
Scopus Author IDs, EIDs, DOIs, ISSNs, affiliation IDs, and indicator values
are fabricated placeholders.

Their sole purpose is to document the **structure** of the raw input file
(`STI 2026 Poster Data 2016-2025.xlsx`, retrieved from Scopus/SciVal and not
redistributable) so that the analysis pipeline in `Lotka.R` can be inspected
and test-run without access to the proprietary data.

- `STI_2026_Poster_Data_2016-2025_SYNTHETIC_SAMPLE.xlsx` — 5 synthetic rows
  in the same 22-column layout as the original export. Pointing `file_path`
  in `Lotka.R` (Module 1) at this file will run the full pipeline end-to-end
  on the toy data (the statistical results are of course meaningless).
- `STI_2026_Poster_Data_2016-2025_SYNTHETIC_SAMPLE.csv` — the same rows in
  CSV form, for quick inspection without Excel.

The analysis script uses only three of the columns: `EID`,
`Scopus Author Ids` (pipe-separated), and `Year`. The remaining columns are
included here solely to document the full schema of the original export.
A complete data dictionary is provided in the repository README.
