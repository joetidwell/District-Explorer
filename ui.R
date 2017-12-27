library(shiny)
library(leaflet)
library(shinyBS)
library(shinyjs)
library(shinydashboard)
# library(plotly)
# library(googleCharts)

# Help contents
txt1 <- "<ul><li>Use this menu to select what data you would like displayed on the map<li>Click any of the sub-menu names to collapse/expand the submenu</ul>"
txt2 <- '<ul style="color: black"><li>Select a category from <code>Data Group</code><li>Select the information you want to display on the map from <code>Variable</code><li>After you choose an option from <code>Variable</code>, the map will update with the new information<li>Click on <code>Select Data</code> to collapse/expand this section</ul>'
txt4 <- txt3 <- 'Some helpful text'

shinyUI(navbarPage("School District Information", id="nav",
  # tabPanel("Dash Map",
  #   div(class="outer",

  #     tags$head(useShinyjs(),
  #       # Include our custom CSS
  #       includeCSS("styles.css"),
  #       includeScript("funcs.js"),
  #       tags$link(rel="stylesheet", type="text/css", href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css")
  #     )
    #   div(class="dashmenu",
    #     bsCollapse(id = "data", 
    #                open =c("select_group"), 
    #                multiple=TRUE,
    #       bsCollapsePanel(
    #         div(style="float: left;", id="sub1", class="open", 
    #           div(style="float: left; width: 150px;", 
    #             h3(style="margin-top: 0px; margin-bottom: 0px;", "Select Data")),
    #           div(style="width:40px; text-align: center; float:left;",
    #             tags$i(class="fa fa-question-circle help")),
    #           div(style="width:20px; text-align: right; float:right;", class="",
    #             tags$i(id="caret1", class="fa fa-caret-square-o-down"))
    #         ),
    #         uiOutput("choose_set"),
    #         # selectInput("data_group", "Data", choices=NULL),
    #         value="select_group"
    #       )
    #     )
    #   )
  #    )
  # ),
  tabPanel("Interactive Map",
    div(class="outer",
        # googleChartsInit(),

      tags$head(
        # Include our custom CSS
        useShinyjs(),
        includeCSS("styles.css"),
        includeScript("funcs.js"),
        tags$link(rel="stylesheet", type="text/css", href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css")
      ),

      leafletOutput("map", width="100%", height="100%"),

      # Plot
      absolutePanel(id = "plots", fixed = TRUE,
        draggable = TRUE, top = 80, right = "auto", left = 30, bottom = "auto",
        width = 330, height = "auto",
        conditionalPanel(condition="input.showPlot==true", plotOutput("hist", height = 200))),

      # Menu
      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
        draggable = FALSE, top = 80, left = "auto", right = 30, bottom = "auto",
        width = 330, height = "auto",
        div(style="display: table-row",
          div(style="display:table-cell", h2("District Explorer")),
          tags$div(style="display:table-cell",
              popify(tags$i(class="fa fa-question-circle help"), 
                  "Help - District Explorer",
                  txt1))), 
        bsCollapse(id = "collapseExample", open=c("select","subset","mapopts"), multiple=TRUE,
          bsCollapsePanel(
            div(style="float: left;", id="sub1", 
              div(style="float: left; width: 200px;", 
                h3(style="margin-top: 0px; margin-bottom: 0px;", "Select Data")),
              div(style="width:50px; text-align: left; float:left;",
                popify(tags$i(class="fa fa-question-circle help"),
                       '<span style="color:black">Help - Select Data</span>',
                       txt2)),
              div(style="width:20px; text-align: right; float:right;",
                tags$i(id="caret1", class="fa fa-caret-square-o-down"))
            ),
            uiOutput("choose_set"),
            selectInput("var", "Variable", choices=NULL),
            value="select",
            style="primary"
          ),
          bsCollapsePanel(
            div(style="float: left;", id="sub2", 
              div(style="float: left; width: 200px;", 
                h3(style="margin-top: 0px; margin-bottom: 0px;", "Subset Data")),
              div(style="width:50px; text-align: left; float:left;",
                popify(tags$i(class="fa fa-question-circle help"), 
                  '<span style="color:black">Help - Subset Data</span>',
                  txt3)),
              div(style="width:20px; text-align: right; float:right;",
                tags$i(id="caret2", class="fa fa-caret-square-o-right"))
            ),
            # uiOutput("choose_community"),        
            # uiOutput("choose_tax"),  
            uiOutput("toggle_fgsd"),
            uiOutput("toggle_gsa"),      
            value="subset",
            style = "primary"
          ),
          bsCollapsePanel(
            div(style="float: left;", id="sub3", 
              div(style="float: left; width: 200px;", 
                h3(style="margin-top: 0px; margin-bottom: 0px;", "Map Options")),
              div(style="width:50px; text-align: left; float:left;",
                popify(tags$i(class="fa fa-question-circle help"), 
                  '<span style="color:black">Help - Subset Data</span>',
                  txt4)),
              div(style="width:20px; text-align: right; float:right;",
                tags$i(id="caret3", class="fa fa-caret-square-o-right"))
            ),
            uiOutput("toggle_overlay"),
            uiOutput("toggle_plot"),
            value="mapopts",
            style = "primary")       
          )

      )
      
      # tags$div(id="cite",
      #   'Data compiled for ', tags$em('Coming Apart: The State of White America, 1960–2010'), ' by Charles Murray (Crown Forum, 2012).'
      # )
    )
  )
  # tabPanel("Interactive Plots",
  #   div(class="outer",

  #     tags$head(
  #       # Include our custom CSS
  #       includeCSS("styles.css"),
  #       includeScript("gomap.js"),
  #       tags$link(rel="stylesheet", type="text/css", href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css")
  #     ),
  #     dashboardPage(
  #       dashboardHeader(title = "Basic dashboard"),
  #       dashboardSidebar(),
  #       dashboardBody(
  #         fluidRow(box(htmlOutput("plot2"),width=12,height=600))
  #       )
  #     )
  #   )
  # ),
  # tabPanel("Generate Report",
  #   div(class="outer",

  #     tags$head(
  #       # Include our custom CSS
  #       includeCSS("styles.css"),
  #       includeScript("gomap.js"),
  #       tags$link(rel="stylesheet", type="text/css", href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css")
  #     )))
))