# R-package msk

[![Travis-CI Build Status](https://travis-ci.org/TobiasRoth/msk.svg?branch=master)](https://travis-ci.org/TobiasRoth/msk)

## Overview

R package for calculating biodiversity indicators based on data from the Swiss Modular Stepwise Procedure ([Modulstufenkonzept MSK](https://modul-stufen-konzept.ch/en/about-the-msp/)). The MSK is a set of methods for surveying and assessing the status of water bodies. It is a collaboration between the federal government, cantons and research institutions. Launched in 1998, methods are now available for the most important aspects of assessing the status of watercourses in accordance with water protection legislation.

## Installation

````         
``` r
# Install the package from GitHub (first option)
# install.packages("pak")
pak::pak("TobiasRoth/msk")

# Install the package from GitHub (second option)
# install.packages("devtools")
devtools::install_github("TobiasRoth/msk")

# Load library 
library(macrobent)
```
````

## Data Structure

## Usage

The following example uses msk to calculate the biodiversity indicators based on NAWA data:
