library(shiny)
library(shinyBS)
library(shinyjs)
library(leaflet)
library(RColorBrewer)
library(scales)
library(dplyr)
library(data.table)
library(shinydashboard)

fancyCheck <- function(id, txt, type="primary", checked="checked") {
  div(class="[ form-group ] shiny_input_container", 
      tags$input(id=id, type="checkbox", name=id, autocomplete="off", checked=checked),
      div(class="[ btn-group ]",
        tag("label",list(class=paste0("[ btn btn-",type," ]"), 
                          `for`=id, 
                          tags$span(class="[ glyphicon glyphicon-ok ]"),
                          tags$span())),
        tag("label",list(class=paste0("[ btn btn-default active ]"), 
                          `for`=id,
                          txt))))
}


myColorNumeric = function(palette, domain, na.color = "#808080", alpha = FALSE, zero.center=FALSE) {
  rng = NULL
  if (length(domain) > 0) {
    if(zero.center) {
      rng = abs(range(domain, na.rm=TRUE))
      rng=c(-max(rng),max(rng))
    } else {
      rng = range(domain, na.rm = TRUE)      
    }
    if (!all(is.finite(rng))) {
      stop("Wasn't able to determine range of domain")
    }
  }

  pf = safePaletteFunc(palette, na.color, alpha)

  withColorAttr('numeric', list(na.color = na.color), function(x) {
    if (length(x) == 0 || all(is.na(x))) {
      return(pf(x))
    }

    if (is.null(rng)) rng = range(x, na.rm = TRUE)

    # rescaled = scales::rescale(x, from = rng)
    # if (any(rescaled < 0 | rescaled > 1, na.rm = TRUE))
    #   warning("Some values were outside the color scale and will be treated as NA")
    pf(pnorm(scale(x)))
  })
}

tmpfun <- get("colorNumeric", envir = asNamespace("leaflet"))
environment(myColorNumeric) <- environment(tmpfun)
attributes(myColorNumeric) <- attributes(tmpfun)




