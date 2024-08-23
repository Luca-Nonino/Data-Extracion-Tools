
# Data Extraction - Tools & Examples

Este repositório contém uma coleção abrangente de ferramentas e exemplos de código para extração de dados de diversas fontes, com foco em automação, processamento e integração de dados. Os exemplos de código cobrem diferentes linguagens de programação, como Python, R e VBA, e abordam fontes de dados que incluem APIs, HTML dinâmico e estático, WebSockets e arquivos estáticos, como PDFs.

## Estrutura do Repositório

O repositório é dividido em vários módulos, cada um projetado para um caso de uso específico:

### 1. **extraction/bcb** (Banco Central do Brasil)
   - **Python**: Este módulo utiliza a biblioteca `bcb` para extrair dados das Expectativas de Mercado do Banco Central do Brasil. O código realiza chamadas à API para diferentes endpoints e salva os dados em arquivos CSV.
     - **Bibliotecas Python**: `pandas`, `os`, `bcb`
   
   - **R**: Utiliza o pacote `rbcb` para acessar séries temporais do Banco Central, com funções para manipulação de dados e visualizações gráficas.
     - **Bibliotecas R**: `rbcb`, `dplyr`, `ggplot2`, `zoo`

### 2. **extraction/comex** (Balança Comercial Brasileira)
   - **Python**: Conjunto de scripts que fazem o download, filtragem e enriquecimento de dados da balança comercial. Utiliza requisições HTTP assíncronas para baixar grandes volumes de dados e processá-los em chunks, otimizando o uso de memória.
     - **Bibliotecas Python**: `aiohttp`, `pandas`, `os`, `logging`, `asyncio`, `requests`, `aiofiles`

### 3. **extraction/html_dynamic** (Extração de Dados HTML Dinâmicos)
   - **Python**: Exemplos de automação de navegação com `Selenium` para manipulação de páginas dinâmicas, como execução de JavaScript, manipulação de pop-ups e extração de dados através de XPath.
     - **Bibliotecas Python**: `selenium`, `webdriver_manager`, `os`, `pandas`, `time`, `datetime`
   
### 4. **extraction/html_static** (Extração de Dados HTML Estáticos)
   - **Python**: Scripts que utilizam `BeautifulSoup` para parsing de páginas HTML estáticas e extração de conteúdo específico, como links para arquivos PDF e dados em textos estruturados.
     - **Bibliotecas Python**: `requests`, `beautifulsoup4`, `fake_useragent`, `PyMuPDF`, `re`

### 5. **extraction/html_feed** (WebSocket Data Extraction)
   - **Python**: Exemplo de uso de WebSockets para coletar dados em tempo real do Binance, como preços de criptomoedas. O script escuta os feeds em tempo real e salva os dados recebidos.
     - **Bibliotecas Python**: `websockets`, `asyncio`, `pandas`, `json`

### 6. **extraction/indec** (Comércio Exterior da Argentina)
   - **Python**: Scripts para download e processamento de dados do comércio exterior da Argentina, utilizando o site do INDEC.
     - **Bibliotecas Python**: `requests`, `pandas`, `os`, `json`, `re`, `zipfile`, `io`
   
   - **R**: Script em R que lida com o download, extração e limpeza dos dados de exportação da Argentina.
     - **Bibliotecas R**: `httr`, `readr`, `jsonlite`, `dplyr`, `tidyr`, `readxl`, `lubridate`, `stringr`
   
### 7. **extraction/notion** (Integração com Notion)
   - **Python**: Scripts que interagem com a API do Notion para consulta e extração de dados de bancos de dados do Notion. Utiliza a API REST do Notion para recuperar dados estruturados e salvá-los em CSV.
     - **Bibliotecas Python**: `requests`, `json`, `csv`, `os`, `logging`

### 8. **extraction/usda** (Departamento de Agricultura dos Estados Unidos - USDA)
   - **Python**: Scripts para interação com as APIs PSD e WASDE do USDA, para obtenção de previsões e dados de mercado.
     - **Bibliotecas Python**: `requests`, `csv`, `os`, `datetime`
   
   - **R**: Scripts que utilizam a API PSD do USDA para extração de dados sobre commodities e mercados.
     - **Bibliotecas R**: `httr`, `jsonlite`, `dplyr`, `purrr`, `readr`
   
   - **VBA**: Macros que interagem com as APIs do USDA para atualizar automaticamente planilhas do Excel com os dados mais recentes.
  
