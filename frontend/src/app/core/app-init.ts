import { Amplify } from 'aws-amplify';
import { ConfigService, AppConfig } from './app-config';

// Carrega public/config.json em runtime e configura o Amplify (Cognito) com os
// valores do ambiente. Permite o mesmo bundle ser servido com config por ambiente.
export function initAppFactory(configService: ConfigService) {
  return async () => {
    try {
      const res = await fetch('config.json', { cache: 'no-store' });
      const config = (await res.json()) as AppConfig;
      configService.set(config);

      if (config.userPoolId && config.userPoolClientId) {
        Amplify.configure({
          Auth: {
            Cognito: {
              userPoolId: config.userPoolId,
              userPoolClientId: config.userPoolClientId,
            },
          },
        });
      }
    } catch (e) {
      console.error('Falha ao carregar config.json', e);
    }
  };
}
