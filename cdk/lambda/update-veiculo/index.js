const { DynamoDB } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient } = require('@aws-sdk/lib-dynamodb');

const ddb = new DynamoDB({});
const docClient = DynamoDBDocumentClient.from(ddb);

const TABLE_NAME = process.env.DYNAMODB_TABLE;

exports.handler = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));

  try {
    const placa = event.pathParameters.placa;
    const body = JSON.parse(event.body);

    // Build update expression dynamically
    const updateExpressions = [];
    const expressionAttributeNames = {};
    const expressionAttributeValues = {};

    if (body.marca !== undefined) {
      updateExpressions.push('#marca = :marca');
      expressionAttributeNames['#marca'] = 'marca';
      expressionAttributeValues[':marca'] = body.marca;
    }

    if (body.modelo !== undefined) {
      updateExpressions.push('#modelo = :modelo');
      expressionAttributeNames['#modelo'] = 'modelo';
      expressionAttributeValues[':modelo'] = body.modelo;
    }

    if (body.ano !== undefined) {
      updateExpressions.push('#ano = :ano');
      expressionAttributeNames['#ano'] = 'ano';
      expressionAttributeValues[':ano'] = body.ano;
    }

    if (body.cor !== undefined) {
      updateExpressions.push('#cor = :cor');
      expressionAttributeNames['#cor'] = 'cor';
      expressionAttributeValues[':cor'] = body.cor;
    }

    // Only if there's something to update
    if (updateExpressions.length === 0) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({
          success: false,
          error: 'No fields to update',
        }),
      };
    }

    updateExpressions.push('updatedAt = :updatedAt');
    expressionAttributeValues[':updatedAt'] = new Date().toISOString();

    const params = {
      TableName: TABLE_NAME,
      Key: {
        placa: placa,
      },
      UpdateExpression: `SET ${updateExpressions.join(', ')}`,
      ExpressionAttributeNames: expressionAttributeNames,
      ExpressionAttributeValues: expressionAttributeValues,
      ReturnValues: 'ALL_NEW',
    };

    const result = await docClient.update(params);
    console.log('Update result:', result);

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        success: true,
        data: result.Attributes,
        message: 'Veículo atualizado com sucesso',
      }),
    };
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        success: false,
        error: error.message,
      }),
    };
  }
};
