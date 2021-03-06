
lm_curve = function(lr,Ms,p,ly,prod,rmin){
  r = 1/lr*(Ms/p - ly*prod)
  r[r < rmin] = rmin
  return(r)
}

RMPlot <- function(input,output,values){
    masse = seq(0,input$Mmax,length.out = 100)
    prod = seq(0,input$ymax,length.out = 100)
    to_plot = data.frame(money = masse, revenu = prod)
    fig = plot_ly(to_plot, x = ~money)
    
    fig = fig %>% add_segments(x = input$Ms, y = 0, xend = input$Ms, yend = 15, type = "scatter", mode = "lines", name = "$$M = M^s$$", color = I("blue"),
                                 hovertemplate = paste("Ms=%{x:.0f}","<extra></extra>"))
    fig = fig %>% add_trace(y = lm_curve(input$lr, masse,values$p,input$ly,values$eq$y, input$rmin), type = "scatter", mode = "lines", name = "$$M^d$$", color = I("red"),
                              hovertemplate = paste("Ms=%{x:.0f}","<br>r=%{y:.2f}","<extra></extra>"))
    fig = fig %>% add_segments(x = 0, y = values$eq$r, xend = input$Mmax, yend = values$eq$r, line = list(color = 'rgb(200, 0, 0)', width = 1, dash = 'dash'), showlegend = FALSE,
                                 hovertemplate = paste("Ms=%{x:.0f}","<br>r=%{y:.2f}","<extra></extra>"))
    
    if(values$shock & !is.na(input$new_value_LM)){
      if(input$shocked_var_LM == "Ms"){
        fig = fig %>% add_segments(x = values$shocked_params_LM["Ms"], y = 0, xend = values$shocked_params_LM["Ms"], yend = 15, type = "scatter", mode = "lines", name = "$$M = M^s$$", color = "rgb(0,20,200)",
                                     hovertemplate = paste("Ms=%{x:.0f}","<extra></extra>"))
        fig = fig %>% add_segments(x = 0, y = values$new_eq$r, xend = input$Mmax, yend = values$new_eq$r, line = list(color = 'rgb(200, 0, 0)', width = 1, dash = 'dash'), showlegend = FALSE,
                                     hovertemplate = paste("Ms=%{x:.0f}","<br>r=%{y:.2f}","<extra></extra>"))
      } else if(input$shocked_var_LM != "Ms"){
        fig = fig %>% add_trace(y = lm_curve(values$shocked_params_LM["lr"],masse,values$shocked_params_LM["p"]/100,values$shocked_params_LM["ly"],values$shocked_params_LM["ystar"],input$rmin), type = "scatter", mode = "lines", name = "$$M^d$$", color = "rgb(0,200,20)",
                                  hovertemplate = paste("Ms=%{x:.0f}","<br>r=%{y:.2f}","<extra></extra>"))
        fig = fig %>% add_segments(x = 0, y = values$new_eq$r, xend = input$Mmax, yend = values$new_eq$r, line = list(color = 'rgb(200, 0, 0)', width = 1, dash = 'dash'), showlegend = FALSE,
                                     hovertemplate = paste("Ms=%{x:.0f}","<br>r=%{y:.2f}","<extra></extra>"))
      }
      new_eq = list(
        x = unname(values$shocked_params_LM["Ms"]),
        y = values$new_eq$r,
        text = paste0("r*=",round(values$new_eq$r,1))
      )
      fig = fig %>% layout(annotations = new_eq)
    } else{
      eq = list(
        x = input$Ms,
        y = values$eq$r,
        text = paste0("r*=",round(values$eq$r,1))
      )
      fig = fig %>% layout(annotations = eq)
    }
    
    f <- list(
      family = "Courier New, monospace",
      size = 18,
      color = "#7f7f7f"
    )
    money <- list(
      title = "Masse monétaire réelle, M/p",
      titlefont = f
    )
    interest <- list(
      title = "Taux d'intérêt, r",
      titlefont = f
    )
    fig = fig %>% layout(xaxis = money, yaxis = interest)
}

LMPlot <- function(input,output,values){
  masse = seq(0,input$Mmax,length.out = 100)
  prod = seq(0,input$ymax,length.out = 100)
  to_plot = data.frame(money = masse, revenu = prod)
  
  fig = plot_ly(to_plot, x = ~revenu)
  fig = fig %>% add_trace(y = lm_curve(input$lr, input$Ms, values$p, input$ly, prod, input$rmin), type = "scatter", mode = "lines", name = "$$LM_1$$", color = I("red"),
                            hovertemplate = paste("y=%{x:.0f}","<br>r=%{y:.2f}","<extra></extra>"))
  fig = fig %>% add_segments(0,values$eq$r,values$eq$y,values$eq$r, line = list(color = 'rgb(200, 0, 0)', width = 1, dash = 'dash'), showlegend = FALSE,
                               hovertemplate = paste("y=%{x:.0f}","<br>r=%{y:.2f}","<extra></extra>"))
  fig = fig %>% add_segments(values$eq$y,0,values$eq$y,values$eq$r, line = list(color = 'rgb(200, 0, 0)', width = 1, dash = 'dash'), showlegend = FALSE,
                               hovertemplate = paste("y=%{x:.0f}","<br>r=%{y:.2f}","<extra></extra>"))
  
  if(values$shock & !is.na(input$new_value_LM)){      
    if(input$shocked_var_LM != "ystar"){
      fig = fig %>% add_trace(y = lm_curve(values$shocked_params_LM["lr"],values$shocked_params_LM["Ms"],values$shocked_params_LM["p"],values$shocked_params_LM["ly"],prod,input$rmin), type = "scatter", mode = "lines", name = "$$LM_2$$", color = "rgb(0,200,20)",
                                hovertemplate = paste("y=%{x:.0f}","<br>r=%{y:.2f}","<extra></extra>"))
    }
    fig = fig %>% add_segments(0,values$new_eq$r,values$shocked_params_LM["ystar"],values$new_eq$r, line = list(color = 'rgb(200, 0, 0)', width = 1, dash = 'dash'), showlegend = FALSE,
                                 hovertemplate = paste("y=%{x:.0f}","<br>r=%{y:.2f}","<extra></extra>"))
    fig = fig %>% add_segments(values$shocked_params_LM["ystar"],0,values$shocked_params_LM["ystar"],values$new_eq$r, line = list(color = 'rgb(200, 0, 0)', width = 1, dash = 'dash'), showlegend = FALSE,
                                 hovertemplate = paste("y=%{x:.0f}","<br>r=%{y:.2f}","<extra></extra>"))
    lm_eq = list(
      x = unname(values$shocked_params_LM["ystar"]),
      y = values$new_eq$r,
      text = paste0("r*=",round(values$new_eq$r,1))
    )
    fig = fig %>% layout(annotations = lm_eq)
  } else{
    is_eq = list(
      x = values$eq$y,
      y = values$eq$r,
      text = paste0("r*=",round(values$eq$r,1))
    )
    fig = fig %>% layout(annotations = is_eq)
  }
  
  f <- list(
    family = "Courier New, monospace",
    size = 18,
    color = "#7f7f7f"
  )
  revenu <- list(
    title = "Revenu, y",
    titlefont = f
  )
  interest <- list(
    title = "Taux d'intérêt, r",
    titlefont = f
  )
  fig = fig %>% layout(xaxis = revenu, yaxis = interest)
}