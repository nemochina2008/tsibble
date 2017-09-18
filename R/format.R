#' @export
print.tbl_ts <- function(x, ..., n = NULL, width = NULL, n_extra = NULL) {
  cat_line(format(x, ..., n = n, width = width, n_extra = n_extra))
  invisible(x)
}

format.tbl_ts <- function(x, ..., n = NULL, width = NULL, n_extra = NULL) {
  format(tibble::trunc_mat(x, n = n, width = width, n_extra = n_extra))
}

print.key <- function(x, ...) {
  cat_line(format(x, ...))
  invisible(x)
}

format.key <- function(x, ...) {
  if (is_empty(x)) {
    return(NULL)
  }
  nest_lgl <- is_nest(x)
  comb_keys <- paste(as.character(x[!nest_lgl]), collapse = ", ")
  if (any(nest_lgl)) {
    nest_keys <- as.character(purrr::map(x[nest_lgl], ~ .[[1]]))
    cond_keys <- paste(nest_keys, collapse = " | ")
    comb_keys <- paste(cond_keys, comb_keys, collapse = ", ")
  }
  comb_keys
}

print.interval <- function(x, ...) {
  cat_line(format(x, ...))
  invisible(x)
}

format.interval <- function(x, ...) {
  not_zero <- !purrr::map_lgl(x, function(x) x == 0)
  output <- x[not_zero]
  paste0(rlang::flatten_dbl(output), toupper(names(output)))
}

# ref: tibble:::cat_line
cat_line <- function(...) {
  cat(paste0(..., "\n"), sep = "")
}