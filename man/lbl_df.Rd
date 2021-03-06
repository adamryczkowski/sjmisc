% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/as_labelled.R
\name{lbl_df}
\alias{lbl_df}
\title{Create a labelled data frame}
\usage{
lbl_df(x)
}
\arguments{
\item{x}{A data frame.}
}
\value{
\code{x}, with \code{lbl_df} class-attribute.
}
\description{
This method wraps a local data frame and adds a \code{lbl_df} class
               attribute. Printing a \code{lbl_df}-data frame is comparable
               to printing \code{\link[tibble]{tibble}} objects, but the class
               information in the output is replaced by the variable label.
}
\examples{
data(efc)
library(dplyr)

efc \%>\%
  select(e15relat, e16sex, e17age) \%>\%
  slice(1:3) \%>\%
  lbl_df()

efc \%>\%
  select(e15relat, e16sex, e17age) \%>\%
  to_label() \%>\%
  set_label(c("Relationship", "Elder's gender", "Elder's age")) \%>\%
  lbl_df()

}
