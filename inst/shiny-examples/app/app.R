library(shiny)
library(cases)
library(shinyWidgets)
library(shinydashboardPlus)
library(shinydashboard)
library(lubridate)
library(dplyr)
library(DT)
library(ggplot2)


# Get data
dl <- grabDat()

# Wrap shinymaterial apps in material_page
ui <- dashboardPagePlus(
      dashboardHeaderPlus(disable = TRUE),
      dashboardSidebar(disable = TRUE, collapsed = TRUE),
      dashboardBody(
        fluidRow(
          boxPlus(
            width = 12,
            column(
              width = 12,
              align = "center",
              h1("Canadian Covid Cases"))),
          boxPlus(
            width = 12,
            title = "Select Provinces",
            closable = FALSE,
            status = "info",
            solidHeader = TRUE,
            collapsible = TRUE,
            "Data sourced from:",
            br(),
            "https://www.canada.ca/en/public-health/services/diseases/2019-novel-coronavirus-infection.html",
            br(),
            selectInput("provs",
                        label = h3("Select Provinces"),
                        choices = unique(dl$calc$geo),
                        selected = c("Alberta", "British Columbia", "Ontario", "Quebec"),
                        selectize = TRUE,
                        multiple = TRUE,
                        width = "100%"),
            fluidRow(
              column(
                width = 12,
                align = "center",
                actionButton("all", label = "All"),
                actionButton("bigfour", label = "Big Four"),
                actionButton("none", label = "None")
              )
            )
          ),
          boxPlus(
            width = 12,
            title = "Date Range",
            closable = FALSE,
            status = "info",
            solidHeader = TRUE,
            collapsible = TRUE,
            shinyWidgets::sliderTextInput(
              inputId    = "daterange",
              label      = h3("Date Range"),
              choices    = c(ymd(unique(dl$dat$date)), Sys.Date()),
              selected   = c(ymd(min(dl$dat$date)), ymd(max(dl$dat$date))),
              grid       = TRUE,
              width      = "100%"),
            fluidRow(
              column(
                width = 12,
                align = "center",
                actionButton("pastweek", label = "Past Week"),
                actionButton("pastmonth", label = "Past Month"),
                actionButton("fullpandemic", label = "All")))
          ),
          boxPlus(
            id = "caseloads",
            width = 12,
            title = "Caseloads",
            closable = FALSE,
            status = "warning",
            solidHeader = TRUE,
            collapsible = TRUE,
            column(
              width = 6,
              DTOutput("table")
              ),
            column(
              width = 6,
              plotOutput("clcol")
            )
          ),
          boxPlus(
            id = "deviation",
            width = 12,
            title = "Deviation from Expected",
            closable = FALSE,
            status = "warning",
            solidHeader = TRUE,
            collapsible = TRUE,
            plotOutput(outputId = "box")
          ),
          boxPlus(
            id = "daily",
            width = 12,
            title = "Daily Cases for All Selected Provinces",
            closable = FALSE,
            status = "warning",
            solidHeader = TRUE,
            collapsible = TRUE,
            plotOutput(outputId = "numtoday",
                       brush = brushOpts(id = "plot_brush", fill = "#FFF", stroke = "#000",
                                         opacity = 0.2, delay = 300, delayType = "debounce",
                                         clip = TRUE, direction = "x", resetOnNew = FALSE)),
            br(),
            fluidRow(
              column(
                width = 12,
                align = "center",
                switchInput("sumtoday", size = "mini", value = FALSE, onLabel = "Colour by province", offLabel = "Summarise All")
              ))
          ),
          boxPlus(
            id = "roll",
            width = 12,
            title = "7-Day Rolling Average: Deviation from Expected",
            closable = FALSE,
            status = "warning",
            solidHeader = TRUE,
            collapsible = TRUE,
            collapsed = TRUE,
            plotOutput(outputId = "line")
          ),


  )
)
)

