
# Extração de Dados WASDE com R

## Visão Geral

Este projeto foi criado para baixar, processar e salvar dados dos relatórios do WASDE (World Agricultural Supply and Demand Estimates) disponibilizados pelo USDA (Departamento de Agricultura dos Estados Unidos). Os relatórios são baixados em formato CSV diretamente do site do USDA, e os dados de interesse são filtrados e salvos em um arquivo CSV para análise posterior.

### WASDE

O WASDE é um relatório mensal preparado pela World Agricultural Outlook Board (WAOB) que fornece previsões sobre a produção, oferta e demanda de commodities agrícolas globais. Este projeto automatiza a extração desses dados, facilitando a análise das previsões mensais.

### API de Relatórios CSV do USDA

Os dados são disponibilizados via arquivos CSV hospedados no site do USDA. Cada arquivo CSV contém informações de diversos relatórios que podem ser processados automaticamente com este script em R.

## Requisitos

Para executar este projeto, você precisará dos seguintes pacotes R:

- **httr**: Para fazer requisições HTTP e baixar os arquivos CSV.
- **readr**: Para leitura e gravação de arquivos CSV.
- **stringr**: Para manipulação de strings, como divisão de linhas.
- **lubridate**: Para manipulação de datas e horas.

Você pode instalar esses pacotes usando o seguinte comando:

```r
install.packages(c("httr", "readr", "stringr", "lubridate"))
```

## Estrutura dos Dados CSV

Cada arquivo CSV contém várias linhas, com cada linha representando um relatório diferente. Para processar os dados de maneira eficiente, o script verifica se o relatório está na lista de relatórios selecionados (`SELECTED_REPORTS`) antes de salvá-lo no arquivo final.

Exemplo de linha CSV:

```csv
2024,08,U.S. Wheat Supply and Use,...,5000000
```

Esse formato inclui o ano, mês, nome do relatório, e outros dados, como números de produção e consumo.

## Estrutura do Código

### 1. **Função `generate_csv_urls_for_current_year()`**

Essa função gera as URLs dos arquivos CSV de todos os meses do ano corrente até o mês atual. As URLs são construídas com base no ano e no mês, usando o formato `ano-mês` (exemplo: `2024-08`).

### 2. **Função `is_selected_report(report_title)`**

Essa função verifica se o título de um relatório está na lista `SELECTED_REPORTS`. Apenas os relatórios que estão nessa lista serão processados e salvos no arquivo final.

### 3. **Função `process_csv_data(csv_url, output_file)`**

Essa função baixa o arquivo CSV da URL fornecida, processa as linhas e salva no arquivo de saída apenas os relatórios que correspondem aos selecionados. Ela faz o seguinte:

- Faz a requisição HTTP para baixar o arquivo CSV.
- Divide o conteúdo do arquivo CSV em linhas.
- Verifica se o relatório pertence à lista de relatórios selecionados.
- Salva os dados no arquivo CSV final.

### 4. **Função `fetch_and_load_wasde_data_for_this_year()`**

Essa é a função principal do script. Ela gera as URLs dos relatórios mensais para o ano corrente, faz o download e processamento dos dados, e salva os resultados no arquivo `OUTPUT_FILE`.

### 5. **Execução do Script**

O script verifica se o diretório de saída existe, e se não, cria-o. Em seguida, executa a função principal para processar os dados do WASDE.

## Como Usar

### Passo 1: Configuração do Ambiente

Certifique-se de ter instalado todos os pacotes R necessários mencionados na seção "Requisitos". Depois, configure o seu ambiente de trabalho no R.

### Passo 2: Executar o Script

Para executar o script e carregar os dados do WASDE, basta rodar o seguinte comando no R:

```r
fetch_and_load_wasde_data_for_this_year()
```

O script fará o download dos relatórios CSV até o mês atual, filtrará os dados de interesse e salvará os resultados no arquivo `data/usda/wasde_data_2024.csv`.

### Passo 3: Verificação dos Dados

Após a execução, você encontrará os dados filtrados e salvos no arquivo `OUTPUT_FILE`. Este arquivo CSV conterá os relatórios selecionados para o ano corrente.

## Personalização

Se você quiser adicionar ou remover relatórios da lista `SELECTED_REPORTS`, basta editar a lista no código R:

```r
SELECTED_REPORTS <- c(
  "U.S. Wheat Supply and Use", 
  "World Soybean Oil Supply and Use",
  ...
)
```

## Considerações Finais

Este projeto automatiza o processo de download e processamento dos dados dos relatórios WASDE, permitindo uma análise eficiente das previsões agrícolas feitas pelo USDA. Ao combinar ferramentas poderosas como `httr`, `readr` e `lubridate`, é possível obter e preparar grandes volumes de dados de forma simples e escalável.
