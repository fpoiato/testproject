// Helpers de resposta HTTP para integracao Lambda proxy (AWS_PROXY).

const ALLOWED_ORIGINS = (process.env.CORS_ALLOWED_ORIGINS || '*')
  .split(',')
  .map((o) => o.trim())
  .filter(Boolean);

function corsHeaders(event) {
  const requestOrigin =
    event && event.headers
      ? event.headers.origin || event.headers.Origin
      : undefined;

  let allowOrigin = '*';
  if (!ALLOWED_ORIGINS.includes('*')) {
    allowOrigin =
      requestOrigin && ALLOWED_ORIGINS.includes(requestOrigin)
        ? requestOrigin
        : ALLOWED_ORIGINS[0];
  }

  return {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': allowOrigin,
    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
  };
}

function ok(event, statusCode, payload) {
  return {
    statusCode,
    headers: corsHeaders(event),
    body: JSON.stringify(payload),
  };
}

function error(event, statusCode, message, details) {
  return ok(event, statusCode, {
    success: false,
    error: message,
    ...(details ? { details } : {}),
  });
}

function parseBody(event) {
  if (!event || !event.body) return {};
  try {
    return typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
  } catch (e) {
    const err = new Error('Corpo da requisicao nao e um JSON valido');
    err.statusCode = 400;
    throw err;
  }
}

module.exports = { corsHeaders, ok, error, parseBody };
