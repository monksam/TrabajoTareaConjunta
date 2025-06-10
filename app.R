# Cargar librerías necesarias
library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(plotly)
library(dplyr)
library(lme4)

# Definir UI
ui <- dashboardPage(
  dashboardHeader(title = "Análisis de Procedimientos Hospitalarios"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Explicación del Estudio", tabName = "explicacion", icon = icon("info-circle")),
      menuItem("Análisis Gráfico", tabName = "graficos", icon = icon("chart-bar")),
      menuItem("Predicción", tabName = "prediccion", icon = icon("calculator"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Pestaña de Explicación
      tabItem(tabName = "explicacion",
              fluidRow(
                box(
                  title = "Análisis Integral de Procedimientos Hospitalarios", 
                  status = "primary", 
                  solidHeader = TRUE,
                  width = 12,
                  h3("Objetivo del Estudio"),
                  p("Identificar y cuantificar los factores que influyen en el número de procedimientos 
              realizados, considerando tanto efectos fijos como la estructura jerárquica inherente 
              a los datos hospitalarios."),
                  
                  h3("Metodología"),
                  p("Se implementó una estrategia de modelización progresiva en tres fases:"),
                  tags$ul(
                    tags$li(strong("Fase I:"), " Modelos Lineales Generalizados (GLM)"),
                    tags$li(strong("Fase II:"), " Modelos de Suavizado, Aditivos y Mixtos (GAM)"),
                    tags$li(strong("Fase III:"), " Validación Bayesiana")
                  ),
                  
                  h3("Características de los Datos"),
                  p("Variable respuesta: Número de procedimientos (1-64)"),
                  p("Media: 15.14 | Mediana: 14 | Ratio varianza/media: 4.0 (sobredispersión)"),
                  
                  h3("Hallazgos Principales"),
                  tags$ul(
                    tags$li("La experiencia profesional aumenta la productividad en +5.3% por año"),
                    tags$li("Cada hora adicional trabajada incrementa los procedimientos en +2.9%"),
                    tags$li("El estrés laboral reduce la productividad en -6.5% por punto"),
                    tags$li("Los residentes tienen -39.3% menos productividad que el personal fijo"),
                    tags$li("Los temporales tienen -16.3% menos productividad que el personal fijo"),
                    tags$li("La formación adicional aporta +8.8% por año de especialización")
                  ),
                  
                  h3("Modelo Final"),
                  p("GLM jerárquico Poisson con efectos aleatorios departamentales"),
                  p(strong("R² = 0.76"), " - Excelente capacidad predictiva"),
                  p("RMSE = 3.6 procedimientos (~24% de la media)")
                )
              )
      ),
      
      # Pestaña de Gráficos
      tabItem(tabName = "graficos",
              fluidRow(
                box(
                  title = "Distribución de la Variable Respuesta", 
                  status = "info", 
                  solidHeader = TRUE,
                  width = 6,
                  plotlyOutput("hist_procedimientos")
                ),
                
                box(
                  title = "Estadísticas Descriptivas", 
                  status = "info", 
                  solidHeader = TRUE,
                  width = 6,
                  tableOutput("estadisticas_desc")
                )
              ),
              
              fluidRow(
                box(
                  title = "Relación entre Variables Continuas", 
                  status = "info", 
                  solidHeader = TRUE,
                  width = 6,
                  selectInput("variable_x", "Variable X:",
                              choices = c("experiencia_anios", "horas_trabajadas", 
                                          "nivel_estres", "formacion_adicional")),
                  plotlyOutput("scatter_plot")
                ),
                
                box(
                  title = "Procedimientos por Tipo de Contrato", 
                  status = "info", 
                  solidHeader = TRUE,
                  width = 6,
                  plotlyOutput("boxplot_contrato")
                )
              ),
              
              fluidRow(
                box(
                  title = "Procedimientos por Departamento", 
                  status = "info", 
                  solidHeader = TRUE,
                  width = 12,
                  plotlyOutput("boxplot_departamento")
                )
              )
      ),
      
      # Pestaña de Predicción
      tabItem(tabName = "prediccion",
              fluidRow(
                box(
                  title = "Predictor de Procedimientos", 
                  status = "success", 
                  solidHeader = TRUE,
                  width = 6,
                  h4("Ingrese los valores para la predicción:"),
                  
                  numericInput("pred_experiencia", "Años de experiencia:", 
                               value = 10, min = 1, max = 30, step = 1),
                  
                  numericInput("pred_horas", "Horas trabajadas:", 
                               value = 40, min = 20, max = 60, step = 1),
                  
                  numericInput("pred_estres", "Nivel de estrés (1-10):", 
                               value = 5, min = 1, max = 10, step = 1),
                  
                  selectInput("pred_contrato", "Tipo de contrato:",
                              choices = c("fijo", "temporal", "residencia")),
                  
                  numericInput("pred_formacion", "Años de formación adicional:", 
                               value = 2, min = 0, max = 10, step = 1),
                  
                  selectInput("pred_departamento", "Departamento:",
                              choices = NULL), # Se llenará en el servidor
                  
                  br(),
                  actionButton("calcular", "Calcular Predicción", 
                               class = "btn-success")
                ),
                
                box(
                  title = "Resultado de la Predicción", 
                  status = "success", 
                  solidHeader = TRUE,
                  width = 6,
                  h4("Número de procedimientos estimado:"),
                  verbatimTextOutput("prediccion_resultado"),
                  
                  h4("Intervalo de confianza (95%):"),
                  verbatimTextOutput("intervalo_confianza"),
                  
                  h4("Interpretación:"),
                  verbatimTextOutput("interpretacion")
                )
              ),
              
              fluidRow(
                box(
                  title = "Análisis de Sensibilidad", 
                  status = "warning", 
                  solidHeader = TRUE,
                  width = 12,
                  h4("Impacto de cambios en las variables:"),
                  tableOutput("analisis_sensibilidad")
                )
              )
      )
    )
  )
)

# Definir Server
server <- function(input, output, session) {
  
  # Cargar datos
  datos <- reactive({
    # Intentar cargar el archivo CSV
    if(file.exists("procedimientos_hospitales.csv")) {
      df <- read.csv("procedimientos_hospitales.csv")
      # Convertir variables categóricas a factores
      df$departamento <- as.factor(df$departamento)
      df$tipo_contrato <- as.factor(df$tipo_contrato)
      return(df)
    } else {
      # Mostrar mensaje de error si no se encuentra el archivo
      showNotification("Archivo 'procedimientos_hospitales.csv' no encontrado. 
                       Por favor, coloque el archivo en el directorio de trabajo.", 
                       type = "error", duration = 10)
      return(NULL)
    }
  })
  
  # Ajustar modelo
  modelo <- reactive({
    req(datos())
    tryCatch({
      glmer(num_procedimientos ~ experiencia_anios + horas_trabajadas +
              nivel_estres + tipo_contrato + formacion_adicional + (1 | departamento),
            family = poisson(link = "log"),
            data = datos())
    }, error = function(e) {
      showNotification(paste("Error al ajustar el modelo:", e$message), 
                       type = "error")
      return(NULL)
    })
  })
  
  # Actualizar opciones de departamento
  observe({
    req(datos())
    updateSelectInput(session, "pred_departamento",
                      choices = levels(datos()$departamento))
  })
  
  # Gráfico de distribución
  output$hist_procedimientos <- renderPlotly({
    req(datos())
    
    p <- ggplot(datos(), aes(x = num_procedimientos)) +
      geom_histogram(bins = 30, fill = "lightblue", color = "darkblue", alpha = 0.7) +
      labs(title = "Distribución del número de procedimientos",
           x = "Número de procedimientos", 
           y = "Frecuencia") +
      theme_minimal()
    
    ggplotly(p)
  })
  
  # Estadísticas descriptivas
  output$estadisticas_desc <- renderTable({
    req(datos())
    
    stats <- data.frame(
      Estadística = c("Media", "Mediana", "Varianza", "Desviación Estándar", 
                      "Mínimo", "Máximo", "Ratio Varianza/Media"),
      Valor = c(
        round(mean(datos()$num_procedimientos), 2),
        median(datos()$num_procedimientos),
        round(var(datos()$num_procedimientos), 2),
        round(sd(datos()$num_procedimientos), 2),
        min(datos()$num_procedimientos),
        max(datos()$num_procedimientos),
        round(var(datos()$num_procedimientos)/mean(datos()$num_procedimientos), 2)
      )
    )
    
    stats
  })
  
  # Gráfico de dispersión
  output$scatter_plot <- renderPlotly({
    req(datos())
    
    p <- ggplot(datos(), aes_string(x = input$variable_x, y = "num_procedimientos")) +
      geom_point(alpha = 0.6, color = "steelblue") +
      geom_smooth(method = "lm", color = "red", se = TRUE) +
      labs(title = paste("Relación entre", input$variable_x, "y número de procedimientos"),
           x = input$variable_x,
           y = "Número de procedimientos") +
      theme_minimal()
    
    ggplotly(p)
  })
  
  # Boxplot por tipo de contrato
  output$boxplot_contrato <- renderPlotly({
    req(datos())
    
    p <- ggplot(datos(), aes(x = tipo_contrato, y = num_procedimientos, fill = tipo_contrato)) +
      geom_boxplot(alpha = 0.7) +
      labs(title = "Procedimientos por tipo de contrato",
           x = "Tipo de contrato",
           y = "Número de procedimientos") +
      theme_minimal() +
      theme(legend.position = "none")
    
    ggplotly(p)
  })
  
  # Boxplot por departamento
  output$boxplot_departamento <- renderPlotly({
    req(datos())
    
    p <- ggplot(datos(), aes(x = departamento, y = num_procedimientos, fill = departamento)) +
      geom_boxplot(alpha = 0.7) +
      labs(title = "Procedimientos por departamento",
           x = "Departamento",
           y = "Número de procedimientos") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1),
            legend.position = "none")
    
    ggplotly(p)
  })
  
  # Realizar predicción
  prediccion <- eventReactive(input$calcular, {
    req(modelo())
    
    # Crear dataframe con los valores de entrada
    nuevo_caso <- data.frame(
      experiencia_anios = input$pred_experiencia,
      horas_trabajadas = input$pred_horas,
      nivel_estres = input$pred_estres,
      tipo_contrato = factor(input$pred_contrato, levels = levels(datos()$tipo_contrato)),
      formacion_adicional = input$pred_formacion,
      departamento = factor(input$pred_departamento, levels = levels(datos()$departamento))
    )
    
    # Realizar predicción
    pred <- predict(modelo(), newdata = nuevo_caso, type = "response")
    
    # Calcular intervalo de confianza aproximado
    # Para modelos mixtos, esto es una aproximación
    se_pred <- sqrt(var(residuals(modelo())))
    ic_inf <- max(0, pred - 1.96 * se_pred)
    ic_sup <- pred + 1.96 * se_pred
    
    list(
      prediccion = pred,
      ic_inferior = ic_inf,
      ic_superior = ic_sup,
      datos_entrada = nuevo_caso
    )
  })
  
  # Mostrar resultado de predicción
  output$prediccion_resultado <- renderText({
    req(prediccion())
    paste0(round(prediccion()$prediccion, 1), " procedimientos")
  })
  
  # Mostrar intervalo de confianza
  output$intervalo_confianza <- renderText({
    req(prediccion())
    paste0("[", round(prediccion()$ic_inferior, 1), " - ", 
           round(prediccion()$ic_superior, 1), "] procedimientos")
  })
  
  # Interpretación
  output$interpretacion <- renderText({
    req(prediccion())
    
    pred_val <- round(prediccion()$prediccion, 1)
    media_general <- round(mean(datos()$num_procedimientos), 1)
    
    if(pred_val > media_general) {
      paste0("Esta configuración produce ", pred_val, " procedimientos, lo cual está ", 
             round(pred_val - media_general, 1), " procedimientos por encima de la media general (", 
             media_general, ").")
    } else if(pred_val < media_general) {
      paste0("Esta configuración produce ", pred_val, " procedimientos, lo cual está ", 
             round(media_general - pred_val, 1), " procedimientos por debajo de la media general (", 
             media_general, ").")
    } else {
      paste0("Esta configuración produce ", pred_val, " procedimientos, lo cual está cerca de la media general (", 
             media_general, ").")
    }
  })
  
  # Análisis de sensibilidad
  output$analisis_sensibilidad <- renderTable({
    req(prediccion(), modelo())
    
    # Coeficientes del modelo
    coefs <- fixef(modelo())
    
    # Calcular efectos porcentuales
    efectos <- data.frame(
      Variable = c("Experiencia (por año)", "Horas trabajadas (por hora)", 
                   "Nivel de estrés (por punto)", "Contrato temporal vs fijo", 
                   "Contrato residencia vs fijo", "Formación adicional (por año)"),
      
      Efecto_Porcentual = paste0(
        ifelse(c(coefs[2], coefs[3], coefs[4], 
                 if("tipo_contratotemporal" %in% names(coefs)) coefs["tipo_contratotemporal"] else 0,
                 if("tipo_contratoresidencia" %in% names(coefs)) coefs["tipo_contratoresidencia"] else 0,
                 coefs[length(coefs)]) > 0, "+", ""),
        round((exp(c(coefs[2], coefs[3], coefs[4], 
                     if("tipo_contratotemporal" %in% names(coefs)) coefs["tipo_contratotemporal"] else 0,
                     if("tipo_contratoresidencia" %in% names(coefs)) coefs["tipo_contratoresidencia"] else 0,
                     coefs[length(coefs)])) - 1) * 100, 1), "%"
      ),
      
      Interpretacion = c(
        "Incremento por cada año adicional de experiencia",
        "Incremento por cada hora adicional trabajada",
        "Reducción por cada punto adicional de estrés",
        "Diferencia de empleados temporales vs fijos",
        "Diferencia de residentes vs empleados fijos",
        "Incremento por cada año adicional de formación"
      )
    )
    
    efectos
  })
}

# Ejecutar la aplicación
shinyApp(ui = ui, server = server)