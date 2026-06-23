// Modelo de dados do veiculo: placa, marca, modelo, versao, cor, ano.
const CURRENT_YEAR = new Date().getFullYear();
const MIN_YEAR = 1900;
const MAX_YEAR = CURRENT_YEAR + 2;

const REQUIRED_STRING_FIELDS = ['placa', 'marca', 'modelo', 'cor'];

function validate(body, { partial = false } = {}) {
  const errors = [];

  if (!partial) {
    for (const field of REQUIRED_STRING_FIELDS) {
      if (!body[field] || String(body[field]).trim() === '') {
        errors.push(`Campo obrigatorio ausente ou vazio: ${field}`);
      }
    }
    if (body.ano === undefined || body.ano === null || body.ano === '') {
      errors.push('Campo obrigatorio ausente: ano');
    }
  }

  if (body.ano !== undefined && body.ano !== null && body.ano !== '') {
    const ano = Number(body.ano);
    if (!Number.isInteger(ano) || ano < MIN_YEAR || ano > MAX_YEAR) {
      errors.push(`ano deve ser um inteiro entre ${MIN_YEAR} e ${MAX_YEAR}`);
    }
  }

  for (const field of ['placa', 'marca', 'modelo', 'cor', 'versao']) {
    if (body[field] !== undefined && typeof body[field] !== 'string') {
      errors.push(`${field} deve ser texto`);
    }
  }

  return errors;
}

// Normaliza o payload mantendo apenas os campos do dominio.
function normalize(body) {
  const out = {};
  if (body.placa !== undefined) out.placa = String(body.placa).trim().toUpperCase();
  for (const field of ['marca', 'modelo', 'versao', 'cor']) {
    if (body[field] !== undefined) out[field] = String(body[field]).trim();
  }
  if (body.ano !== undefined && body.ano !== null && body.ano !== '') {
    out.ano = Number(body.ano);
  }
  return out;
}

module.exports = { validate, normalize, MIN_YEAR, MAX_YEAR };
