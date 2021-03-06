% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/merge_imputations.R
\name{merge_imputations}
\alias{merge_imputations}
\title{Merges multiple imputed data frames into a single data frame}
\usage{
merge_imputations(dat, imp, ori = NULL)
}
\arguments{
\item{dat}{The data frame that was imputed and used as argument in the
\code{\link[mice]{mice}}-function call.}

\item{imp}{The \code{\link[mice]{mids}}-object with the imputed data frames
from \code{dat}.}

\item{ori}{Optional, if \code{ori} is specified, the imputed variables are
appended to this data frame; else, a new data frame with the imputed
variables is returned.}
}
\value{
A data frame with imputed variables; or \code{ori} with
        appended imputed variables, if \code{ori} was specified.
}
\description{
This function merges multiple imputed data frames from
               \code{\link[mice]{mids}}-objects into a single data frame
               by computing the mean or selecting the most likely imputed value.
}
\details{
This method merges multiple imputations of variables into a single
         variable by computing the (rounded) mean of all imputed values
         of missing values. By this, each missing value is replaced by
         those values that have been imputed the most times.
         \cr \cr
         \code{imp} must be a \code{mids}-object, which is returned by the
         \code{mice}-function of the \pkg{mice}-package. \code{merge_imputations} than
         creates a data frame for each imputed variable, by combining all
         imputations (as returned by the \code{\link[mice]{complete}}-function)
         of each variable, and computing the row means of this data frame.
         The mean value is then rounded for integer values (and not for numerical
         values with fractional part), which corresponds to the most frequent
         imputed value for a missing value. The original variable with missings
         is then copied and missing values are replaced by the most frequent imputed
         value.
}
\note{
Typically, further analyses are conducted on pooled results of multiple
      imputed data sets (see \code{\link[mice]{pool}}), however, sometimes
      (in social sciences) it is also feasible to compute the mean of multiple
      imputed variables (see \cite{Burns et al. 2011}).
}
\examples{
library(mice)
imp <- mice(nhanes)

# return data frame with imputed variables
merge_imputations(nhanes, imp)

# append imputed variables to original data frame
merge_imputations(nhanes, imp, nhanes)

}
\references{
Burns RA, Butterworth P, Kiely KM, Bielak AAM, Luszcz MA, Mitchell P, et al. 2011. Multiple imputation was an efficient method for harmonizing the Mini-Mental State Examination with missing item-level data. Journal of Clinical Epidemiology;64:787–93 \doi{10.1016/j.jclinepi.2010.10.011}
}
