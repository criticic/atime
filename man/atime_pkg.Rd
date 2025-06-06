\name{atime_pkg}
\alias{atime_pkg}
\alias{atime_pkg_test_info}
\title{Asymptotic timing package tests}
\description{R package performance testing, by computing time/memory
  usage of several R expressions of
  several different data sizes, for several package
  versions (base, HEAD, CRAN, merge-base, other historical references
  specified by user).
  \code{atime_pkg_test_info} returns an environment containing test
  code/calls (useful for running a single test), whereas
  \code{atime_pkg} runs all tests and saves results/plots to disk.
}
\usage{
atime_pkg(pkg.path=".", tests.dir=NULL)
atime_pkg_test_info(pkg.path=".", tests.dir=NULL)
}
\arguments{
  \item{pkg.path}{path to git repository containing R package.}
  \item{tests.dir}{path to directory which contains \code{atime/tests.R},
    relative to \code{pkg.path} (default \code{NULL} means first
    existing directory of \code{"inst"} or \code{".ci"}).}
}
\details{
  There should be a \code{tests.R} code file which
  defines \code{test.list}, a list with names corresponding to different
  tests.
  Each element should be a list with at least three named elements: \code{N},
  \code{setup}, \code{expr}, (possibly others such as
  \code{pkg.edit.fun} and \code{version_name="1234567890abcdef"})
  to be passed as named arguments to \code{atime_versions}, along with
  the following versions which are passed using the \code{sha.vec} argument:
  \code{base} ref comes from \code{GITHUB_BASE_REF} environment variable (default \code{master}),
  \code{HEAD} ref is the branch that you want to merge into base,
  \code{CRAN} is current published version (sha value \code{""}),
  \code{merge-base} is most recent common ancestor commit between \code{base} and
  \code{HEAD}.
  For visualization, default colors are provided for versions with names:
  \code{HEAD}, \code{base}, \code{CRAN}, \code{merge-base},
  \code{Before}, \code{Regression}, \code{Slow}, \code{Fixed},
  \code{Fast}; other version names will be gray using
  the default colors.
  If \code{tests.R} defines a variable named \code{version.colors}, then
  it should be a character vector of colors to be used instead of the
  default (names for versions, values for colors).
  If \code{tests.R} defines a variable named \code{pval.thresh}, then
  it should be a positive numeric value between 0 and 1 (any smaller p-values
  will generate messages about slowdowns in HEAD_issues.md).
}
\value{
  \code{atime_pkg_test_info} returns an environment in which the code of
  \code{tests.R} was evaluated, including a variable \code{test.call}
  which is a list of un-evaluated \code{atime_versions} calls,
  one for each test
  (use with \code{eval} to run a single test).
  \code{atime_pkg} returns a named list of test results,
  names come from names of \code{test.list}, and values
  come from results of \code{atime_versions}. Side effect is that
  data/plot files are saved in \code{atime} directory, including
  tests.RData (test results which can be read into R if you want to make
  your own alternative plots/analyses), tests_all_facet.png (plot
  summarizing all test results), tests_preview_facet.png (plot
  summarizing only most significant results), and install_seconds.txt
  (total number of seconds used to install different package versions).
  Plots emphasize differences between \code{HEAD} and a comparison
  version, which is defined as the first of
  these versions which is available: \code{merge-base}, \code{base}, \code{CRAN}.
  Plots show test cases, first sorted by \code{N.factor}, which is the
  ratio of N values at the time limit, \code{HEAD} versus comparison
  version. If \code{N.factor<1} then \code{HEAD} is much slower than
  comparison version (the smaller N value for \code{HEAD} went over the
  time limit). \code{N.factor=1} means \code{HEAD} and comparison version
  had same value for largest N (so have nearly the same speed); ties
  are broken using \code{P.value}, un-paired two-sample T-test for
  \code{HEAD} time greater than comparison time at largest N.
}

\author{Toby Dylan Hocking}

\seealso{
  \code{\link{atime_test}} for defining each test,
  \code{\link{atime_test_list}} for defining common arguments in each
  element of the test list.
}

\examples{

if(FALSE){

  ## Clone binsegRcpp, and checkout a branch which has performance tests.
  tdir <- tempfile()
  dir.create(tdir)
  git2r::clone("https://github.com/tdhock/binsegRcpp", tdir)
  repo <- git2r::repository(tdir)
  git2r::checkout(repo, "another-branch")

  ## Run one test.
  info.env <- atime::atime_pkg_test_info(tdir)
  test_name <- "binseg(1:N,maxSegs=N/2) DIST=l1"
  (one.call <- info.env$test.call[[test_name]])
  one.result <- eval(one.call)
  plot(one.result) # constant difference for small N should be visible.

  ## Run all tests.
  result.list <- atime::atime_pkg(tdir)
  inst.atime <- file.path(tdir, "inst", "atime")
  dir(inst.atime)
  tests.RData <- file.path(inst.atime, "tests.RData")
  (objs <- load(tests.RData))
  plot(pkg.results[[test_name]]) # should look similar.

  atime::atime_versions_remove("binsegRcpp")

}

## https://github.com/tdhock/binsegRcpp/blob/atime-test-funs/.ci/atime/tests.R
## has another real example, see how to run it in tests/testthat/test-versions.R

}
