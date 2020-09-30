library(ggplot2)
library(Cairo)   # For nicer ggplot2 output when deployed on Linux

plot_click <- function(l, xpos){
  if(is.na(l$x1)){
    l$x1 <- xpos
  } else if(is.na(l$x2)) {
    l$x2 <- xpos
  } else{
    l$x1 <- NA
    l$x2 <- NA
  }
  l
}



ui <- fluidPage(
  # Some custom CSS for a smaller font for preformatted text
  tags$head(
    tags$style(HTML("
      pre, table.table {
        font-size: smaller;
      }
    "))
  ),

  fluidRow(
    column(width = 4, wellPanel(
      radioButtons("plot_type", "Plot type",
                   c("base", "ggplot2")
      )
    )),
    column(width = 4,
           # In a plotOutput, passing values for click, dblclick, hover, or brush
           # will enable those interactions.
           plotOutput("plot1", height = 350,
                      # Equivalent to: click = clickOpts(id = "plot_click")
                      click = "plot_click",
                      dblclick = dblclickOpts(
                        id = "plot_dblclick"
                      ),
                      hover = hoverOpts(
                        id = "plot_hover"
                      ),
                      brush = brushOpts(id = "plot_brush", fill = "#9cf", stroke = "#036",
                                opacity = 0.25, delay = 300, delayType = "debounce",
                                clip = TRUE, direction = "x", resetOnNew = FALSE)
           )
    )
  ),
  fluidRow(
    column(width = 3,
           verbatimTextOutput("click_info")
    ),
    column(width = 3,
           verbatimTextOutput("twoclick_info")
    ),
    column(width = 3,
           verbatimTextOutput("hover_info")
    ),
    column(width = 3,
           verbatimTextOutput("brush_info")
    )
  )
)


server <- function(input, output) {
  output$plot1 <- renderPlot({
    if (input$plot_type == "base") {
      plot(mtcars$wt, mtcars$mpg)
    } else if (input$plot_type == "ggplot2") {
      ggplot(mtcars, aes(wt, mpg)) + geom_point()
    }
  })


  output$click_info <- renderPrint({
    cat("input$plot_click:\n")
    str(input$plot_click)
  })
  output$hover_info <- renderPrint({
    cat("input$plot_hover:\n")
    str(input$plot_hover)
  })
  output$twoclick_info <- renderPrint({
    cat("input$plot_twoclick:\n")

  })
  output$brush_info <- renderPrint({
    cat("input$plot_brush:\n")
    str(input$plot_brush)
  })

}


shinyApp(ui, server)
