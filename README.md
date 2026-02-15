# msk

R package for calculating biodiversity indicators based on data from the Swiss Modular Stepwise Procedure ([Modulstufenkonzept MSK](https://modul-stufen-konzept.ch/en/about-the-msp/)). The MSK is a set of methods for surveying and assessing the status of water bodies. It is a collaboration between the federal government, cantons and research institutions.

The package works with any dataset that follows the [Darwin Core](https://dwc.tdwg.org/terms/) standard (event/occurrence tables linked by `eventID`).

## Installation

```r
# Install the package from GitHub (first option)
# install.packages("pak")
pak::pak("TobiasRoth/msk")

# Install the package from GitHub (second option)
# install.packages("devtools")
devtools::install_github("TobiasRoth/msk")

# Load library
library(msk)
```

## Available functions

| Function | Description |
|:---|:---|
| `calc_alphadiv()` | Alpha diversity (number of distinct taxa per event) |
| `calc_abundance()` | Total abundance (sum of `individualCount` per event) |
| `calc_gammadiv()` | Gamma diversity (total distinct taxa, optionally per group) |
| `calc_betadiv()` | Beta diversity (pairwise Simpson dissimilarity) |
| `calc_indicator_index()` | Normalise indicator values to a reference (base = 100) |

## Quick example

```r
library(msk)
library(dplyr)

# Calculate alpha diversity and abundance using the included diatom dataset
dat <- dia %>%
  calc_alphadiv() %>%
  calc_abundance()

head(dat$event)

# Gamma diversity per year
dat$event$year <- as.integer(format(dat$event$eventDate, "%Y"))
calc_gammadiv(dat, group_by_col = "year")

# Beta diversity per year
calc_betadiv(dat, group_by_col = "year")
```

## Data structure

The package expects data as a list with two data frames following Darwin Core terminology:

- **`event`** -- one row per sampling event (requires `eventID`)
- **`occurrence`** -- one row per taxon observation (requires `eventID` and `taxonID`, optionally `individualCount`)

The included dataset `dia` (diatoms from the Swiss NAWA monitoring programme) serves as an example:

```r
data("dia")
str(dia, max.level = 1)
```

## Documentation

A detailed vignette explains the full workflow (data structure, indicator calculation, visualisation, index normalisation):

```r
vignette("Biodiversity_Indicators", package = "msk")
```

After installing the package with `build_vignettes = TRUE`, the vignette is also available in the R help system:

```r
# Install with vignettes
devtools::install_github("TobiasRoth/msk", build_vignettes = TRUE)

# Browse all vignettes
browseVignettes("msk")
```

## License

MIT
