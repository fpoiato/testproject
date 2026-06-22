export type EnvironmentName = 'development' | 'test' | 'staging' | 'production';

export interface EnvironmentConfig {
  envName: EnvironmentName;
  /** AWS account ID placeholder — set per deployment target */
  account: string;
  /** AWS region placeholder — set per deployment target */
  region: string;
}

/**
 * Base configuration for each stage/environment.
 * All environments share the same AWS account; resources are segregated by stage.
 */
export const ENVIRONMENTS: Record<EnvironmentName, EnvironmentConfig> = {
  development: {
    envName: 'development',
    account: process.env.CDK_DEFAULT_ACCOUNT ?? '123456789012',
    region: process.env.CDK_DEFAULT_REGION ?? 'us-east-1',
  },
  test: {
    envName: 'test',
    account: process.env.CDK_DEFAULT_ACCOUNT ?? '123456789012',
    region: process.env.CDK_DEFAULT_REGION ?? 'us-east-1',
  },
  staging: {
    envName: 'staging',
    account: process.env.CDK_DEFAULT_ACCOUNT ?? '123456789012',
    region: process.env.CDK_DEFAULT_REGION ?? 'us-east-1',
  },
  production: {
    envName: 'production',
    account: process.env.CDK_DEFAULT_ACCOUNT ?? '123456789012',
    region: process.env.CDK_DEFAULT_REGION ?? 'us-east-1',
  },
};

export function getEnvironmentConfig(envName: string): EnvironmentConfig {
  if (!(envName in ENVIRONMENTS)) {
    throw new Error(
      `Invalid environment "${envName}". Valid values: ${Object.keys(ENVIRONMENTS).join(', ')}`,
    );
  }
  return ENVIRONMENTS[envName as EnvironmentName];
}
