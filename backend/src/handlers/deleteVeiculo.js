const { DeleteCommand } = require('@aws-sdk/lib-dynamodb');
const { docClient, tableNameFromEvent } = require('../lib/dynamo');
const { ok, error } = require('../lib/http');

// DELETE /veiculos/{id} - remove um veiculo.
exports.handler = async (event) => {
  const TableName = tableNameFromEvent(event);
  const id = event.pathParameters && event.pathParameters.id;
  if (!id) return error(event, 400, 'Parametro id ausente');

  try {
    await docClient.send(
      new DeleteCommand({
        TableName,
        Key: { id },
        ConditionExpression: 'attribute_exists(id)',
      })
    );
    return ok(event, 200, { success: true, message: 'Veiculo removido com sucesso' });
  } catch (err) {
    if (err.name === 'ConditionalCheckFailedException') {
      return error(event, 404, 'Veiculo nao encontrado');
    }
    console.error('deleteVeiculo error', err);
    return error(event, 500, 'Erro ao remover veiculo', err.message);
  }
};
