# Copy this file to /srv/shiny-server/myapp/app.R
dir <- system.file("shiny-examples", "app", package = "cases")
setwd(dir)
shiny::shinyAppDir(".")
