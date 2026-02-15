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

occurrence <- dia %>%
  transmute(
    taxonID = aID_SP,
    # taxonRank = "species",
    eventID = aID,
    individualCount = abund
  )

dia <- list(
  event = event,
  occurrence = occurrence
)

usethis::use_data(dia, overwrite = TRUE)
