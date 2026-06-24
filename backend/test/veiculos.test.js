const { mockClient } = require('aws-sdk-client-mock');
const { DynamoDBDocumentClient, ScanCommand, GetCommand, PutCommand, UpdateCommand, DeleteCommand } = require('@aws-sdk/lib-dynamodb');

const ddbMock = mockClient(DynamoDBDocumentClient);

const getVeiculos = require('../src/handlers/getVeiculos');
const getVeiculo = require('../src/handlers/getVeiculo');
const createVeiculo = require('../src/handlers/createVeiculo');
const updateVeiculo = require('../src/handlers/updateVeiculo');
const deleteVeiculo = require('../src/handlers/deleteVeiculo');
const { validate } = require('../src/lib/veiculo');

const baseEvent = { requestContext: { stage: 'test' }, headers: {} };

beforeEach(() => ddbMock.reset());

describe('validate', () => {
  test('aceita veiculo completo e valido', () => {
    expect(validate({ placa: 'ABC1D23', marca: 'VW', modelo: 'Golf', versao: 'GTI', cor: 'Preto', ano: 2020 })).toEqual([]);
  });
  test('rejeita campos obrigatorios ausentes', () => {
    const errors = validate({ versao: 'GTI' });
    expect(errors.length).toBeGreaterThan(0);
  });
  test('rejeita ano invalido', () => {
    const errors = validate({ marca: 'VW', modelo: 'Golf', cor: 'Preto', ano: 1800 });
    expect(errors.some((e) => e.includes('ano'))).toBe(true);
  });
});

describe('getVeiculos', () => {
  test('retorna lista com count', async () => {
    ddbMock.on(ScanCommand).resolves({ Items: [{ id: '1', marca: 'VW' }], LastEvaluatedKey: undefined });
    const res = await getVeiculos.handler(baseEvent);
    expect(res.statusCode).toBe(200);
    const body = JSON.parse(res.body);
    expect(body.count).toBe(1);
    expect(body.data[0].marca).toBe('VW');
  });
});

describe('getVeiculo', () => {
  test('404 quando nao existe', async () => {
    ddbMock.on(GetCommand).resolves({ Item: undefined });
    const res = await getVeiculo.handler({ ...baseEvent, pathParameters: { id: 'x' } });
    expect(res.statusCode).toBe(404);
  });
});

describe('createVeiculo', () => {
  test('cria com id uuid e campos normalizados', async () => {
    ddbMock.on(PutCommand).resolves({});
    const res = await createVeiculo.handler({
      ...baseEvent,
      body: JSON.stringify({ placa: 'XYZ4E56', marca: 'Fiat', modelo: 'Uno', versao: 'Mille', cor: 'Branco', ano: 2015 }),
    });
    expect(res.statusCode).toBe(201);
    const body = JSON.parse(res.body);
    expect(body.data.id).toMatch(/[0-9a-f-]{36}/);
    expect(body.data.modelo).toBe('Uno');
  });
  test('400 quando invalido', async () => {
    const res = await createVeiculo.handler({ ...baseEvent, body: JSON.stringify({ marca: 'Fiat' }) });
    expect(res.statusCode).toBe(400);
  });
});

describe('updateVeiculo', () => {
  test('atualiza e retorna ALL_NEW', async () => {
    ddbMock.on(UpdateCommand).resolves({ Attributes: { id: '1', cor: 'Azul' } });
    const res = await updateVeiculo.handler({
      ...baseEvent,
      pathParameters: { id: '1' },
      body: JSON.stringify({ cor: 'Azul' }),
    });
    expect(res.statusCode).toBe(200);
    expect(JSON.parse(res.body).data.cor).toBe('Azul');
  });
});

describe('deleteVeiculo', () => {
  test('remove com sucesso', async () => {
    ddbMock.on(DeleteCommand).resolves({});
    const res = await deleteVeiculo.handler({ ...baseEvent, pathParameters: { id: '1' } });
    expect(res.statusCode).toBe(200);
  });
});
