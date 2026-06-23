const { CognitoJwtVerifier } = require('aws-jwt-verify');

// STAGE_POOL_MAP: JSON { "<stage>": { "userPoolId": "...", "clientId": "..." }, ... }
// Cada stage do API Gateway valida o JWT contra o user pool do seu ambiente,
// garantindo isolamento por ambiente mesmo com um unico API Gateway.
const stageMap = JSON.parse(process.env.STAGE_POOL_MAP || '{}');

const verifiers = {};
for (const [stage, cfg] of Object.entries(stageMap)) {
  verifiers[stage] = CognitoJwtVerifier.create({
    userPoolId: cfg.userPoolId,
    tokenUse: 'id',
    clientId: cfg.clientId,
  });
}

function policy(principalId, effect, resource, context) {
  return {
    principalId,
    policyDocument: {
      Version: '2012-10-17',
      Statement: [
        { Action: 'execute-api:Invoke', Effect: effect, Resource: resource },
      ],
    },
    context: context || {},
  };
}

exports.handler = async (event) => {
  const methodArn = event.methodArn || '';
  // arn:aws:execute-api:region:acct:apiId/stage/VERB/resource
  const parts = methodArn.split('/');
  const stage = parts[1];
  const apiGatewayArn = parts.slice(0, 2).join('/'); // arn.../apiId/stage
  const allowResource = `${apiGatewayArn}/*/*`;

  const verifier = verifiers[stage];
  const raw = event.authorizationToken || '';
  const token = raw.replace(/^Bearer\s+/i, '').trim();

  if (!verifier || !token) {
    throw new Error('Unauthorized');
  }

  try {
    const payload = await verifier.verify(token);
    return policy(payload.sub, 'Allow', allowResource, {
      email: payload.email || '',
      stage,
    });
  } catch (err) {
    console.error('Authorization failed for stage', stage, err.message);
    throw new Error('Unauthorized');
  }
};
