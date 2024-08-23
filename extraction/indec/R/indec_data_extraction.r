# Pacotes necessários
library(httr)     # Para requisições HTTP
library(readr)    # Para ler e escrever arquivos CSV
library(readxl)   # Para ler arquivos Excel
library(jsonlite) # Para manipular dados JSON
library(stringr)  # Para manipulação de strings
library(dplyr)    # Para manipulação de data frames
library(tidyr)    # Para limpeza de dados
library(lubridate) # Para manipulação de datas e horas

# Diretórios e Caminhos
BASE_DIR <- normalizePath(file.path(dirname(rstudioapi::getActiveDocumentContext()$path), '..', '..', '..'))
DATA_DIR <- file.path(BASE_DIR, 'data', 'indec')

# Garante que o diretório exista
if (!dir.exists(DATA_DIR)) {
  dir.create(DATA_DIR, recursive = TRUE)
}

# Função para baixar e extrair os dados de exportação para um ano específico
download_and_extract <- function(year, output_dir) {
  url <- sprintf("https://comex.indec.gob.ar/files/zips/exports_%d_M.zip", year)
  response <- GET(url)
  
  if (status_code(response) != 200) {
    stop("Falha no download do arquivo ZIP.")
  }
  
  temp <- tempfile()
  writeBin(content(response, "raw"), temp)
  unzip(temp, exdir = output_dir)
  unlink(temp)
  
  files <- list.files(output_dir, pattern = sprintf("expom%s.csv|exponm%s.csv|expopm%s.csv", substr(year, 3, 4), substr(year, 3, 4), substr(year, 3, 4)), full.names = TRUE)
  
  if (length(files) > 0) {
    new_file_path <- file.path(output_dir, sprintf("%d_%s", year, basename(files[1])))
    file.rename(files[1], new_file_path)
    message(sprintf("Arquivo '%s' extraído e salvo em: %s", basename(files[1]), new_file_path))
    return(new_file_path)
  }
  return(NULL)
}

# Função para baixar dados auxiliares (ex.: NCM ou países)
download_auxiliary_data <- function(url, output_file) {
  response <- GET(url)
  
  if (status_code(response) != 200) {
    stop("Falha no download dos dados auxiliares.")
  }
  
  writeBin(content(response, "raw"), output_file)
  message(sprintf("Dados auxiliares baixados e salvos em: %s", output_file))
}

# Limpa o diretório de saída (remover arquivos existentes)
clean_output_directory <- function(output_dir) {
  files <- list.files(output_dir, full.names = TRUE)
  if (length(files) > 0) {
    file.remove(files)
  }
}

# Função para limpar e processar os dados de exportação
clean_export_data <- function(df) {
  # Substitui vírgulas por pontos para conversão numérica
  df <- df %>%
    mutate(across(c('Pnet(kg)', 'FOB(u$s)'), ~ str_replace_all(., ",", "."))) %>%
    mutate(across(everything(), ~ str_trim(.)))  # Remove espaços em branco
  
  # Marca registros confidenciais
  df <- df %>%
    mutate(Confidential = ifelse(str_detect(`Pnet(kg)`, "s") | str_detect(`FOB(u$s)`, "s"), "Yes", "No")) %>%
    mutate(across(c('Pnet(kg)', 'FOB(u$s)'), ~ as.numeric(str_replace_all(., "s", ""))))
  
  return(df)
}

# Função principal para baixar, processar e salvar os dados do WASDE
fetch_and_process_data <- function() {
  clean_output_directory(DATA_DIR)
  
  # Baixa e extrai dados de exportação para os últimos 3 anos e o ano atual
  for (year in seq(from = year(Sys.Date()) - 3, to = year(Sys.Date()), by = 1)) {
    download_and_extract(year, DATA_DIR)
  }
  
  # Baixa dados auxiliares (NCM Excel e países JSON)
  ncm_excel_url <- "https://comex.indec.gob.ar/files/amendments/enmienda_VII(desde%202024).xlsx"
  countries_json_url <- "https://comexbe.indec.gob.ar/public-api/report/countries?current=en"
  
  ncm_excel_path <- file.path(DATA_DIR, 'ncm_data.xlsx')
  countries_json_path <- file.path(DATA_DIR, 'countries.json')
  
  download_auxiliary_data(ncm_excel_url, ncm_excel_path)
  
  response <- GET(countries_json_url)
  write(content(response, "text", encoding = "UTF-8"), file = countries_json_path)
  message(sprintf("Dados de países baixados e salvos em: %s", countries_json_path))
  
  # Carrega os dados de exportação e limpa os dados
  csv_files <- list.files(DATA_DIR, pattern = "\\.csv$", full.names = TRUE)
  export_data <- lapply(csv_files, function(file) {
    read_csv(file, delim = ";", locale = locale(encoding = "ISO-8859-1"))
  }) %>%
    bind_rows() %>%
    clean_export_data()
  
  # Carrega e mapeia nomes de países usando o arquivo JSON
  countries_data <- fromJSON(countries_json_path)$data
  country_mapping <- setNames(countries_data$nombre, countries_data$`_id`)
  export_data <- export_data %>%
    mutate(Pdes = as.character(Pdes), Country_Name = country_mapping[Pdes])
  
  # Carrega dados do NCM do Excel e mapeia as descrições
  ncm_data <- read_excel(ncm_excel_path, sheet = "NCM enm7", skip = 3) %>%
    select(NCM = I, NCM_Description = `SECCIÓN I - ANIMALES VIVOS Y PRODUCTOS DEL REINO ANIMAL`) %>%
    mutate(NCM = as.integer(str_remove_all(NCM, "\\.")))
  
  export_data <- export_data %>%
    left_join(ncm_data, by = "NCM")
  
  # Salva os dados processados em CSV
  final_processed_file_path <- file.path(DATA_DIR, 'final_processed_export_data.csv')
  write_csv(export_data, final_processed_file_path)
  message(sprintf("Dados processados salvos em: %s", final_processed_file_path))
  
  # Salva em um novo arquivo com separador de vírgula
  final_csv_path <- file.path(DATA_DIR, 'final_processed_export_data_comma.csv')
  write_csv(export_data, final_csv_path, delim = ",")
  message(sprintf("Dados processados com separador de vírgula salvos em: %s", final_csv_path))
  
  # Exibe as primeiras linhas do dataframe processado
  print(head(export_data))
}

# Execução principal
fetch_and_process_data()
