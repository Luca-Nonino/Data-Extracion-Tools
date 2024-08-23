
# Extração de Dados da API PSD do USDA com R

## Visão Geral

Este projeto em R faz a extração de dados de previsões de commodities da API PSD (Production, Supply and Distribution) do USDA (Departamento de Agricultura dos Estados Unidos). Ele consome dados da API no formato JSON e os salva em um arquivo CSV. O objetivo principal é demonstrar como interagir com uma API RESTful, consumir dados JSON e processá-los em R.

### API PSD do USDA

A API PSD do USDA fornece dados sobre a produção, oferta e distribuição de commodities agrícolas em todo o mundo. Os principais endpoints da API incluem:

- **Regiões** (`/api/psd/regions`): Retorna informações sobre regiões globais.
- **Países** (`/api/psd/countries`): Retorna informações sobre países e as regiões a que pertencem.
- **Commodities** (`/api/psd/commodities`): Retorna uma lista de commodities e seus códigos correspondentes.
- **Unidades de Medida** (`/api/psd/unitsOfMeasure`): Retorna uma lista de unidades de medida e seus IDs.
- **Atributos de Commodities** (`/api/psd/commodityAttributes`): Retorna uma lista de atributos (por exemplo, "Área Plantada", "Produção") utilizados nas previsões das commodities.

A API também permite acessar previsões específicas para commodities por país e ano.

### Estrutura dos Dados JSON

Os dados retornados pela API do USDA estão no formato JSON, que é uma estrutura de dados leve e amplamente utilizada para transmitir dados entre um servidor e um cliente. No R, utilizamos pacotes como `jsonlite` para manipular essas estruturas e convertê-las em formatos mais familiares, como data frames.

#### Exemplo de Estrutura JSON (Regiões):
```json
[
  {
    "regionCode": "R00",
    "regionName": "World"
  },
  {
    "regionCode": "R01",
    "regionName": "North America"
  }
]
```

Esses dados podem ser convertidos para um data frame em R para facilitar a manipulação.

## Requisitos

Para executar este projeto, é necessário ter os seguintes pacotes R instalados:

- `httr`: Para fazer requisições HTTP.
- `jsonlite`: Para manipulação de dados JSON.
- `dplyr`: Para manipulação de dados em data frames.
- `purrr`: Para manipulação funcional.
- `readr`: Para salvar dados em formato CSV.

Você pode instalar esses pacotes utilizando o seguinte código:
```r
install.packages(c("httr", "jsonlite", "dplyr", "purrr", "readr"))
```

## Uso da API PSD com R

### Autenticação

Para acessar a API, você precisará de uma chave de API (API_KEY). No código, essa chave é armazenada em uma variável constante:
```r
API_KEY <- 'sua-chave-api-aqui'
```

Essa chave é usada em todas as requisições HTTP para autenticar o usuário.

### Estrutura do Código

#### 1. **Função `get_api_data(endpoint)`**

Esta função faz uma requisição GET ao endpoint especificado da API e retorna o conteúdo da resposta no formato de lista R (convertido a partir do JSON).

Exemplo:
```r
# Faz uma requisição ao endpoint de regiões
regioes <- get_api_data('regions')
```

#### 2. **Função `fetch_auxiliary_data()`**

Esta função recupera os dados auxiliares de regiões, países, commodities, atributos e unidades de medida. Esses dados são essenciais para mapear os códigos (ex.: códigos de países e commodities) aos seus respectivos nomes.

Exemplo:
```r
# Recupera todos os dados auxiliares
dados_auxiliares <- fetch_auxiliary_data()
```

#### 3. **Função `fetch_forecast_data(commodity_code, ano)`**

Esta função faz requisições à API para recuperar os dados de previsão de uma commodity específica em um determinado ano, tanto para dados de países quanto para dados globais (mundo).

Exemplo:
```r
# Busca os dados de previsão para o código da commodity "0440000" no ano de 2024
previsao <- fetch_forecast_data("0440000", 2024)
```

#### 4. **Função `process_and_write_data()`**

Essa função processa os dados de previsão, combinando-os com as informações auxiliares para gerar um arquivo CSV final.

Exemplo:
```r
# Processa e salva os dados de previsão em um arquivo CSV
process_and_write_data(dados_auxiliares$paises, dados_auxiliares$commodities, dados_auxiliares$atributos, dados_auxiliares$unidades)
```

#### 5. **Função Principal `main()`**

A função `main` coordena o fluxo de execução do script: obtém os dados auxiliares, processa as previsões e salva os resultados em um arquivo CSV.

### Salvando os Dados

Os dados processados são salvos em um arquivo CSV especificado pela constante `OUTPUT_FILE`. Esse arquivo contém todas as previsões de commodities para o ano de 2024, incluindo informações sobre o código da commodity, país, região, unidade de medida e valores das previsões.

## Exemplo de Execução

Para executar o código, basta rodar a função principal:
```r
main()
```

Após a execução, os dados serão salvos no arquivo `data/usda/commodity_forecast_2024.csv`.

## Considerações Finais

Este projeto demonstra como consumir uma API RESTful em R, manipular dados JSON e salvá-los em um formato estruturado. A combinação de pacotes como `httr`, `jsonlite`, `dplyr` e `purrr` torna o processamento de grandes volumes de dados de APIs uma tarefa simples e eficiente no R.

### Boas Práticas

Seguindo as boas práticas de programação em R, como documentado no arquivo `r-style-guide.txt`, o código está organizado de forma clara, com nomes de funções e variáveis descritivos, uso consistente de espaços e indentação adequada【28†source】【29†source】. Essas práticas ajudam a garantir a legibilidade e manutenibilidade do código a longo prazo.
