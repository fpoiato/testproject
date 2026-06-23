const { randomUUID } = require('crypto');
const { PutCommand } = require('@aws-sdk/lib-dynamodb');
const { docClient, tableNameFromEvent } = require('../lib/dynamo');
const { ok, error, parseBody } = require('../lib/http');
const { validate, normalize } = require('../lib/veiculo');

// POST /veiculos - cria um veiculo (id gerado via uuid).
exports.handler = async (event) => {
  const TableName = tableNameFromEvent(event);
  try {
    const body = parseBody(event);
    const errors = validate(body);
    if (errors.length) return error(event, 400, 'Validacao falhou', errors);

    const now = new Date().toISOString();
    const item = {
      id: randomUUID(),
      ...normalize(body),
      createdAt: now,
      updatedAt: now,
    };

    await docClient.send(new PutCommand({ TableName, Item: item }));
    return ok(event, 201, {
      success: true,
      data: item,
      message: 'Veiculo criado com sucesso',
    });
  } catch (err) {
    console.error('createVeiculo error', err);
    return error(event, err.statusCode || 500, 'Erro ao criar veiculo', err.message);
  }
};
