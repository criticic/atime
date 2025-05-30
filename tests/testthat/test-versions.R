library(data.table)
library(testthat)
tdir <- tempfile()
dir.create(tdir)
git2r::clone("https://github.com/tdhock/binsegRcpp", tdir)
test_that("error if no versions specified", {
  expect_error({
    atime.list <- atime::atime_versions(
      pkg.path=tdir,
      N=2^seq(2, 20),
      setup={
        max.segs <- as.integer(N/2)
        data.vec <- 1:N
      },
      expr=binsegRcpp::binseg_normal(data.vec, max.segs))
  },
  "need to specify at least one git SHA, in either sha.vec, or ...",
  fixed=TRUE)
})

test_that("atime_versions_exprs error when expr does not contain pkg:", {
  expect_error({
    atime::atime_versions_exprs(
      pkg.path=tdir,
      expr=dt[, .(vs = (sum(val))), by = .(id)],
      "Before"="be2f72e6f5c90622fe72e1c315ca05769a9dc854",
      "Regression"="e793f53466d99f86e70fc2611b708ae8c601a451", 
      "Fixed"="58409197426ced4714af842650b0cc3b9e2cb842") 
  }, "expr should contain at least one instance of binsegRcpp:: to replace with binsegRcpp.be2f72e6f5c90622fe72e1c315ca05769a9dc854:", fixed=TRUE)
})

if(requireNamespace("ggplot2"))test_that("atime_pkg produces tests_all_facet.png and tests_preview_facet.png on atime-test-funs", {
  repo <- git2r::repository(tdir)
  ## https://github.com/tdhock/binsegRcpp/tree/atime-test-funs
  atime.dir <- file.path(tdir, ".ci", "atime")
  unlink(file.path(atime.dir, "*"))
  git2r::checkout(repo, branch="atime-test-funs", force=TRUE)
  options(repos="http://cloud.r-project.org")#required to check CRAN version.
  result.list <- atime::atime_pkg(tdir, ".ci")
  tests.RData <- file.path(atime.dir, "tests.RData")
  (objs <- load(tests.RData))
  expected.names <- c(
    "binseg(1:N,maxSegs=N/2) DIST=l1",
    "binseg(1:N,maxSegs=N/2) DIST=meanvar_norm", 
    "binseg(1:N,maxSegs=N/2) DIST=poisson",
    "binseg_normal(1:N,maxSegs=N/2)"
  )
  expect_identical(sort(unique(bench.dt$Test)), sort(expected.names))
  expect_identical(sort(limit.dt$Test), sort(expected.names))
  expect_is(limit.dt$P.value, "factor")
  expect_is(limit.dt$N.factor, "factor")
  expect_identical(names(pkg.results), expected.names)
  expect_is(bench.dt[["Test"]], "character")
  install.seconds <- sapply(result.list, "[[", "install.seconds")
  expect_is(install.seconds, "numeric")
  expect_identical(names(install.seconds), expected.names)
  bench.seconds <- sapply(result.list, "[[", "bench.seconds")
  expect_is(bench.seconds, "numeric")
  expect_identical(names(bench.seconds), expected.names)
  ## also test global PNG.
  tests_all_facet.png <- file.path(atime.dir, "tests_all_facet.png")
  expect_true(file.exists(tests_all_facet.png))
  tests_preview_facet.png <- file.path(atime.dir, "tests_preview_facet.png")
  expect_true(file.exists(tests_preview_facet.png))
  HEAD_issues.md <- file.path(atime.dir, "HEAD_issues.md")
  expect_true(file.exists(HEAD_issues.md))
})

if(requireNamespace("ggplot2"))test_that("atime_pkg produces tests_all_facet.png and tests_preview_facet.png on another-branch", {
  repo <- git2r::repository(tdir)
  ## https://github.com/tdhock/binsegRcpp/tree/another-branch
  inst.atime <- file.path(tdir, "inst", "atime")
  unlink(file.path(inst.atime, "*"))
  git2r::checkout(repo, branch="another-branch", force=TRUE)
  options(repos="http://cloud.r-project.org")#required to check CRAN version.
  result.list <- atime::atime_pkg(tdir)
  tests_all_facet.png <- file.path(inst.atime, "tests_all_facet.png")
  expect_true(file.exists(tests_all_facet.png))
  ##N.tests.preview=2 < N.tests=4 so should make one more PNG with those two.
  tests_preview_facet.png <- file.path(inst.atime, "tests_preview_facet.png")
  expect_true(file.exists(tests_preview_facet.png))
  install_seconds.txt <- file.path(inst.atime, "install_seconds.txt")
  install.seconds <- scan(install_seconds.txt, n=1, quiet=TRUE)
  expect_is(install.seconds, "numeric")
})

