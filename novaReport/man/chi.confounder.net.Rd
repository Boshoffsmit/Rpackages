% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/chi.confounder.net.R
\name{chi.confounder.net}
\alias{chi.confounder.net}
\title{Confounder Chi-net}
\usage{
chi.confounder.net(df, outcome = "outcome", exposure = "exposure",
  outdir = "graphs/", stoor = TRUE)
}
\arguments{
\item{df}{Data frame}

\item{outcome}{Character vector}

\item{exposure}{Character vector}

\item{outdir}{Character vector referring to output directory}

\item{stoor}{Logical that stores the file as pdf}
}
\description{
Function to graphically display chi2 test results to 
ID confounders. Requires a data frame with outcome and exposures 
such as the one provided by the chi.2.eksp function. Receives a data frame 
and returns a list of network objects
}

