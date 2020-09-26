#' Get Population and Cases Data
#'
#' Returns a list of tibbles
#'
#'
#' @return List of three tibbles: pop (population data from statscan), dat (covid cases from canada.ca), calc (combined dat and pop along with relative caseload: calculation of pct cases and diff from expected based on population)
#'
#' @import readr dplyr tibble tidyr lubridate forcats
#'
#' @export
grabDat <- function(){

  # Get population data
  pop <- read_csv("https://www150.statcan.gc.ca/t1/tbl1/en/dtl!downloadDbLoadingData-nonTraduit.action?pid=1710000901&latestN=5&startDate=&endDate=&csvLocale=en&selectedMembers=%5B%5B4%2C12%2C8%2C9%2C5%2C7%2C10%2C3%2C14%2C15%2C6%2C11%2C2%2C1%5D%5D") %>%
    mutate(DATE = parse_date(REF_DATE, format = "%Y-%m")) %>%
    select(date = DATE, geo = GEO, pop = VALUE) %>%
    group_by(geo) %>%
    slice_max(date)

  # Pull case data
  dat <- read_csv("https://health-infobase.canada.ca/src/data/covidLive/covid19.csv") %>%
    select(geo = prname, date, numtoday, numtotal, numactive) %>%
    mutate(date = parse_date(date, format = "%d-%m-%Y"),
           geo = factor(x = geo, levels = pr)) %>%
    filter(geo != "Repatriated travellers",
           numtoday >=0) %>%
    arrange(date)

  # Combine case and population data, calculate relative caseload

  calc <-
    dat %>%
    left_join(pop, by = c("geo", "date")) %>% # Add populations
    mutate(geo = factor(x = geo, levels = pr)) %>%  # Recreate factor
    group_by(geo) %>%
    arrange(pop) %>%
    mutate(pop = first(pop)) %>% # Ensure all dates have a population appropriate for their prov
    arrange(geo) %>%
    ungroup() %>%
    filter(geo != "Canada") %>%
    mutate(geo = forcats::fct_drop(geo)) %>%
    group_by(date) %>%
    mutate(pctcases = numtoday/sum(numtoday),
           totpop = sum(pop),
           pctcases = if_else(is.nan(pctcases), 0, pctcases)) %>%  # if no cases at all on that day replace with 0
    ungroup() %>%
    mutate(diff = (pctcases - pop/totpop) * 100)

  list(pop = pop, dat = dat, calc = calc)
}


#' Relative Caseloads by Date
#'
#'
#'
#' @param x dat from grabDat
#' @param start first day - defaults to March 1st, 2020
#' @param end last day - defaults to today
#'
#' @return List of two tibbles: References (RNAME/LENGTH) and Mapping (ID/PN/VN/CL)
#'
#' @import dplyr tibble tidyr
#'
#' @export

caseloads <- function(x, start = "2020-03-01", end = Sys.Date()){
  x %>%
    filter(between(date, as.Date(ymd(start)),
                   as.Date(ymd(end)))) %>% # Select period
    mutate(Tot = sum(numtoday)) %>% # total cases for all
    group_by(geo) %>%
    mutate(PctTotal = sum(numtoday)/Tot * 100,
           Cases = sum(numtoday)) %>% # Percent of cases in that period (sums to 1)
    slice_head(n = 1) %>%
    select(Province = geo, Cases, PctTotal)
}

# Plotting ####

#' Stepped Breaks
#'
#' Create breaks with steps k with bounds being 1k and n+1*k
#'
#' @param k step size
#' @return numeric vector of steps
#'
#' @export
brks <- function(k) {
  step <- k
  function(y) seq((floor(min(y)) %/% step) * step, (ceiling(max(y)) %/% step) * step, by = step)
}


#' Line Plots
#'
#' Create lineplots
#'
#' @param x dl$calc
#' @param k rolling average in days
#' @return dope plot
#'
#' @import dplyr tibble tidyr zoo ggplot2 lubridate
#'
#' @export
makelineplot <- function(x, k = 7){
  x %>%
    group_by(geo) %>%
    mutate(roll = zoo::rollmean(diff, k, fill = NA)) %>%
    ggplot(aes(x = date)) +
    geom_line(aes(y = 0), colour = "black") +
    geom_line(aes(y = roll, colour = geo), size = 1) +
    scale_x_date(breaks = "2 weeks") +
    scale_y_continuous(breaks = brks(10)) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, size = 8)) +
    labs(x = "Date",
         y = "Percent Deviation from Expected New Cases",
         colour = "Province",
         title = "Daily Deviation from Expected New Covid-19 Cases in Canadian Provinces")
         #subtitle = paste("Rolling ", k, "-Day Average from ", start, " to ", end, sep = ""))
}

#' Bar Plots
#'
#' Create barplots
#'
#' @param x dl$dat
#' @return dope plot
#'
#' @import dplyr ggplot2
#'
#' @export

makebarplot <- function(x){
  ggplot2::ggplot(x, aes(x = reorder(Province, - Cases), fill = Province)) +
  geom_col(aes(y=Cases), show.legend = FALSE) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, size = 8)) +
  labs(x = "Province",
       y = "Cases")
}

#' Box Plots
#'
#' Create barplots
#'
#' @param x dl$calc
#' @return dope plot
#'
#' @import dplyr tibble tidyr zoo ggplot2 lubridate
#'
#' @export
makeboxplot <- function(x){
  x %>%
    ggplot(aes(x = geo)) +
    geom_boxplot(aes(y = diff, fill = geo), show.legend = FALSE) +
    scale_y_continuous(breaks = brks(10)) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, size = 10)) +
    labs(x = "Province",
         y = "Percent Deviation from Expected New Cases",
         colour = "Province",
         title = "Summary of Deviation from Expected Covid-19 Cases in Canadian Provinces")
}
