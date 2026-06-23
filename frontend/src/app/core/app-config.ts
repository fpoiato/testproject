import { Injectable } from '@angular/core';

export interface AppConfig {
  environment: string;
  apiUrl: string;
  region: string;
  userPoolId: string;
  userPoolClientId: string;
}

@Injectable({ providedIn: 'root' })
export class ConfigService {
  private config: AppConfig = {
    environment: 'development',
    apiUrl: '',
    region: 'us-east-1',
    userPoolId: '',
    userPoolClientId: '',
  };

  set(config: AppConfig) {
    this.config = config;
  }

  get(): AppConfig {
    return this.config;
  }

  get apiUrl(): string {
    return this.config.apiUrl;
  }

  get environment(): string {
    return this.config.environment;
  }
}
