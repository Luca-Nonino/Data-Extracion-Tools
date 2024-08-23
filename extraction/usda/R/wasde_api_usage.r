# Pacotes necessários
library(httr)  # Para fazer as requisições HTTP
library(readr)  # Para manipulação de arquivos CSV
library(stringr)  # Para manipulação de strings
library(lubridate)  # Para manipulação de datas e horas

# Constantes
BASE_URL <- "https://www.usda.gov/sites/default/files/documents/oce-wasde-report-data-"
OUTPUT_FILE <- 'data/usda/wasde_data_2024.csv'
SELECTED_REPORTS <- c(
  "U.S. Wheat Supply and Use", "World Soybean Oil Supply and Use", "World Wheat Supply and Use",
  "Mexico Sugar Supply and Use and High Fructose Corn Syrup Consumption", "U.S. Cotton Supply and Use",
  "U.S. Wheat by Class: Supply and Use", "U.S. Soybeans and Products Supply and Use (Domestic Measure)",
  "World Cotton Supply and Use", "World Corn Supply and Use", "U.S. Feed Grain and Corn Supply and Use",
  "World and U.S. Supply and Use for Oilseeds", "World Soybean Supply and Use",
  "World and U.S. Supply and Use for Cotton", "World Soybean Meal Supply and Use"
)

# Função para gerar URLs dos CSVs para todos os meses do ano corrente até o mês atual
generate_csv_urls_for_current_year <- function() {
  current_date <- Sys.Date()
  current_year <- year(current_date)
  current_month <- month(current_date)
  
  csv_urls <- vector("character", current_month)  # Vetor para armazenar URLs dos CSVs
  
  for (month in 1:current_month) {
    month_str <- sprintf("%02d", month)  # Formata o mês com dois dígitos
    csv_urls[month] <- paste0(BASE_URL, current_year, "-", month_str, ".csv")
  }
  
  return(csv_urls)
}

# Função auxiliar para verificar se um relatório está na lista de relatórios selecionados
is_selected_report <- function(report_title) {
  return(report_title %in% SELECTED_REPORTS)
}

# Função para processar e carregar dados do CSV
process_csv_data <- function(csv_url, output_file) {
  tryCatch({
    # Faz a requisição HTTP para o CSV
    response <- GET(csv_url)
    stop_for_status(response)  # Verifica se a requisição foi bem-sucedida
    
    # Lê o conteúdo do CSV
    csv_content <- content(response, as = "text")
    csv_lines <- str_split(csv_content, "\n")[[1]]  # Divide o conteúdo em linhas
    
    # Abre o arquivo de saída em modo de adição (append)
    file_conn <- file(output_file, open = "a", encoding = "UTF-8")
    
    # Processa cada linha do CSV, ignorando o cabeçalho
    for (line in csv_lines[-1]) {
      data_fields <- read_csv(line, col_names = FALSE, show_col_types = FALSE)
      
      # Verifica se a linha tem 16 campos e se o relatório está na lista selecionada
      if (ncol(data_fields) == 16 && is_selected_report(data_fields[[3]])) {
        write_csv(data_fields, file_conn, append = TRUE)  # Escreve a linha no arquivo de saída
      }
    }
    
    close(file_conn)  # Fecha a conexão com o arquivo
    return(TRUE)
    
  }, error = function(e) {
    # Captura erros de requisição HTTP e outros erros
    message("Ocorreu um erro: ", e$message)
    return(FALSE)
  })
}

# Função principal para buscar e carregar os dados do WASDE para o ano corrente
fetch_and_load_wasde_data_for_this_year <- function() {
  # Gera URLs dos CSVs até o mês atual
  csv_urls <- generate_csv_urls_for_current_year()
  
  message("Buscando relatórios para as seguintes URLs:")
  print(csv_urls)
  
  # Processa cada URL de CSV e carrega os dados
  for (url in csv_urls) {
    if (!process_csv_data(url, OUTPUT_FILE)) {
      message("Relatório não lançado para a URL: ", url)
    }
  }
  
  message("Dados carregados com sucesso.")
}

# Executa o script principal
if (interactive()) {
  # Garante que o diretório de saída exista
  dir.create(dirname(OUTPUT_FILE), recursive = TRUE, showWarnings = FALSE)
  
  # Inicia o processo de busca e carregamento dos dados
  fetch_and_load_wasde_data_for_this_year()
}