shinyServer(function(input, output, session) {

  # path.data <- path.expand(file.path("~/git/BISD/data"))
  # path.maps <- path.expand(file.path("~/git/BISD/data/SchoolDistricts"))

  path.data <- path.expand(file.path("/srv/shiny-server/districts/data"))
  path.maps <- path.expand(file.path("/srv/shiny-server/districts/SchoolDistricts"))


  load(file.path(path.data,"districts.RData"))

  # districts <- districts[districts$fgsd==TRUE,]

  output$choose_community <- renderUI({
    selectizeInput("comm", "Community Type", choices=as.list(districts@data$`COMMUNITY TYPE`), multiple=TRUE, options=list(placeholder="ALL  (Click to select specific options)"))
  })

  output$choose_tax <- renderUI({
    selectizeInput("tax", "Tax Rate", choices=as.list(districts@data$`TAX RATE`), multiple=TRUE, options=list(placeholder="ALL  (Click to select specific options)"))
  })

  output$choose_set <- renderUI({
    selectInput("set", "Data Group", choices=as.list(groups), selected="TAX & REVENUE")
  })

  output$toggle_overlay <- renderUI({
    fancyCheck("showOverlay","Show Districts")
  })

  output$toggle_plot <- renderUI({
    fancyCheck("showPlot","Show Plot",checked=NULL)
  })

  output$toggle_fgsd <- renderUI({
    fancyCheck("fgsd","Fast Growth Districts",checked=NULL)
  })

  output$toggle_gsa <- renderUI({
    fancyCheck("gsa","Greater San Antonio",checked=NULL)
  })

  observe({
    if(length(input$set)==0) {
      return()
    }
    varset <- gsub(".*: ","",variables[[input$set]])
    updateSelectInput(session, "var", choices=varset)
  })

  observe({
    if(is.null(input$showOverlay)) {
      return()
    }
    proxy <- leafletProxy("map", data = dyn.sdf())
    if(input$showOverlay) {
      proxy %>% showGroup("overlay")
    } else {
      proxy %>% hideGroup("overlay")
    }
  })

  observe({
    if(is.null(input$showPlot)) {
      return()
    }
    proxy <- leafletProxy("map", data = dyn.sdf())
    if(input$showOverlay) {
      proxy %>% showGroup("overlay")
    } else {
      proxy %>% hideGroup("overlay")
    }
  })


  dyn.sdf <- reactive({
    if(is.null(input$fgsd)) {
      return(districts)
    }
    tmp <- districts
    if(length(input$comm)>0) {
      tmp <- tmp[tmp$`COMMUNITY TYPE` %in% input$comm,]
    }
    if(length(input$tax)>0) {
      tmp <- tmp[tmp$`TAX RATE` %in% input$tax,]
    }
    if(input$fgsd) {
      tmp <- tmp[tmp$fgsd==TRUE,]
    }
    if(input$gsa) {
      tmp <- tmp[tmp$gsa==TRUE,]
    }
    return(tmp)
  })

  plot.dt <- reactive({
    if(paste0(input$set,": ",input$var) %in% names(dyn.sdf()@data)) {
      tmp <- dyn.sdf()@data[,.SD,.SDcols=c("NAME",paste0(input$set,": ",input$var))]
      setnames(tmp, c("NAME","value"))
      return(tmp)
    }
    return(NA)

  })  


  output$map <- renderLeaflet({
    leaflet() %>% 
      # addProviderTiles("Stamen.TonerLite") %>% 
      addProviderTiles("Stamen.Toner") %>% 
      # addProviderTiles("CartoDB.Positron") %>% 
      setView(-98.5720038,29.5764091,
              zoom = 9)    
  })


  # output$map2 <- renderLeaflet({
  #   leaflet() %>% 
  #     # addProviderTiles("Stamen.TonerLite") %>% 
  #     addProviderTiles("Stamen.Toner") %>% 
  #     # addProviderTiles("CartoDB.Positron") %>% 
  #     setView(-98.5720038,29.5764091,
  #             zoom = 9) 

  # })


  colorpal <- function(dat){
    myColorNumeric(c("#008837","#f5f5f5","#7b3294"), dat)
  }


  polygon_popup <- function(mdat,nm) {
      paste0("<strong>",
      mdat$NAME,
      "</strong><br>",
      "<strong>",nm,": </strong>", 
       comma(mdat$value))      
  }


  observe({
    if(class(plot.dt())[1]!="logical") {

        mdat <- plot.dt()
        leafletProxy("map", data = dyn.sdf()) %>%
        clearShapes() %>%
        addPolygons(data = dyn.sdf(), 
                    fillColor= colorpal(mdat$value)(mdat$value),
                    fillOpacity = 0.4, 
                    weight = 2, 
                    color = "#86592d",
                    popup = polygon_popup(mdat,input$var),
                    layerId=mdat$NAME,
                    group = "overlay") %>%   
              addLegend(position = 'bottomleft',
                  pal = colorpal(mdat$value),
                  values = mdat$value,
                  title = paste0("<div style='width: 150px'>",input$var,"</div>"),
                  layerId = "legend"
                )
    }
  })


  output$hist <- renderPlot({
    event <- input$map_shape_mouseover
    mdat <- plot.dt()
    hist(mdat$value,
      breaks = 20,
      main = NULL,
      # xlab = input$var,
      xlab = NULL,
      ylab=NULL,
      col = '#00DD00',
      border = 'steelblue')
    if(!is.null(event$id)) {
        abline(v=mdat[NAME==event$id]$value, lwd=3)

    }


  })




  shinyjs::onclick("sub1",
    runjs('caretSwitch("caret1")')
  )
  shinyjs::onclick("sub2",
    runjs('caretSwitch("caret2")')
  )
  shinyjs::onclick("sub3",
    runjs('caretSwitch("caret3")')
  )


})
