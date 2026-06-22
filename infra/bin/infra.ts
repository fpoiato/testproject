#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib/core';
import { getEnvironmentConfig } from '../lib/config';
import { InfraStack } from '../lib/infra-stack';

const app = new cdk.App();

const environment = app.node.tryGetContext('environment') ?? 'development';
const config = getEnvironmentConfig(environment);

new InfraStack(app, `InfraStack-${config.envName}`, {
  env: {
    account: config.account,
    region: config.region,
  },
  description: `Infrastructure stack for ${config.envName} environment`,
  tags: {
    Environment: config.envName,
    Project: 'testproject',
  },
});
