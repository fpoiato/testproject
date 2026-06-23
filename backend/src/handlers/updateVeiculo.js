const { UpdateCommand } = require('@aws-sdk/lib-dynamodb');
const { docClient, tableNameFromEvent } = require('../lib/dynamo');
const { ok, error, parseBody } = require('../lib/http');
const { validate, normalize } = require('../lib/veiculo');

// PUT /veiculos/{id} - atualiza campos de um veiculo existente.
exports.handler = async (event) => {
  const TableName = tableNameFromEvent(event);
  const id = event.pathParameters && event.pathParameters.id;
  if (!id) return error(event, 400, 'Parametro id ausente');

  try {
    const body = parseBody(event);
    const errors = validate(body, { partial: true });
    if (errors.length) return error(event, 400, 'Validacao falhou', errors);

    const fields = normalize(body);
    if (Object.keys(fields).length === 0) {
      return error(event, 400, 'Nenhum campo valido para atualizar');
    }
    fields.updatedAt = new Date().toISOString();

    const names = {};
    const values = {};
    const sets = [];
    for (const [k, v] of Object.entries(fields)) {
      names[`#${k}`] = k;
      values[`:${k}`] = v;
      sets.push(`#${k} = :${k}`);
    }

    const result = await docClient.send(
      new UpdateCommand({
        TableName,
        Key: { id },
        UpdateExpression: `SET ${sets.join(', ')}`,
        ExpressionAttributeNames: names,
        ExpressionAttributeValues: values,
        ConditionExpression: 'attribute_exists(id)',
        ReturnValues: 'ALL_NEW',
      })
    );

    return ok(event, 200, {
      success: true,
      data: result.Attributes,
      message: 'Veiculo atualizado com sucesso',
    });
  } catch (err) {
    if (err.name === 'ConditionalCheckFailedException') {
      return error(event, 404, 'Veiculo nao encontrado');
    }
    console.error('updateVeiculo error', err);
    return error(event, err.statusCode || 500, 'Erro ao atualizar veiculo', err.message);
  }
};
