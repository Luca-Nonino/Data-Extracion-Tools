# Pacotes necessários
library(httr)  # Para fazer as requisições HTTP
library(jsonlite)  # Para manipular os dados JSON
library(dplyr)  # Para manipulação de dados
library(purrr)  # Para manipulação funcional
library(readr)  # Para salvar os dados em CSV

# Constantes
API_KEY <- '697486e5-932d-46d3-804a-388452a19d70'
BASE_URL <- 'https://apps.fas.usda.gov/OpenData/api/psd/'
OUTPUT_FILE <- 'data/usda/commodity_forecast_2024.csv'

# Cabeçalhos para o arquivo CSV de saída
CABECALHOS <- c(
  "commodityCode", "countryCode", "marketYear", "calendarYear", "month",
  "attributeId", "unitId", "commodityName", "attributeName", "unitDescription",
  "countryName", "regionName", "value"
)

# Lista de códigos de commodities e o ano para consulta
COMMODITIES <- c("0440000", "2631000")
ANO <- 2024

# Função auxiliar para fazer as requisições GET à API
get_api_data <- function(endpoint) {
  url <- paste0(BASE_URL, endpoint)
  response <- GET(url, add_headers('Accept' = 'application/json', 'API_KEY' = API_KEY))
  stop_for_status(response)  # Verifica se a requisição foi bem-sucedida
  content(response, as = "text") %>% fromJSON(flatten = TRUE)  # Retorna o conteúdo JSON como lista
}

# Função para buscar dados auxiliares de regiões, países, commodities, atributos e unidades
fetch_auxiliary_data <- function() {
  # Cria dicionários (listas nomeadas) para mapear códigos aos nomes correspondentes
  regioes <- get_api_data('regions') %>% 
    setNames(.$regionName, .$regionCode)
  
  paises <- get_api_data('countries') %>% 
    transmute(countryCode, countryName = .$countryName, regionName = regioes[.$regionCode])
  
  commodities <- get_api_data('commodities') %>% 
    setNames(.$commodityName, .$commodityCode)
  
  atributos <- get_api_data('commodityAttributes') %>% 
    setNames(.$attributeName, .$attributeId)
  
  unidades <- get_api_data('unitsOfMeasure') %>% 
    setNames(trimws(.$unitDescription), .$unitId)
  
  list(paises = paises, commodities = commodities, atributos = atributos, unidades = unidades)
}

# Função para buscar dados de previsão para uma commodity e ano específico (tanto nível de país quanto global)
fetch_forecast_data <- function(commodity_code, ano) {
  dados_paises <- get_api_data(paste0('commodity/', commodity_code, '/country/all/year/', ano))
  dados_mundiais <- get_api_data(paste0('commodity/', commodity_code, '/world/year/', ano))
  
  # Mescla os dados de países e mundial
  bind_rows(dados_paises, dados_mundiais)
}

# Função para processar e salvar os dados no CSV
process_and_write_data <- function(paises, commodities, atributos, unidades) {
  # Abre o arquivo CSV para escrita
  write_csv(tibble(CABECALHOS), OUTPUT_FILE)  # Escreve o cabeçalho no arquivo
  
  # Itera sobre cada código de commodity
  walk(COMMODITIES, function(commodity_code) {
    forecast_data <- fetch_forecast_data(commodity_code, ANO)
    
    # Processa cada registro da previsão
    forecast_data %>% 
      mutate(
        commodityName = commodities[commodityCode],
        attributeName = atributos[attributeId],
        unitDescription = unidades[unitId],
        countryName = if_else(countryCode == "00", "World", paises$countryName[paises$countryCode == countryCode]),
        regionName = if_else(countryCode == "00", "Global", paises$regionName[paises$countryCode == countryCode])
      ) %>% 
      select(all_of(CABECALHOS)) %>% 
      write_csv(OUTPUT_FILE, append = TRUE)
  })
}

# Função principal para executar o script
main <- function() {
  # Busca os dados auxiliares
  dados_auxiliares <- fetch_auxiliary_data()
  
  # Processa e salva os dados no CSV
  process_and_write_data(dados_auxiliares$paises, dados_auxiliares$commodities, dados_auxiliares$atributos, dados_auxiliares$unidades)
  
  message(sprintf("Dados salvos com sucesso em %s", OUTPUT_FILE))
}

# Ponto de entrada do script
if (interactive()) {
  main()
}
