#           Copyright(c) Antoine Champion 2017.
#  Distributed under the Boost Software License, Version 1.0 .
#     (See accompanying file LICENSE_1_0.txt or copy at
#           http://www.boost.org/LICENSE_1_0.txt)

#' @importFrom methods formalArgs
#' @importFrom magrittr %>%
NULL

#' @title       Some
#' @usage       some(arg)
#' @description
#' Make a variable optional. 
#'
#' \code{optional} is an object wrapper which indicates
#' whether the object is valid or not.
#' @details
#' Note that \code{some(some(i)) == some(i)}
#' and \code{some(none) == FALSE}
#' 
#' Operators and print will have the same behavior with 
#' an optional than with its base type.
#' 
#' @param arg   The variable to make optional
#' @return      \code{arg} as \code{optional}
#' @seealso     none, opt_unwrap(), make_opt()
#' @examples
#' a <- some(5)
#' class(a)
#' ## [1] "optional"
#'
#' a == 5
#' ## [1] TRUE
#'
#' a
#' ## [1] 5
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

#' @title       None
#' @description
#' Indicates an invalid variable.
#' Might be returned by an optional function 
#' (see \code{?make_opt()})
#'
#' @seealso     some(), opt_unwrap()
#' @examples
#' a <- none
#' a
#' ## [1] None
#' @export
none <- some(TRUE)
attr(none, "option_none") <- TRUE

#' @title       Option Unwrap
#' @usage 		opt_unwrap(opt)
#' 
#' @description
#' Cast an optional object to its base type.
#' @details
#' Since an optional can be used the same way as its
#' base type, there is no known scenario where this
#' function might be useful.
#' 
#' @param opt   The optional variable to cast back
#' @return      The object wrapped in \code{opt}. 
#'              \code{NULL} if \code{opt} is \code{none}.
#' @seealso     make_opt(), match_with()
#' @examples
#' a <- some(5)
#' class(a)
#' ## [1] "optional"
#' a <- opt_unwrap(a)
#'
#' class(a)
#' ## [1] "numeric"
#' @export
opt_unwrap <- function(opt) {
  if (class(opt) != "optional")
        return(opt)

  if (attr(opt, "option_none"))
    return(NULL)

  attr(opt, "class") <- attr(opt, "option_class")
  attr(opt, "option_class") <- NULL
  attr(opt, "option_none") <- NULL

  return(opt)
}

# Equal operator overload
#' @export
`==.optional` <- function(e1, e2) {
  if (class(e1) == "optional" && attr(e1, "option_none"))
    return(class(e2) == "optional" && attr(e2, "option_none"))

  if (class(e2) == "optional" && attr(e2, "option_none"))
    return(class(e1) == "optional" && attr(e1, "option_none"))

  return(opt_unwrap(e1) == opt_unwrap(e2))
}

#' @title                       Make optional
#' @description
#' Make an existing function accepting and returning optionals.
#' @usage make_opt(fun, stop_if_none = FALSE, fun_if_none = NULL)
#' @details
#' \enumerate{
#'   \item Every optional argument passed to \code{f_opt()} will be  
#'         converted to its original type before being sent 
#'         to \code{f()}. If one or more of them is \code{none},  
#'         several behaviors are available (see argument list).
#'   \item If \code{f()} returns null, or if an error is thrown 
#'         during its execution, then \code{f_opt()} returns 
#'         \code{none}. Else it will return  \code{some(f(...))}.
#' }
#' @param fun                   The function to make optional, might be any 
#'                              function.
#' @param stop_if_none          If true, \code{f_opt()} will stop and return 
#'                              \code{none} if one of the arguments provided 
#'                              is \code{none}. Else, \code{none} will be 
#'                              sent as \code{NULL} to the function.
#'                              *Default: FALSE*
#' @param fun_if_none           If not null, will be executed if an argument
#'                              is \code{none}.
#'                              *Default: NULL*
#' @return                      The optional function. To be used with the
#'                              same parameters than \code{fun()}.
#' @seealso                     some(), none(), match_with()
#' @examples
#' c_opt <- make_opt(c)
#' c_opt(some(2), none, some(5))
#' ## [1] 2 5
#' c_opt()
#' ## [1] "None"
#' @export
make_opt <- function(fun, stop_if_none = FALSE, fun_if_none = NULL) {
  return(function(...) {
    args <- list(...)
    to_null <- c()

    if (length(args) != 0) {
      for (i in 1:length(args)) {

        if (class(args[[i]]) != "optional") next

        if (args[[i]] == none) {
          if (!is.null(fun_if_none))
            fun_if_none()

          if (stop_if_none) return(none)

          to_null <- c(to_null, i)
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

# Print generic overload
#' @export
print.optional <- function(x, ...) {
  if (attr(x, "option_none")) {
    print("None", ...)
  } else {
    attr(x, "class") <- attr(x, "option_class")
    attr(x, "option_class") <- NULL
    attr(x, "option_none") <- NULL
    print(x, ...)
  }
}

# If fun has zero arguments, calls fun()
# else calls fun(x)
opt_call_match_ <- function(fun, x) {
  if (length(formalArgs(fun)) != 0)
    fun(x)
  else
    fun()
}

#' @title       Match With
#' @usage		match_with(x, ...)
#' 
#' @description
#' Function to check a variable using pattern matching.
#' @details
#' \code{match_with(variable,
#' pattern, result-function,
#' ...}
#' If \code{variable} matches a \code{pattern}, \code{result-function}
#' is called. For comparing optional types, it is a better habit to 
#' use \code{match_with} than a conditional statement.
#'
#' \enumerate{
#'   \item Each \code{pattern} can be either:
#'     \itemize{
#'       \item an object or a primitive type (direct comparison with \code{variable}),
#'       \item a list (match if \code{variable} is in the list),
#'       \item a \code{magrittr} functional sequence that matches if it returns \code{variable} . The dot \code{.} denotes the variable to be matched.
#'     }
#'   \item If \code{result-function} takes no arguments, it will be called as is. Else, the only argument that will be sent is \code{variable}.
#' }
#'
#' @param x     The variable to pattern-match
#' @param ...   Pairs of one pattern (value or list or magrittr 
#'              sequence) and one result function
#' @return      The object wrapped in \code{opt}
#' @seealso     some(), none
#' @examples
#' library(magrittr)
#'
#' a <- 5
#' match_with(a,
#'   . %>% some(.),     print,
#'   none, function()   print("Error!")
#' )
#' ## [1] 5
#'
#' match_with(a,
#'   1, function()        print("Matched exact value"),
#'   list(2, 3, 4),       function(x) paste("Matched in list:", x),
#'   . %>% if (. > 4) .,  function(x) paste("Matched in condition:", x)
#' )
#' ## [1] "Matched in condition: 5"
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
