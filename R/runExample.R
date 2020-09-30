#' Run Cases Shiny App
#'
#' @import shiny
#'
#' @export
runExample <- function() {
  appDir <- system.file("app", package = "cases")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `cases`.", call. = FALSE)
  }

  shiny::runApp(appDir, display.mode = "normal")
}
