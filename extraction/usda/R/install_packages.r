# Lista de pacotes necessários para os scripts PSD API e WASDE API
required_packages <- c(
  "httr",        # Para requisições HTTP
  "jsonlite",    # Para manipulação de dados JSON
  "dplyr",       # Para manipulação de data frames
  "purrr",       # Para manipulação funcional
  "readr",       # Para salvar dados em formato CSV
  "stringr",     # Para manipulação de strings (usado no script WASDE)
  "lubridate"    # Para manipulação de datas e horas (usado no script WASDE)
)

# Função para instalar pacotes que ainda não estão instalados
install_if_missing <- function(package) {
  if (!require(package, character.only = TRUE)) {
    install.packages(package)
    library(package, character.only = TRUE)
  }
}

# Instalação dos pacotes
lapply(required_packages, install_if_missing)

# Mensagem final
message("Todos os pacotes necessários foram instalados e carregados com sucesso.")
