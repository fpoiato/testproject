#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { SamAppStack } from '../lib/sam-app-stack';
import * as dotenv from 'dotenv';

// Load environment variables from Terraform outputs
dotenv.config({ path: '../../.env' });

const app = new cdk.App();

const environment = app.node.tryGetContext('environment') ?? process.env.ENVIRONMENT ?? 'development';

// Import Terraform outputs via environment variables
const apiGatewayId = process.env.API_GATEWAY_ID ?? '';
const apiGatewayRootResourceId = process.env.API_GATEWAY_ROOT_RESOURCE_ID ?? '';
const dynamoDbTableName = process.env.DYNAMODB_TABLE_NAME ?? '';
const cognitoUserPoolId = process.env.COGNITO_USER_POOL_ID ?? '';
const cognitoUserPoolArn = process.env.COGNITO_USER_POOL_ARN ?? '';

new SamAppStack(app, 'SamAppStack', {
  env: {
    region: process.env.AWS_REGION ?? 'us-east-1',
    account: process.env.AWS_ACCOUNT_ID ?? '123456789012',
  },
  description: `SamApp Lambda Stack for ${environment} environment`,
  tags: {
    Project: 'testproject',
    Environment: environment,
    Component: 'Lambda',
  },
  // Pass Terraform outputs as properties
  apiGatewayId,
  apiGatewayRootResourceId,
  dynamoDbTableName,
  cognitoUserPoolId,
  cognitoUserPoolArn,
  stageName: environment,
});
