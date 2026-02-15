## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 4
)

## ----setup, message = FALSE---------------------------------------------------
library(msk)
library(dplyr)
library(ggplot2)

## -----------------------------------------------------------------------------
data("dia")
str(dia, max.level = 1)

## -----------------------------------------------------------------------------
head(dia$event)

## -----------------------------------------------------------------------------
head(dia$occurrence)

## -----------------------------------------------------------------------------
dat <- dia %>%
  calc_alphadiv()

head(dat$event)

## -----------------------------------------------------------------------------
dat <- dat %>%
  calc_abundance()

head(dat$event)

## ----eval = FALSE-------------------------------------------------------------
# dat <- dia %>%
#   calc_alphadiv() %>%
#   calc_abundance()

## -----------------------------------------------------------------------------
# Overall gamma diversity
calc_gammadiv(dia)

## -----------------------------------------------------------------------------
dat$event$year <- as.integer(format(dat$event$eventDate, "%Y"))

gamma_by_year <- calc_gammadiv(dat, group_by_col = "year")
gamma_by_year

## -----------------------------------------------------------------------------
# Overall beta diversity
calc_betadiv(dia)

## -----------------------------------------------------------------------------
# Beta diversity per year
beta_by_year <- calc_betadiv(dat, group_by_col = "year")
beta_by_year

## ----alpha-plot---------------------------------------------------------------
alpha_summary <- dat$event %>%
  group_by(year) %>%
  summarise(
    mean = mean(alphadiv),
    lo = mean - qt(0.975, n() - 1) * sd(alphadiv) / sqrt(n()),
    up = mean + qt(0.975, n() - 1) * sd(alphadiv) / sqrt(n())
  )

ggplot(alpha_summary, aes(x = year, y = mean, ymin = lo, ymax = up)) +
  geom_point() +
  geom_errorbar(width = 0.2) +
  geom_smooth(method = "lm", se = FALSE, linetype = 2) +
  ylim(0, NA) +
  labs(
    title = "Alpha Diversity",
    x = "",
    y = "Number of taxa per event"
  )

## ----gamma-plot---------------------------------------------------------------
ggplot(gamma_by_year, aes(x = year, y = gammadiv)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, linetype = 2) +
  ylim(0, NA) +
  labs(
    title = "Gamma Diversity",
    x = "",
    y = "Total number of taxa"
  )

## ----beta-plot----------------------------------------------------------------
ggplot(beta_by_year, aes(x = year, y = betadiv_mean,
                         ymin = betadiv_q25, ymax = betadiv_q75)) +
  geom_point() +
  geom_errorbar(width = 0.2) +
  geom_smooth(method = "lm", se = FALSE, linetype = 2) +
  ylim(0, NA) +
  labs(
    title = "Beta Diversity (Simpson Dissimilarity)",
    x = "",
    y = "Community dissimilarity"
  )

## -----------------------------------------------------------------------------
gamma_indexed <- calc_indicator_index(
  gamma_by_year,
  value_col = "gammadiv",
  group_col = "year",
  ref_value = min(gamma_by_year$year)
)
gamma_indexed

## ----index-plot---------------------------------------------------------------
ggplot(gamma_indexed, aes(x = year, y = index)) +
  geom_hline(yintercept = 100, linetype = 2) +
  geom_point() +
  geom_line() +
  labs(
    title = "Gamma Diversity Index",
    x = "",
    y = paste0("Index [", min(gamma_by_year$year), " = 100]")
  )