server <- function(input, output, session) {


  calc <-  reactive({
    dl$calc %>%
      filter(geo %in% input$provs) %>%
      filter(between(date, as.Date(input$daterange[1]),as.Date(input$daterange[2])))
  })
  dat <-  reactive({
    dl$dat %>%
      filter(geo %in% input$provs)
  })

  # Province Buttons
  # All
  observeEvent(input$all, {
    updateSelectInput(session, "provs",
                      selected = unique(dl$calc$geo)
    )
  })
  # Big 4
  observeEvent(input$bigfour, {
    updateSelectInput(session, "provs",
                      selected = c("Alberta", "British Columbia", "Ontario", "Quebec")
    )
  })
  # None
  observeEvent(input$none, {
    updateSelectInput(session, "provs",
                      selected = ""
    )
  })

  # Date Buttons
  # Week
  observeEvent(input$pastweek, {
    updateSliderTextInput(session, "daterange",
                      selected = c(Sys.Date() - weeks(1), Sys.Date())
    )
  })
  # Week
  observeEvent(input$pastmonth, {
    updateSliderTextInput(session, "daterange",
                          selected = c(Sys.Date() - weeks(4), Sys.Date())
    )
  })
  # Full Pandemic
  observeEvent(input$fullpandemic, {
    updateSliderTextInput(session, "daterange",
                          selected = c(ymd("2020-01-31"), Sys.Date())
    )
  })

  observeEvent(input$plot_brush, {
    bp <- brushedPoints(dat(), input$plot_brush)
    if(is.null(input$plot_brush)){
      updateSliderTextInput(session,
                            "daterange",
                            selected = c(ymd("2020-01-31"),
                                         Sys.Date()))
    } else {
      updateSliderTextInput(session,
                            "daterange",
                            selected = c(min(bp$date),
                                         max(bp$date)))
    }

  }, ignoreNULL = FALSE) # Must monitor for change to NULL in plot_brush

  # Caseload Table
  output$table <- renderDT(options = list(
    searching = FALSE,
    lengthChange = FALSE,
    info = FALSE,
    paging = FALSE
  ), {
    req(input$provs, cancelOutput = F)
    caseloads(dat(), input$daterange[1], input$daterange[2])
    })

  # Caseload Plot
  output$clcol <- renderPlot({
    req(input$provs, cancelOutput = F)
    caseloads(dat(), input$daterange[1], input$daterange[2]) %>%
     makebarplot()
  })

  # Box Plot
  output$box <- renderPlot({
    req(input$provs, cancelOutput = F)
    makeboxplot(calc())
  })

  # Cases Plot
  output$numtoday <- renderPlot({
    req(input$provs, cancelOutput = F)
      p <- ggplot(dat(), aes(x = date, y = numtoday))

    if(input$sumtoday){
      p <- p + geom_col(aes(fill = geo))
    } else {
      p <- p + geom_col()
    }

    p +
      annotate("rect",
               xmin = as.Date("2020-01-31"),
               xmax = as.Date(input$daterange[1]),
               ymin = -Inf,
               ymax = Inf,
               alpha = .2) +
      annotate("rect",
               xmin = as.Date(input$daterange[2]),
               xmax = Sys.Date(),
               ymin = -Inf,
               ymax = Inf,
               alpha = .2) +
      theme(legend.title = element_blank(),
            legend.position='bottom') +
      guides(fill=guide_legend(ncol=2)) +
      labs(x = "Date",
           y = "Number of Cases") +
      scale_x_date(date_breaks = "1 week",
                   date_minor_breaks = "3 days",
                   date_labels = "%b-%d") +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, size = 10))
  })

  # Rolling Average Plot
  output$line <- renderPlot({
    req(input$provs, cancelOutput = F)
    makelineplot(calc())
  })

  output$brush_info <- renderPrint({
    cat("input$plot_brush:\n")
    str(input$plot_brush)
  })

}


shinyApp(ui = ui, server = server)
