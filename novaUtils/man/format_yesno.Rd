% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/formatFields.R
\name{format_yesno}
\alias{format_yesno}
\title{Format integer-like character field}
\usage{
format_yesno(field = NULL, yes = 1, no = 0, asFactor = FALSE)
}
\arguments{
\item{field}{Vector to be converted to a character vector}

\item{yes}{Integer containing the number associated with "yes"}

\item{no}{Integer containing the number associated with "no"}

\item{asFactor}{Logical that determines whether the field should be encoded as a factor}
}
\value{
Formatted field returned either as a character vector or a vector encoded as a factor
}
\description{
Function that receives an integer-like character field and replaces character strings 
containing "1" and "0" with "yes" and "no" whilst also removing duplicate values
}

