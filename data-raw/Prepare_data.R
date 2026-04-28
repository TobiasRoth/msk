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

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# MZB ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

load("../10-R/Daten/MZB/mzb.RData")

# Neozoen und Datensätze ohne Taxon-Zuweisung ausschliessen
mzb <- mzb %>% filter(neozoo == 0, !is.na(taxon_ibch))

# Höhe numerisch, nur Stationen <= 1000 m ü.M.
mzb$alt <- as.numeric(mzb$alt)
mzb <- mzb %>% filter(alt <= 1000)

# Nur 4 NAWA-Kampagnen
campaigns <- c(2012, 2015, 2019, 2023)
mzb <- mzb %>% filter(year %in% campaigns)

# Nur Stationen mit Aufnahmen in allen 4 Kampagnen
stao_komplett <- mzb %>%
  group_by(aID_STAO) %>%
  dplyr::summarise(n_kampagnen = n_distinct(year), .groups = "drop") %>%
  filter(n_kampagnen == 4) %>%
  pull(aID_STAO)
mzb <- mzb %>% filter(aID_STAO %in% stao_komplett)

# Abundanz als Integer
mzb <- mzb %>% mutate(abund = as.integer(abund))

event <- mzb %>%
  group_by(eventID = aID) %>%
  dplyr::summarise(
    eventDate  = first(date),
    locationID = first(aID_STAO),
    year       = first(year),
    altitude   = first(alt)
  )

occurrence <- mzb %>%
  transmute(
    eventID         = aID,
    taxonID         = taxon_ibch,
    individualCount = abund
  )

mzb <- list(
  event      = event,
  occurrence = occurrence
)

usethis::use_data(mzb, overwrite = TRUE)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Fische ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

load("../10-R/Daten/Fische/kdfisch.RData")
load("../10-R/Daten/Fische/fisch.RData")

# Nur Stationen <= 1000 m ü.M. (kdfisch bereits auf 4 Kampagnen beschränkt)
kdfisch <- kdfisch %>% filter(alt <= 1000)

# Nur Stationen mit mindestens 3 Kampagnen
stao_komplett <- kdfisch %>%
  group_by(aID_STAO) %>%
  dplyr::summarise(n_kampagnen = n_distinct(year), .groups = "drop") %>%
  filter(n_kampagnen >= 3) %>%
  pull(aID_STAO)
kdfisch <- kdfisch %>% filter(aID_STAO %in% stao_komplett)

# fisch auf gefilterte Events einschränken
fisch <- fisch %>% filter(aID %in% kdfisch$aID)

# Artennamen-Lookup (eindeutig pro NUESP)
sp_lookup <- fisch %>%
  dplyr::select(taxonID = NUESP, scientificName = Name_W, vernacularName = Name_D) %>%
  dplyr::distinct(taxonID, .keep_all = TRUE)

# Occurrence: pro Event × Art aggregieren (jede Zeile = 1 Individuum)
occurrence <- fisch %>%
  dplyr::group_by(eventID = aID, taxonID = NUESP) %>%
  dplyr::summarise(
    individualCount = sum(abund, na.rm = TRUE),
    totalWeight_g   = sum(Gewicht_g, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  dplyr::left_join(sp_lookup, by = "taxonID")

event <- kdfisch %>%
  transmute(
    eventID    = aID,
    locationID = aID_STAO,
    year       = year,
    altitude   = alt,
    stream     = stream,
    N_runs     = N_runs
  )

fisch <- list(
  event      = event,
  occurrence = occurrence
)

usethis::use_data(fisch, overwrite = TRUE)
