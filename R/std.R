#' @title Standardize and center variables
#' @name std
#' @description \code{std()} computes a z-transformation (standardized and centered)
#'              on the input. \code{center()} centers the input.
#'
#' @param include.fac Logical, if \code{TRUE}, factors will be converted to numeric
#'          vectors and also standardized or centered.
#'
#' @inheritParams to_factor
#' @inheritParams rec
#'
#' @return A vector with standardized or centered variables. If \code{x} is a
#'         data frame, only the transformed variables will be returned.
#'
#' @note \code{std()} and \code{center()} only return a vector, if \code{x} is
#'         a vector. If \code{x} is a data frame and only one variable is specified
#'         in the \code{...}-ellipses argument, both functions do return a
#'         data frame (see 'Examples').
#'
#' @examples
#' library(dplyr)
#' data(efc)
#' std(efc$c160age) %>% head()
#' std(efc, e17age, c160age) %>% head()
#'
#' center(efc$c160age) %>% head()
#' center(efc, e17age, c160age) %>% head()
#'
#' # NOTE!
#' std(efc$e17age) # returns a vector
#' std(efc, e17age) # returns a tibble
#'
#' # works with mutate()
#' efc %>%
#'   select(e17age, neg_c_7) %>%
#'   mutate(age_std = std(e17age), burden = center(neg_c_7)) %>%
#'   head()
#'
#' @export
std <- function(x, ..., include.fac = TRUE, suffix = "_z") {
  # evaluate arguments, generate data
  .dots <- match.call(expand.dots = FALSE)$`...`
  .dat <- get_dot_data(x, .dots)

  std_and_center(x, .dat, include.fac, standardize = TRUE, suffix)
}


#' @rdname std
#' @export
center <- function(x, ..., include.fac = TRUE, suffix = "_c") {
  # evaluate arguments, generate data
  .dots <- match.call(expand.dots = FALSE)$`...`
  .dat <- get_dot_data(x, .dots)

  std_and_center(x, .dat, include.fac, standardize = FALSE, suffix)
}


std_and_center <- function(x, .dat, include.fac, standardize, suffix) {
  if (is.data.frame(x)) {

    # iterate variables of data frame
    for (i in colnames(.dat)) {
      x[[i]] <- std_helper(
        x = .dat[[i]],
        include.fac = include.fac,
        standardize = standardize
      )
    }

    # coerce to tibble and select only recoded variables
    x <- tibble::as_tibble(x[colnames(.dat)])

    # add suffix to recoded variables?
    if (!is.null(suffix) && !sjmisc::is_empty(suffix)) {
      colnames(x) <- sprintf("%s%s", colnames(x), suffix)
    }
  } else {
    x <- std_helper(
      x = .dat,
      include.fac = include.fac,
      standardize = standardize
    )
  }

  x
}


#' @importFrom stats sd na.omit
std_helper <- function(x, include.fac, standardize) {
  # check whether factors should also be standardized
  if (is.factor(x)) {
    if (include.fac)
      x <- to_value(x, keep.labels = FALSE)
    else
      return(x)
  }
  # remove missings
  tmp <- stats::na.omit(x)
  # save value label, if any
  lab <- get_label(x)
  # now center and standardize
  tmp <- tmp - mean(tmp)
  if (standardize) tmp <- tmp / stats::sd(tmp)
  # and fill in values in original vector
  x[!is.na(x)] <- tmp
  # add back label
  set_label(x, lab)
}