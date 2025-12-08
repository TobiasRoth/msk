rm(list = ls(all = TRUE))

# Libraries
library(tidyverse)
library(usethis)

# Packetstruktur erstellen
create_package("../msk")

# Vignette erstellen
usethis::use_vignette("Biodiversity_Indicators")
