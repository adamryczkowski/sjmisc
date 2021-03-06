#' @title Split numeric variables into smaller groups
#' @name split_var
#'
#' @description Recode numeric variables into equal sized groups, i.e. a
#'                variable is cut into a smaller number of groups at
#'                specific cut points.
#'
#' @seealso \code{\link{group_var}} to group variables into equal ranged groups,
#'          or \code{\link{rec}} to recode variables.
#'
#' @param groupcount The new number of groups that \code{x} should be split into.
#' @param inclusive Logical; if \code{TRUE}, cut point value are included in
#'          the preceeding group. This may be necessary if cutting a vector into
#'          groups does not define proper ("equal sized") group sizes.
#'          See 'Note' and 'Examples'.
#'
#' @inheritParams to_factor
#' @inheritParams group_var
#' @inheritParams rec
#'
#' @return A grouped variable with equal sized groups. If \code{x} is a data
#'         frame, only the grouped variables will be returned.
#'
#' @details \code{split_var} splits a variable into equal sized groups, where the
#'            amount of groups depends on the \code{groupcount}-argument. Thus,
#'            this functions \code{\link{cut}s} a variable into groups at the
#'            specified \code{\link[stats]{quantile}s}.
#'            \cr \cr
#'            By contrast, \code{\link{group_var}} recodes a variable into
#'            groups, where groups have the same value range
#'            (e.g., from 1-5, 6-10, 11-15 etc.).
#'
#' @note In case a vector has only few different unique values, splitting into
#'         equal sized groups may fail. In this case, use the \code{inclusive}-argument
#'         to shift a value at the cut point into the lower, preceeding group to
#'         get equal sized groups. See 'Examples'.
#'
#' @examples
#' data(efc)
#' # non-grouped
#' table(efc$neg_c_7)
#'
#' # split into 3 groups
#' table(split_var(efc$neg_c_7, groupcount = 3))
#'
#' # split multiple variables into 3 groups
#' split_var(efc, neg_c_7, pos_v_4, e17age, groupcount = 3)
#' frq(split_var(efc, neg_c_7, pos_v_4, e17age, groupcount = 3))
#'
#' # original
#' table(efc$e42dep)
#'
#' # two groups, non-inclusive cut-point
#' # vector split leads to unequal group sizes
#' table(split_var(efc$e42dep, groupcount = 2))
#'
#' # two groups, inclusive cut-point
#' # group sizes are equal
#' table(split_var(efc$e42dep, groupcount = 2, inclusive = TRUE))
#'
#' @importFrom stats quantile
#' @export
split_var <- function(x, ..., groupcount, as.num = FALSE, val.labels = NULL, var.label = NULL, inclusive = FALSE, suffix = "_g") {
  # evaluate arguments, generate data
  .dots <- match.call(expand.dots = FALSE)$`...`
  .dat <- get_dot_data(x, .dots)

  if (is.data.frame(x)) {

    # iterate variables of data frame
    for (i in colnames(.dat)) {
      x[[i]] <- split_var_helper(
        x = .dat[[i]],
        groupcount = groupcount,
        as.num = as.num,
        var.label = var.label,
        val.labels = val.labels,
        inclusive = inclusive
      )
    }

    # coerce to tibble and select only recoded variables
    x <- tibble::as_tibble(x[colnames(.dat)])

    # add suffix to recoded variables?
    if (!is.null(suffix) && !sjmisc::is_empty(suffix)) {
      colnames(x) <- sprintf("%s%s", colnames(x), suffix)
    }
  } else {
    x <- split_var_helper(
      x = .dat,
      groupcount = groupcount,
      as.num = as.num,
      var.label = var.label,
      val.labels = val.labels,
      inclusive = inclusive
    )
  }

  x
}

split_var_helper <- function(x, groupcount, as.num, val.labels, var.label, inclusive) {
  # retrieve variable label
  if (is.null(var.label))
    var_lab <- get_label(x)
  else
    var_lab <- var.label
  # do we have any value labels?
  val_lab <- val.labels
  # amount of "cuts" is groupcount - 1
  zaehler <- seq_len(groupcount - 1)
  # prepare division
  nenner <- rep(groupcount, length(zaehler))
  # get quantiles
  qu_prob <- zaehler / nenner
  # get quantile values
  grp_cuts <- stats::quantile(x, qu_prob, na.rm = TRUE)
  # cut variables into groups
  retval <- cut(x,
                c(0, grp_cuts, max(x, na.rm = T)),
                include.lowest = !inclusive,
                right = inclusive)
  # rename factor levels
  levels(retval) <- seq_len(groupcount)
  # to numeric?
  if (as.num) retval <- to_value(retval)
  # set back variable and value labels
  retval <- suppressWarnings(set_label(retval, lab = var_lab))
  retval <- suppressWarnings(set_labels(retval, labels = val_lab))
  # return value
  return(retval)
}
