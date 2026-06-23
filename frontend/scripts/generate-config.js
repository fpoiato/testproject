// Gera public/config.json a partir de variaveis de ambiente (injetadas pelo
// CodeBuild via ENVIRONMENT e pelas saidas do Terraform). Em build local,
// usa defaults apontando para o ambiente de development.
const fs = require('fs');
const path = require('path');

const config = {
  environment: process.env.ENVIRONMENT || 'development',
  apiUrl: process.env.API_URL || '',
  region: process.env.AWS_REGION || process.env.COGNITO_REGION || 'us-east-1',
  userPoolId: process.env.COGNITO_USER_POOL_ID || '',
  userPoolClientId: process.env.COGNITO_CLIENT_ID || '',
};

const outDir = path.join(__dirname, '..', 'public');
fs.mkdirSync(outDir, { recursive: true });
fs.writeFileSync(
  path.join(outDir, 'config.json'),
  JSON.stringify(config, null, 2) + '\n'
);

console.log('config.json gerado para o ambiente:', config.environment);
console.log(JSON.stringify({ ...config }, null, 2));
