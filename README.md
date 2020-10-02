
# Canadian Covid-19 Cases

Comparison of caseloads between Canadian provinces.

Data sourced from: https://www.canada.ca/en/public-health/services/diseases/2019-novel-coronavirus-infection.html

## Launch Webapp via Binder

Launch App using Master branch: [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/TheZetner/cases/master?urlpath=shiny/inst/app/)

## Interface

### Select Provinces

![selprov](/images/selprov.PNG)

* Type in search bar. Enter or clicking on province name adds to selection
* _Big Four_ refers to BC, ON, AB, and QC as the largest provinces by population 
* _All_ and _None_ are self-explanatory

### Select Dates

Click and drag on the plot, move the sliders, or click the buttons to choose what range to select from Jan 31st, 2020 to Today.

![seldate1](/images/seldate1.PNG)

Use the toggle switch to show aggregate cases or colour by province. 

![seldate2](/images/seldate2.PNG)

### Data Display

All are relative to the provinces selected and the date range chosen. To compare caseloads by province to all of Canada click _All_.

1. Caseloads
    * Table of cases and percent share of cases from the selected provinces. Click column headers to reorder.
    * Chart displays same information as table
  
    ![caseloads](/images/caseloads.PNG)
  
2. Deviation from Expected: Summary
    * Summary of daily deviations from expected caseload (see below) across date range specified

    ![summary](/images/summary.PNG)

3. Deviation from Expected: Rolling Average
    * 7-Day rolling average of deviation from expected caseload (see below) across date range specified

    ![rolling](/images/rolling.PNG)

### Calculations

#### Percent Caseload by Province

<!-- $$PCTCases_{Province} = \left( \frac{Cases_{Province}}{Cases_{Canada}} \right) * 100$$ -->
![PercentCaseload](https://latex.codecogs.com/gif.download?PCTCases_%7BProvince%7D%20%3D%20%5Cleft%28%20%5Cfrac%7BCases_%7BProvince%7D%7D%7BCases_%7BCanada%7D%7D%20%5Cright%29%20*%20100)

#### Expected Caseload by Province

<!-- $$Cases_{Expected} = Cases_{Canada} * \frac{Population_{Province}}{Population_{Canada}}$$ -->
![Expected Caseload](https://latex.codecogs.com/gif.download?Cases_%7BExpected%7D%20%3D%20Cases_%7BCanada%7D%20*%20%5Cfrac%7BPopulation_%7BProvince%7D%7D%7BPopulation_%7BCanada%7D%7D)

#### Percent Deviation from Expected Caseload

<!-- $$\left( \frac{Cases_{Province}}{Cases_{Canada}} - \frac{Population_{Province}}{Population_{Canada}} \right) * 100$$ -->
![Percent Deviation](https://latex.codecogs.com/gif.download?%5Cleft%28%20%5Cfrac%7BCases_%7BProvince%7D%7D%7BCases_%7BCanada%7D%7D%20-%20%5Cfrac%7BPopulation_%7BProvince%7D%7D%7BPopulation_%7BCanada%7D%7D%20%5Cright%29%20*%20100)
