#           Copyright(c) Antoine Champion 2017.
#  Distributed under the Boost Software License, Version 1.0 .
#     (See accompanying file LICENSE_1_0.txt or copy at
#           http://www.boost.org/LICENSE_1_0.txt)

#' @import magrittr
#' NULL

#' @title       Some
#' Make a variable optional
#'
#' Note that `some(some(i)) == some(i)` 
#' and `some(none) == FALSE`
#'
#' @param arg   The variable to make optional
#' @return      `some(arg)`
#' @seealso     `none`, `opt_unwrap`
#' @examples
#' a <- some(5)
#' class(a)
#' > [1] "optional"
#' a == 5
#' > [1] TRUE
#' @export
some <- function(arg) {
  if (class(arg) == "optional") {
    if (attr(arg, "option_none")) return(FALSE)
    else                          return(arg)
  }
  if (is.null(arg)) return(none)
  attr(arg, "option_class") <- attr(arg, "class")
  attr(arg, "option_none") <- FALSE
  attr(arg, "class") <- "optional"
  return(arg)
}

#' @export
none <- some(TRUE)
attr(none, "option_none") <- TRUE

#' @export
opt_unwrap <- function(opt) {
  if ("class" %in% attributes(opt)
      && attr(opt, "class") != "optional")
        return(opt)
  attr(opt, "class") <- attr(opt, "option_class")
  attr(opt, "option_class") <- NULL
  attr(opt, "option_none") <- NULL
  return(opt)
}

#' @export
`==.optional` <- function(e1, e2) {
  if (class(e1) == "optional" && attr(e1, "option_none"))
    return(class(e2) == "optional" && attr(e2, "option_none"))

  if (class(e2) == "optional" && attr(e2, "option_none"))
    return(class(e1) == "optional" && attr(e1, "option_none"))

  return(opt_unwrap(e1) == opt_unwrap(e2))
}

#' @export
make_opt <- function(fun, stop_if_none = TRUE, fun_if_none = NULL) {
  return(function(...) {
    args = list(...)
    to_null = c()

    if (length(args) != 0) {
      for (i in 1:length(args)) {

        if (class(args[[i]]) != "optional") next

        if (args[[i]] == none) {
          if (stop_if_none) return(none)

          to_null <- c(to_null, i)

          if (!is.null(fun_if_none))
            fun_if_none()        
        }

        else {
          attr(args[[i]], "class") <- attr(args[[i]], "option_class")
          attr(args[[i]], "option_class") <- NULL
          attr(args[[i]], "option_none") <- NULL
        }
      }
    }

    args[to_null] <- NULL

    tryCatch(ret <- do.call(fun, args),
             error = function(e) {
               ret <- NULL
             }
    )
    if (is.null(ret))
      return(none)
    else
      return(some(ret))
  })
}

#' @export
print.optional <- function(opt, ...) {
  if (attr(opt, "option_none")) {
    print("None", ...)
  } else {
    attr(opt, "class") <- attr(opt, "option_class")
    attr(opt, "option_class") <- NULL
    attr(opt, "option_none") <- NULL
    print(opt, ...)
  }
}

opt_call_match_ <- function(fun, x) {
  if (length(formalArgs(fun)) != 0)
    fun(x)
  else
    fun()
}

#' @export
match_with <- function(x, ...) {
  args <- list(...)
  n <- length(args)
  if (n < 0) return(none)

  for (i in seq(1, n, 2)) {
    if ("fseq" %in% class(args[[i]])) {
      ret <- args[[i]](x)
      if (!is.null(ret) && ret == x) {
        return(opt_call_match_(args[[i + 1]], x))
      }
    }
    else if ("list" %in% class(args[[i]])) {
      if (x %in% args[[i]]) {
        return(opt_call_match_(args[[i + 1]], x))
      }
    }
    else if (isTRUE(all.equal(x, args[[i]]))) {
      return(opt_call_match_(args[[i + 1]], x))
    }
  }

  return(none)
}