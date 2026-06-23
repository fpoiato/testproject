# TASK-032 - Export para Excel

## Objetivo
Exportar a lista filtrada de veiculos para um arquivo `.xlsx` no cliente.

## Contexto
Parte do [EPIC-006](https://github.com/fpoiato/testproject/issues/47).

## Arquivos afetados
- `frontend/src/app/features/veiculos/veiculos.component.ts` (xlsx)

## Criterios de aceite
- Botao "Exportar Excel" gera arquivo com colunas Marca/Modelo/Versao/Cor/Ano
  respeitando o filtro/busca atuais.
