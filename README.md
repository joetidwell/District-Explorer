District Explorer
=====

This `R` `Shiny` application provides an interactive map of all public school districts in Texas. Users can select from a list of variables, for example `Total Actual Revenue` or `Locally Adopted Tax Rate` and visualize this information in several ways. 


Functionality
------
* Values for the selected variable will be displayed as a chloropleth overlay on the map
* Clicking within the boundaries of a district will display the numeric value of the selected variable for that district
* Enabling `plots` under `Map Options` in the GUI will display a histogram of the selected variable. Hovering the mouse over a district will display a vertical line in the histogram corresponding to the variable value for that district
* The data, and consequently which districts will be visualized, can be subset in several ways under the `Subset Data` tab in the GUI.

Data Sources
------

* [TEA Datasets](http://tea.texas.gov/Reports_and_Data/School_District_Data/)


Demo
-----
* [Live Code](http://joetidwell.org:3838/districts/)

