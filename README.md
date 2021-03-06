
# Canadian Covid-19 Cases

Comparison of caseloads between Canadian provinces.

Data sourced from: https://www.canada.ca/en/public-health/services/diseases/2019-novel-coronavirus-infection.html

## Launch Webapp via Binder

Launch App using Master branch: [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/TheZetner/cases/master?urlpath=shiny/inst/app/)

## Interface

### Select Provinces

![](./images/selprov.PNG)

* Type in search bar. Enter or clicking on province name adds to selection
* _Big Four_ refers to BC, ON, AB, and QC as the largest provinces by population 
* _All_ and _None_ are self-explanatory

### Select Dates

Click and drag on the plot, move the sliders, or click the buttons to choose what range to select from Jan 31st, 2020 to Today.

![](./images/seldate1.PNG)

Use the toggle switch to show aggregate cases or colour by province. 

![](./images/seldate2.PNG)

### Data Display

All are relative to the provinces selected and the date range chosen. To compare caseloads by province to all of Canada click _All_.

1. Caseloads
    * Table of cases and percent share of cases from the selected provinces. Click column headers to reorder.
    * Chart displays same information as table
  
    ![](./images/caseloads.PNG)
  
2. Deviation from Expected: Summary
    * Summary of daily deviations from expected caseload (see below) across date range specified

    ![](./images/summary.PNG)

3. Deviation from Expected: Rolling Average
    * 7-Day rolling average of deviation from expected caseload (see below) across date range specified

    ![](./images/rolling.PNG)

### Calculations

#### Percent Caseload by Province

<!-- $$PCTCases_{Province} = \left( \frac{Cases_{Province}}{Cases_{Canada}} \right) * 100$$ -->
![](./images/pctcases.gif)

#### Expected Caseload by Province

<!-- $$Cases_{Expected} = Cases_{Canada} * \frac{Population_{Province}}{Population_{Canada}}$$ -->
![](./images/expectedcases.gif)

#### Percent Deviation from Expected Caseload

<!-- $$\left( \frac{Cases_{Province}}{Cases_{Canada}} - \frac{Population_{Province}}{Population_{Canada}} \right) * 100$$ -->
![](./images/pctdev.gif)
