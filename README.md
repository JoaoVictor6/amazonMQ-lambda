# AmazonMQ + Lambda
Este projeto é uma poc. Queremos testar como seria integração de amazonMQ com lambdas por eventBridge.

## Stack
- AWS
    - AmazonMQ
    - EventBridge
    - Lmabda Function
- LocalStack(para testes locais)
    - Docker

## Exemplo
Nessa POC criaremos 3 lambdas functions:
- Emissor: responsavel pro disparar itens no tópico "edição-de-proposta"
- Receptor principal: Responsavel por ouvir o tópico "edição-de-proposta" e lidar com essa valor.(no momento somente printar nos logs, estamos em um POC)
- Receptor para itens obsoletos: Caso o valor disparador no tópico "edição-de-proposta" tenha o campo "isObsoleto" como true, esse receptor deve receber o item.

## Pontos importante
- A configuração do que a lambda function devera ouvir eh eita a nivel de eventBridge. Logo, teremos tudo documentado via codigo com terraform
- Esse exemplo tende a ser o mais simples possivel. A ideia é validar essa infra.

## Como testar
Temos um conjunto de scripts que orquestram o ambiente local e a validação da POC. O script principal é o `run_all.sh`.

## Checklist

*   [x] Configurar o LocalStack com Docker
*   [x] Criar um script Terraform para definir a infraestrutura
    *   [x] Criar uma instância do AmazonMQ
    *   [x] Criar três funções Lambda (emissor, receptor principal e receptor de obsoletos)
    *   [x] Criar um EventBridge para conectar o AmazonMQ às funções Lambda
*   [x] Criar um script para testar a infraestrutura
    *   [x] Refatorar script de teste em scripts menores.
*   [x] Escrever o código para as três funções Lambda
    *   [x] Função emissora
        *   [x] devemos conseguir alterar o valor "isObsoleto" por parametros.
    *   [x] Função receptora principal
    *   [x] Função receptora de obsoletos
*   [ ] Testar a solução
*   [ ] Atualizar o arquivo `README.md` com os resultados dos testes

## Resultados dos testes

O script de teste foi refatorado em scripts menores. Para executar todos os testes, utilize o script `run_all.sh`.
