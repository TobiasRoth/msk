rm(list = ls(all = TRUE))

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Settings ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Libraries
library(tidyverse)
library(usethis)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Diatomeen ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

load("../10-R/Daten/Diatomeen/dia.RData")

# Daten in DaC speichern
event <- dia %>%
  group_by(eventID = aID) %>%
  dplyr::summarise(
    eventDate = first(date)
  )

occurence <- dia %>%
  transmute(
    taxonID = aID_SP,
    # taxonRank = "species",
    eventID = aID,
    individualCount = abund
  )

dia <- list(
  event = event,
  occurence = occurence
)

usethis::use_data(dia, overwrite = TRUE)
