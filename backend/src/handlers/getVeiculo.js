const { GetCommand } = require('@aws-sdk/lib-dynamodb');
const { docClient, tableNameFromEvent } = require('../lib/dynamo');
const { ok, error } = require('../lib/http');

// GET /veiculos/{id} - retorna um veiculo.
exports.handler = async (event) => {
  const TableName = tableNameFromEvent(event);
  const id = event.pathParameters && event.pathParameters.id;
  if (!id) return error(event, 400, 'Parametro id ausente');

  try {
    const result = await docClient.send(
      new GetCommand({ TableName, Key: { id } })
    );
    if (!result.Item) return error(event, 404, 'Veiculo nao encontrado');
    return ok(event, 200, { success: true, data: result.Item });
  } catch (err) {
    console.error('getVeiculo error', err);
    return error(event, 500, 'Erro ao buscar veiculo', err.message);
  }
};