if(requireNamespace("ggplot2"))test_that("atime_pkg produces tests_all_facet.png and tests_preview_facet.png on master", {
  repo <- git2r::repository(tdir)
  inst.atime <- file.path(tdir, ".ci", "atime")
  unlink(file.path(inst.atime, "*"))
  git2r::checkout(repo, branch="master", force=TRUE)
  options(repos="http://cloud.r-project.org")#required to check CRAN version.
  result.list <- atime::atime_pkg(tdir)
  tests_all_facet.png <- file.path(inst.atime, "tests_all_facet.png")
  expect_true(file.exists(tests_all_facet.png))
  tests_preview_facet.png <- file.path(inst.atime, "tests_preview_facet.png")
  expect_true(file.exists(tests_preview_facet.png))
  install_seconds.txt <- file.path(inst.atime, "install_seconds.txt")
  install.seconds <- scan(install_seconds.txt, n=1, quiet=TRUE)
  expect_is(install.seconds, "numeric")
})

if(requireNamespace("ggplot2"))test_that("atime_pkg produces tests_all_facet.png and tests_preview_facet.png on priority_queue", {
  repo <- git2r::repository(tdir)
  ## https://github.com/tdhock/binsegRcpp/pull/23
  inst.atime <- file.path(tdir, ".ci", "atime")
  unlink(file.path(inst.atime, "*"))
  git2r::checkout(repo, branch="priority_queue", force=TRUE)
  options(repos="http://cloud.r-project.org")#required to check CRAN version.
  result.list <- atime::atime_pkg(tdir)
  tests_all_facet.png <- file.path(inst.atime, "tests_all_facet.png")
  expect_true(file.exists(tests_all_facet.png))
  tests_preview_facet.png <- file.path(inst.atime, "tests_preview_facet.png")
  expect_true(file.exists(tests_preview_facet.png))
  install_seconds.txt <- file.path(inst.atime, "install_seconds.txt")
  install.seconds <- scan(install_seconds.txt, n=1, quiet=TRUE)
  expect_is(install.seconds, "numeric")
})

test_that("pkg.edit.fun is a function", {
  example_tests.R <- system.file("example_tests.R", package="atime")
  tests.dir <- file.path(tempfile(), ".ci", "atime")
  dir.create(tests.dir, showWarnings = FALSE, recursive = TRUE)
  tests.R <- file.path(tests.dir, "tests.R")
  file.copy(example_tests.R, tests.R)
  ci.dir <- dirname(tests.dir)
  pkg.dir <- dirname(ci.dir)
  DESCRIPTION <- file.path(pkg.dir, "DESCRIPTION")
  cat("Package: atime\nVersion: 1.0\n", file=DESCRIPTION)
  git2r::init(pkg.dir)
  repo <- git2r::repository(pkg.dir)
  git2r::add(repo, DESCRIPTION)
  git2r::commit(repo, "test commit")
  options(repos="http://cloud.r-project.org")#required to check CRAN version.
  test.env <- atime::atime_pkg_test_info(pkg.dir)
  test_N_expr <- test.env$test.list$test_N_expr
  expect_identical(test_N_expr$pkg.edit.fun, test.env$edit.data.table)
  expect_identical(test_N_expr$N, c(2,20))
  expect_identical(test_N_expr$expr, quote(rnorm(N)))
  test_expr <- test.env$test.list$test_expr
  expect_identical(test_expr$pkg.edit.fun, test.env$edit.data.table)
  expect_identical(test_expr$N, c(9,90))
  expect_identical(test_expr$expr, quote(rnorm(N)))
  e.res <- eval(test.env$test.call[["global_var_in_setup"]])
  expect_is(e.res, "atime")
})

gdir <- tempfile()
dir.create(gdir)
git2r::clone("https://github.com/tdhock/grates", gdir)

test_that("informative error when pkg.path is not a package", {
  expect_error({
    atime::atime_versions(
      gdir,
      current = "1aae646888dcedb128c9076d9bd53fcb4075dcda",
      old     = "51056b9c4363797023da4572bde07e345ce57d9c",
      setup   = date_vec <- rep(Sys.Date(), N),
      expr    = grates::as_yearmonth(date_vec))
  }, sprintf("pkg.path=%s should be path to an R package, but %s/DESCRIPTION does not exist", gdir, gdir), fixed=TRUE)
})

test_that("atime_versions works with grates pkg in sub-dir of git repo", {
  if(!requireNamespace("fastymd"))install.packages("fastymd")
  glist <- atime::atime_versions(
    file.path(gdir,"pkg"),
    current = "1aae646888dcedb128c9076d9bd53fcb4075dcda",
    old     = "51056b9c4363797023da4572bde07e345ce57d9c",
    setup   = date_vec <- rep(Sys.Date(), N),
    expr    = grates::as_yearmonth(date_vec))
  expect_is(glist, "atime")
})

test_that("atime_pkg_test_info() works for data.table, run one test case", {
  dt_dir <- tempfile()
  dir.create(dt_dir)
  git2r::clone("https://github.com/Rdatatable/data.table", dt_dir)
  dt_info <- atime::atime_pkg_test_info(dt_dir)
  dt_result <- eval(dt_info$test.call[[1]])
  expect_is(dt_result, "atime")
})
