## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 4
)

## ----flowchart, echo = FALSE, fig.height = 1.6--------------------------------
DiagrammeR::grViz("
digraph {
  graph [rankdir = LR, fontname = Arial, bgcolor = transparent]
  node  [fontname = Arial, fontsize = 13, style = filled,
         shape = box, margin = '0.2,0.12', penwidth = 1.2]
  edge  [fontname = Arial, fontsize = 11, color = '#555555']

  A [label = 'Flat table\n(e.g. MIDAT export)',   fillcolor = '#dce8f5', color = '#5a8fc2']
  B [label = 'R data frame',                       fillcolor = '#dce8f5', color = '#5a8fc2']
  C [label = 'msk list\n(event + occurrence)',     fillcolor = '#dce8f5', color = '#5a8fc2']
  D [label = 'Biodiversity\nindicators',            fillcolor = '#d5f5e3', color = '#2e8b57']

  A -> B [label = 'read_excel()\nread.csv()']
  B -> C [label = 'as_msk()']
  C -> D [label = 'calc_alphadiv()\ncalc_abundance()\ncalc_betadiv() ...']
}
")

## ----setup, message = FALSE---------------------------------------------------
library(msk)
library(dplyr)
library(ggplot2)
library(patchwork)

## -----------------------------------------------------------------------------
data("mzb")
str(mzb, max.level = 1)

## -----------------------------------------------------------------------------
head(mzb$event)

## -----------------------------------------------------------------------------
head(mzb$occurrence)

## ----as-msk-import------------------------------------------------------------
library(readxl)

path <- system.file("extdata", "midat_example.xlsx", package = "msk")
dat  <- read_excel(path) %>% as_msk()

dat$event

## ----eval = FALSE-------------------------------------------------------------
# # Excel
# dat <- read_excel("midat_export.xlsx") %>% as_msk()
# 
# # CSV
# dat <- read.csv("export.csv") %>% as_msk()

## ----eval = FALSE-------------------------------------------------------------
# # Default: altitude and locationName included from MIDAT columns
# as_msk(raw)
# 
# # No extra event columns
# as_msk(raw, event_cols = NULL)
# 
# # Custom extra columns on both levels
# as_msk(
#   raw,
#   event_cols      = c(altitude = "hohe", stream = "gewaesser"),
#   occurrence_cols = c(spear = "spear_2019_11")
# )

## ----eval = FALSE-------------------------------------------------------------
# read_excel("other_export.xlsx") %>%
#   as_msk(
#     location_id     = "site_code",
#     date            = "sample_date",
#     taxon_id        = "species",
#     count           = "n_individuals",
#     event_cols      = c(altitude = "elevation", stream = "river_name"),
#     occurrence_cols = c(RL = "red_list_status")
#   )

## ----as-msk-example-----------------------------------------------------------
flat <- data.frame(
  station_id = c(1, 1, 1, 2, 2),
  gewaesser  = c("Aare", "Aare", "Aare", "Thur", "Thur"),
  dd = 12, mm = 6, yyyy = 2023,
  hohe       = c(480, 480, 480, 395, 395),
  taxon_ibch = c("Baetidae", "Ephemerellidae", "Gammaridae",
                 "Baetidae", "Simuliidae"),
  freq1      = c(45, 12, 230, 18, 67),
  det_method = c("kick", "kick", "kick", "surber", "surber")
)

# MIDAT defaults: altitude and locationName added automatically
dat <- as_msk(flat)
dat$event
dat$occurrence

## ----as-msk-extracols---------------------------------------------------------
as_msk(
  flat,
  event_cols      = c(altitude = "hohe"),
  occurrence_cols = c(method = "det_method")
)$occurrence

## ----as-msk-pipeline----------------------------------------------------------
as_msk(flat) %>%
  calc_alphadiv() %>%
  calc_abundance()

## -----------------------------------------------------------------------------
dat <- mzb %>%
  calc_alphadiv()

head(dat$event)

## -----------------------------------------------------------------------------
dat <- dat %>%
  calc_abundance(method = "total") %>%
  calc_abundance(method = "mean_per_taxon")

head(dat$event)

## -----------------------------------------------------------------------------
calc_gammadiv(mzb, group_by_col = "year")

## -----------------------------------------------------------------------------
calc_betadiv(mzb, group_by_col = "year")

## ----mzb-calc-----------------------------------------------------------------
campaigns <- c(2012, 2015, 2019, 2023)

mzb_ind <- mzb %>%
  calc_alphadiv() %>%
  calc_abundance(method = "total")

alpha_mzb <- mzb_ind$event %>%
  group_by(year) %>%
  summarise(
    mean = mean(alphadiv),
    lo   = mean - qt(0.975, n() - 1) * sd(alphadiv) / sqrt(n()),
    up   = mean + qt(0.975, n() - 1) * sd(alphadiv) / sqrt(n()),
    .groups = "drop"
  )

abund_mzb <- mzb_ind$event %>%
  group_by(year) %>%
  summarise(
    mean = mean(abundance),
    lo   = mean - qt(0.975, n() - 1) * sd(abundance) / sqrt(n()),
    up   = mean + qt(0.975, n() - 1) * sd(abundance) / sqrt(n()),
    .groups = "drop"
  )

beta_mzb <- calc_betadiv(mzb, group_by_col = "year")

## ----mzb-plot, fig.width = 10, fig.height = 4---------------------------------
p_alpha <- ggplot(alpha_mzb, aes(x = year, y = mean, ymin = lo, ymax = up)) +
  geom_point() +
  geom_errorbar(width = 0.5) +
  geom_smooth(method = "lm", se = FALSE, linetype = 2) +
  scale_x_continuous(breaks = campaigns) +
  ylim(0, NA) +
  labs(
    title = "Artenvielfalt\n(Alpha-Diversität)",
    x     = "Zeitperiode",
    y     = "Artenvielfalt\n[Anzahl Taxa pro Probestelle]"
  )

p_beta <- ggplot(beta_mzb, aes(x = year, y = betadiv_mean,
                                ymin = betadiv_q25, ymax = betadiv_q75)) +
  geom_point() +
  geom_errorbar(width = 0.5) +
  geom_smooth(method = "lm", se = FALSE, linetype = 2) +
  scale_x_continuous(breaks = campaigns) +
  ylim(0, NA) +
  labs(
    title = "Vielfalt der Artgemeinschaften\n(Beta-Diversität)",
    x     = "Zeitperiode",
    y     = "Vielfalt der Artgemeinschaften\n[Simpson Index (0–1)]"
  )

p_abund <- ggplot(abund_mzb, aes(x = year, y = mean, ymin = lo, ymax = up)) +
  geom_point() +
  geom_errorbar(width = 0.5) +
  geom_smooth(method = "lm", se = FALSE, linetype = 2) +
  scale_x_continuous(breaks = campaigns) +
  ylim(0, NA) +
  labs(
    title = "Abundanz",
    x     = "Zeitperiode",
    y     = "Abundanz\n[Gesamtindividuenzahl pro Probestelle]"
  )

p_alpha + p_beta + p_abund

## ----index-calc---------------------------------------------------------------
gamma_mzb <- calc_gammadiv(mzb, group_by_col = "year")

gamma_indexed <- calc_indicator_index(
  gamma_mzb,
  value_col = "gammadiv",
  group_col = "year",
  ref_value = 2012
)
gamma_indexed

## ----index-plot---------------------------------------------------------------
ggplot(gamma_indexed, aes(x = year, y = index)) +
  geom_hline(yintercept = 100, linetype = 2) +
  geom_point(size = 2) +
  geom_line() +
  scale_x_continuous(breaks = campaigns) +
  labs(
    title = "Gamma-Diversität MZB (Index)",
    x     = "Zeitperiode",
    y     = "Index [2012 = 100]"
  )

## -----------------------------------------------------------------------------
data("fisch")
str(fisch, max.level = 1)

## -----------------------------------------------------------------------------
head(fisch$event)

## -----------------------------------------------------------------------------
head(fisch$occurrence)

## ----fisch-calc---------------------------------------------------------------
fisch_ind <- fisch %>%
  calc_alphadiv() %>%
  calc_abundance(method = "total")

# Custom metric: total biomass per event (sum of totalWeight_g)
biomass_per_event <- fisch$occurrence %>%
  group_by(eventID) %>%
  summarise(biomass_g = sum(totalWeight_g, na.rm = TRUE), .groups = "drop")

fisch_ind$event <- fisch_ind$event %>%
  left_join(biomass_per_event, by = "eventID")

head(fisch_ind$event)

## ----fisch-summary------------------------------------------------------------
campaigns <- c(2012, 2015, 2019, 2023)

alpha_fisch <- fisch_ind$event %>%
  group_by(year) %>%
  summarise(
    mean = mean(alphadiv),
    lo   = mean - qt(0.975, n() - 1) * sd(alphadiv) / sqrt(n()),
    up   = mean + qt(0.975, n() - 1) * sd(alphadiv) / sqrt(n()),
    .groups = "drop"
  )

abund_fisch <- fisch_ind$event %>%
  group_by(year) %>%
  summarise(
    mean = mean(abundance),
    lo   = mean - qt(0.975, n() - 1) * sd(abundance) / sqrt(n()),
    up   = mean + qt(0.975, n() - 1) * sd(abundance) / sqrt(n()),
    .groups = "drop"
  )

biomass_fisch <- fisch_ind$event %>%
  group_by(year) %>%
  summarise(
    mean = mean(biomass_g),
    lo   = mean - qt(0.975, n() - 1) * sd(biomass_g) / sqrt(n()),
    up   = mean + qt(0.975, n() - 1) * sd(biomass_g) / sqrt(n()),
    .groups = "drop"
  )

beta_fisch  <- calc_betadiv(fisch, group_by_col = "year")
gamma_fisch <- calc_gammadiv(fisch, group_by_col = "year")

## ----fisch-plot, fig.width = 10, fig.height = 8-------------------------------
p_alpha_f <- ggplot(alpha_fisch, aes(x = year, y = mean, ymin = lo, ymax = up)) +
  geom_point() +
  geom_errorbar(width = 0.5) +
  geom_smooth(method = "lm", se = FALSE, linetype = 2) +
  scale_x_continuous(breaks = campaigns) +
  ylim(0, NA) +
  labs(
    title = "Artenvielfalt\n(Alpha-Diversität)",
    x     = "Zeitperiode",
    y     = "Artenvielfalt\n[Anzahl Arten pro Probestelle]"
  )

p_abund_f <- ggplot(abund_fisch, aes(x = year, y = mean, ymin = lo, ymax = up)) +
  geom_point() +
  geom_errorbar(width = 0.5) +
  geom_smooth(method = "lm", se = FALSE, linetype = 2) +
  scale_x_continuous(breaks = campaigns) +
  ylim(0, NA) +
  labs(
    title = "Abundanz",
    x     = "Zeitperiode",
    y     = "Abundanz\n[Gesamtindividuenzahl pro Probestelle]"
  )

p_biomass_f <- ggplot(biomass_fisch, aes(x = year, y = mean, ymin = lo, ymax = up)) +
  geom_point() +
  geom_errorbar(width = 0.5) +
  geom_smooth(method = "lm", se = FALSE, linetype = 2) +
  scale_x_continuous(breaks = campaigns) +
  ylim(0, NA) +
  labs(
    title = "Biomasse",
    x     = "Zeitperiode",
    y     = "Biomasse\n[Gesamtgewicht g pro Probestelle]"
  )

p_beta_f <- ggplot(beta_fisch, aes(x = year, y = betadiv_mean,
                                    ymin = betadiv_q25, ymax = betadiv_q75)) +
  geom_point() +
  geom_errorbar(width = 0.5) +
  geom_smooth(method = "lm", se = FALSE, linetype = 2) +
  scale_x_continuous(breaks = campaigns) +
  ylim(0, NA) +
  labs(
    title = "Vielfalt der Artgemeinschaften\n(Beta-Diversität)",
    x     = "Zeitperiode",
    y     = "Vielfalt der Artgemeinschaften\n[Simpson Index (0–1)]"
  )

(p_alpha_f + p_abund_f) / (p_biomass_f + p_beta_f)

## ----fisch-gamma, fig.width = 5, fig.height = 4-------------------------------
ggplot(gamma_fisch, aes(x = year, y = gammadiv)) +
  geom_point(size = 2) +
  geom_smooth(method = "lm", se = FALSE, linetype = 2) +
  scale_x_continuous(breaks = campaigns) +
  ylim(0, NA) +
  labs(
    title = "Gamma-Diversität Fische",
    x     = "Zeitperiode",
    y     = "Gesamtartenzahl"
  )

