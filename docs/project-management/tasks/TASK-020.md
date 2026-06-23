# TASK-020 - Backend remoto Terraform + cleanup

## Objetivo
Migrar o state para backend remoto (S3 + DynamoDB lock) e remover o stack antigo
(dev parcial) e a stack CloudFormation do CDK (SamAppStack).

## Contexto
Parte do [EPIC-004](https://github.com/fpoiato/testproject/issues/45).

## Resultado
- Bucket `testproject-tfstate-986873053420` (versionado) + tabela `testproject-tflock`.
- `backend.tf` configurando o backend S3.
- Stack dev antigo destruido (43 recursos) e `SamAppStack` deletada.
