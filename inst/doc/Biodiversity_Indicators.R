## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------

# Libraries
library(tidyverse)
library(Rmisc)
library(ggthemes)
library(readxl)
library(msk)

# Plot settings
theme_set(
  theme_clean() +
    theme(
      legend.title = element_blank(), 
      legend.position = "right", 
      legend.background = element_rect(colour = "white"),
      plot.background = element_blank())
)
options(ggplot2.discrete.colour= c("#1F78B4", "#FF7F00", "#33A02C", "#E31A1C", "#6A3D9A"))

## -----------------------------------------------------------------------------
dat <- 
  dia %>% 
  calc_alphadiv()

## -----------------------------------------------------------------------------
dat$event

## -----------------------------------------------------------------------------
dat$event %>% 
  group_by(year = year(eventDate)) %>% 
  dplyr::summarise(
    av = mean(alphadiv)
  ) %>% 
  ggplot(aes(x = year, y = av)) +
  geom_point() +
  geom_smooth(method = lm) +
  ylim(0, NA) +
  labs(
    x = "Species richness",
    y = ""
  )

