\name{atime}
\alias{atime}
\title{Asymptotic timing}
\description{Computation time and memory for several R expressions of
  several different data sizes.}

\usage{atime(
 N, setup, expr.list=NULL, times=10, seconds.limit=0.01, verbose=FALSE,
 result=FALSE, N.env.parent=NULL, ...)}

\arguments{
  \item{N}{numeric vector of at least two unique data sizes, default is \code{2^seq(2,20)}.}
  \item{setup}{expression to evaluate for every data size, before timings.}
  \item{expr.list}{named list of expressions to time.}
  \item{times}{number of times to evaluate each timed expression.}
  \item{seconds.limit}{if the median timing of any expression exceeds
    this many seconds, then no timings for larger N are computed.}
  \item{verbose}{logical, print messages after every data size?}
  \item{result}{
    logical: save the result of evaluating each expression?
    Or a function to compute a result, given the value obtained after
    evaluating each expression.
    If each result is a data frame with one row, then the numeric column
    names will be saved as more units to analyze (in addition to kilobytes
    and seconds).
  }
  \item{N.env.parent}{environment to use as parent of environment
  created for each data size N, or NULL to use default parent env.}
  \item{\dots}{named expressions to time.}
}

\details{Each iteration involves first computing the setup expression,
  and then computing several times the \dots expressions. For
  convenience, expressions may be specified either via code (\dots) or
  data (\code{expr.list} arg).}

\seealso{\code{\link{atime_grid}} for avoiding repetition when measuring
  asymptotic properties of several similar expressions.}

\value{list of class atime with elements \code{unit.col.vec} (character
  vector of column names to analyze), \code{seconds.limit} (numeric
  input param), \code{measurements} (data table of results).}

\author{Toby Dylan Hocking}

\examples{

data.table::setDTthreads(1) # for CRAN.

## Polynomial and exponential time string functions.
atime_result_string <- atime::atime(
  seconds.limit=0.001,
  N=unique(as.integer(10^seq(0,3,l=100))),
  setup={
    subject <- paste(rep("a", N), collapse="")
    pattern <- paste(rep(c("a?", "a"), each=N), collapse="")
    linear_size_replacement <- paste(rep("REPLACEMENT", N), collapse="")
  },
  PCRE.match=regexpr(pattern, subject, perl=TRUE),
  TRE.match=regexpr(pattern, subject, perl=FALSE),
  constant.replacement=gsub("a","constant size replacement",subject),
  linear.replacement=gsub("a",linear_size_replacement,subject))
plot(atime_result_string)

}
