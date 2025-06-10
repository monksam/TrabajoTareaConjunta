# Análisis Integral de Procedimientos Hospitalarios: Una Aproximación Multimetodológica

**Autores:** Saray Calvo Parra, Vaska Tomova Manolova y Santiago Agustín Moncalero  
Tarea conjunto del Modulo IV -Máster en Bioestadística - Universidad de Valencia  
**Fecha:** Junio 2025

## 📋 Descripción del Proyecto

Este repositorio contiene un análisis estadístico integral de los factores que influyen en la productividad médica hospitalaria, medida a través del número de procedimientos realizados. El estudio implementa una **estrategia de modelización progresiva** que integra múltiples enfoques metodológicos para identificar y cuantificar los determinantes de la productividad en el ámbito hospitalario.

## 🎯 Objetivos

- **Objetivo Principal:** Identificar y cuantificar los factores que influyen en el número de procedimientos realizados por el personal médico
- **Objetivos Específicos:**
  - Evaluar el impacto de factores individuales (experiencia, formación, estrés)
  - Analizar el efecto de variables organizacionales (tipo de contrato, departamento)
  - Desarrollar un modelo predictivo robusto para la gestión hospitalaria
  - Validar los hallazgos mediante múltiples enfoques metodológicos

## 📊 Metodología

### Estrategia de Modelización Progresiva

**Fase I: Modelos Lineales Generalizados (GLM)**
- Modelo Poisson básico
- Modelo Binomial Negativo para manejo de sobredispersión

**Fase II: Modelos de Suavizado, Aditivos y Mixtos (GAM)**
- GAM con splines para detectar no linealidades
- GAM mixtos con efectos aleatorios departamentales

**Fase III: Validación Bayesiana**
- Implementación MCMC del modelo óptimo
- Diagnósticos de convergencia y validación cruzada

## 📈 Principales Hallazgos

- **Experiencia profesional:** +5.3% por año adicional
- **Intensidad laboral:** +2.9% por hora trabajada
- **Estrés laboral:** -6.5% por punto de estrés
- **Precariedad contractual:** Residentes (-39.3%) y temporales (-16.3%) vs. personal fijo
- **Formación especializada:** +8.8% por año de formación adicional

**Modelo Final:** GLM jerárquico Poisson con R² = 0.76

## 📁 Contenido del Repositorio

```
├── app.R                              # Aplicación Shiny interactiva
├── Informe.Rmd                        # Código R Markdown del análisis
├── procedimientos_hospitales.csv      # Base de datos utilizada
├── informe_final.pdf                  # Informe completo en PDF
├── Podcast Analisis.mp4               # podcast de 7 minutos generados con IA, analizando los resultados
└── README.md                          # Este archivo
```

## 🚀 Aplicación Shiny

La aplicación web interactiva incluye tres módulos principales:

### 📖 **Explicación del Estudio**
- Resumen de objetivos y metodología
- Principales hallazgos y conclusiones
- Características del modelo final

### 📊 **Análisis Gráfico**
- Distribución de la variable respuesta
- Relaciones entre variables explicativas
- Comparaciones por grupos (contrato, departamento)
- Gráficos interactivos con Plotly

### 🔮 **Predictor Interactivo**
- Herramienta de predicción en tiempo real
- Intervalos de confianza
- Análisis de sensibilidad
- Interpretación automática de resultados

## 💻 Instalación y Uso

### Prerrequisitos

```r
# Instalar paquetes necesarios
install.packages(c("shiny", "shinydashboard", "DT", "ggplot2", 
                   "plotly", "dplyr", "lme4", "MASS", "mgcv", 
                   "glmmTMB", "kableExtra", "performance"))
```

### Ejecutar la Aplicación

```r
# Clonar el repositorio
git clone https://github.com/[tu-usuario]/procedimientos-hospitalarios

# Cambiar al directorio del proyecto
setwd("procedimientos-hospitalarios")

# Ejecutar la aplicación Shiny
shiny::runApp("app.R")
```

## 📊 Estructura de los Datos

La base de datos `procedimientos_hospitales.csv` contiene las siguientes variables:

| Variable | Tipo | Descripción |
|----------|------|-------------|
| `num_procedimientos` | Numérica | Número de procedimientos realizados (variable respuesta) |
| `experiencia_anios` | Numérica | Años de experiencia profesional |
| `horas_trabajadas` | Numérica | Horas trabajadas por período |
| `nivel_estres` | Numérica | Nivel de estrés laboral (escala 1-10) |
| `tipo_contrato` | Categórica | Tipo de contrato (fijo, temporal, residencia) |
| `formacion_adicional` | Numérica | Años de formación especializada adicional |
| `departamento` | Categórica | Departamento hospitalario |

## 📋 Resultados Principales

### Modelo Final: GLM Jerárquico Poisson

```
log(E[procedimientos]) = β₀ + β₁×experiencia + β₂×horas + β₃×estrés + 
                         β₄×contrato + β₅×formación + u_departamento
```

**Métricas de Rendimiento:**
- R² = 0.76
- RMSE = 3.6 procedimientos (~24% de la media)
- MAE = 2.8 procedimientos (~18% de la media)

**Validación Bayesiana:**
- Convergencia robusta (R̂ < 1.02)
- Diferencia promedio < 0.33% entre estimaciones frecuentistas y Bayesianas

## 📚 Referencias y Metodología

El análisis integra técnicas de:
- **Modelos Lineales Generalizados:** Manejo de datos de conteo con sobredispersión
- **Modelos Aditivos Generalizados:** Detección de no linealidades
- **Modelos Mixtos:** Incorporación de estructura jerárquica
- **Estadística Bayesiana:** Cuantificación de incertidumbre y validación

## 🤝 Contribuciones

Este proyecto fue desarrollado como parte del Máster en Bioestadística de la Universidad de Valencia. 

**Autores:**
- **Saray Calvo Parra** 
- **Vaska Tomova Manolova** 
- **Santiago Agustín Moncalero**  

## 📄 Licencia

Este proyecto tiene fines académicos y está disponible para uso educativo y de investigación.

## 📞 Contacto

Para consultas sobre este proyecto, contactar a través de la Universidad de Valencia - Máster en Bioestadística.

---

*Proyecto desarrollado en R y Shiny | Universidad de Valencia | 2025*
