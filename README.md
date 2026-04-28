# msk

R package for calculating biodiversity indicators from species occurrence data.
Developed for the Swiss [Modular Stepwise Procedure](https://modul-stufen-konzept.ch/en/about-the-msp/)
(Modulstufenkonzept, MSK), a set of standardised methods for surveying and
assessing the status of water bodies in Switzerland.

The package works with any dataset that follows the
[Darwin Core](https://dwc.tdwg.org/terms/) standard (event/occurrence tables
linked by `eventID`).

## Installation

```r
# Install from GitHub
# install.packages("pak")
pak::pak("TobiasRoth/msk")

# Alternative
# install.packages("devtools")
devtools::install_github("TobiasRoth/msk")

library(msk)
```

## Available functions

| Function | Type | Description |
|:---|:---|:---|
| `as_msk()` | import | Convert a flat species table to the msk data structure |
| `calc_alphadiv()` | event-level | Number of distinct taxa per event |
| `calc_abundance()` | event-level | Total or mean-per-taxon abundance per event |
| `calc_gammadiv()` | group-level | Total distinct taxa across events (optionally per group) |
| `calc_betadiv()` | group-level | Pairwise Simpson dissimilarity between events |
| `calc_indicator_index()` | — | Normalise indicator values to a reference (base = 100) |

Event-level functions add a column to the `event` table and return the modified
data list, so they can be chained with `%>%`. Group-level functions return a
summary tibble.

## Data structure

The package expects data as a list with two data frames:

- **`event`** — one row per sampling event; requires `eventID`
- **`occurrence`** — one row per taxon per event; requires `eventID`,
  `taxonID`, and (for abundance functions) `individualCount`

Additional columns are preserved by all functions.

## Quick example

```r
library(msk)
library(dplyr)

# Chain multiple indicators using the included macroinvertebrate dataset
dat <- mzb %>%
  calc_alphadiv() %>%
  calc_abundance(method = "total") %>%
  calc_abundance(method = "mean_per_taxon")

head(dat$event)

# Group-level indicators: gamma and beta diversity per year
calc_gammadiv(mzb, group_by_col = "year")
calc_betadiv(mzb, group_by_col = "year")
```

## Example datasets

| Dataset | Description |
|:---|:---|
| `mzb` | Macroinvertebrates (MZB) — 340 events, 85 stations, 4 NAWA campaigns (2012–2023) |
| `fisch` | Fish — 176 events, 51 stations, 4 NAWA campaigns (2012–2023); includes biomass data |

Both datasets are included for demonstration purposes only and must not be used
for analysis or reporting. The authoritative source is the
[MIDAT database](https://www.infofauna.ch/de/fauna-der-schweiz/makrozoobenthos#gsc.tab=0) (MZB) and the relevant cantonal and
federal fish data repositories.

## Documentation

A vignette covers the full workflow — data structure, all indicator functions,
chaining, visualisation with `ggplot2`, index normalisation, and a complete
fish data analysis:

```r
# Install with vignettes
devtools::install_github("TobiasRoth/msk", build_vignettes = TRUE)

vignette("Biodiversity_Indicators", package = "msk")
```

## License

MIT
