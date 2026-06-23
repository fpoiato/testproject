const { ScanCommand } = require('@aws-sdk/lib-dynamodb');
const { docClient, tableNameFromEvent } = require('../lib/dynamo');
const { ok, error } = require('../lib/http');

// GET /veiculos - lista todos os veiculos do ambiente.
exports.handler = async (event) => {
  const TableName = tableNameFromEvent(event);
  try {
    const items = [];
    let ExclusiveStartKey;
    do {
      const result = await docClient.send(
        new ScanCommand({ TableName, ExclusiveStartKey })
      );
      items.push(...(result.Items || []));
      ExclusiveStartKey = result.LastEvaluatedKey;
    } while (ExclusiveStartKey);

    return ok(event, 200, { success: true, data: items, count: items.length });
  } catch (err) {
    console.error('getVeiculos error', err);
    return error(event, 500, 'Erro ao listar veiculos', err.message);
  }
};
