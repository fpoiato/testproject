const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client, {
  marshallOptions: { removeUndefinedValues: true },
});

// Modelo compartilhado: o mesmo codigo serve todos os ambientes.
// A tabela e resolvida pelo stage da requisicao (requestContext.stage),
// que corresponde ao ambiente: Veiculos-development, Veiculos-test, etc.
function tableNameFromEvent(event) {
  const stage =
    (event &&
      event.requestContext &&
      event.requestContext.stage &&
      event.requestContext.stage !== '$default' &&
      event.requestContext.stage) ||
    process.env.STAGE ||
    process.env.ENVIRONMENT ||
    'development';
  return `Veiculos-${stage}`;
}

module.exports = { docClient, tableNameFromEvent };
