import { Amplify } from 'aws-amplify';
import { ConfigService, AppConfig } from './app-config';
import { I18nService } from './i18n.service';

// Carrega public/config.json e traducoes; configura Amplify (Cognito) por ambiente.
export function initAppFactory(configService: ConfigService, i18n: I18nService) {
  return async () => {
    await i18n.init();

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
