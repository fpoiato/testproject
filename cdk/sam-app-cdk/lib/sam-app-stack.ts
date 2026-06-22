import * as cdk from 'aws-cdk-lib';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';
import * as dynamodb from 'aws-cdk-lib/aws-dynamodb';
import * as cognito from 'aws-cdk-lib/aws-cognito';
import * as iam from 'aws-cdk-lib/aws-iam';
import { Construct } from 'constructs';

export interface SamAppStackProps extends cdk.StackProps {
  apiGatewayId: string;
  dynamoDbTableName: string;
  cognitoUserPoolId: string;
  cognitoUserPoolArn: string;
}

export class SamAppStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: SamAppStackProps) {
    super(scope, id, props);

    // Import API Gateway from Terraform
    const apiGateway = apigateway.RestApi.fromRestApiId(this, 'ImportedApiGateway', props.apiGatewayId);

    // Import DynamoDB table from Terraform
    const dynamoTable = dynamodb.Table.fromTableName(this, 'ImportedDynamoTable', props.dynamoDbTableName);

    // Import Cognito User Pool from Terraform
    const cognitoUserPool = cognito.UserPool.fromUserPoolId(this, 'ImportedCognitoUserPool', props.cognitoUserPoolId);
    const cognitoUserPoolArn = props.cognitoUserPoolArn;

    // Create Cognito JWT Authorizer
    const cognitoAuthorizer = new apigateway.CognitoUserPoolsAuthorizer(this, 'CognitoAuthorizer', {
      cognitoUserPools: [cognitoUserPool],
      identitySource: 'Authorization',
    });

    // ========================================
    // Lambda Functions for Veiculos
    // ========================================

    // 1. Get Veiculos (List all vehicles)
    const getVeiculosFn = this.createLambdaFunction('GetVeiculos', 'get-veiculos', dynamoTable, ['dynamodb:Scan', 'dynamodb:Query']);
    const getVeiculosIntegration = new apigateway.LambdaIntegration(getVeiculosFn, {
      proxy: true,
    });

    // 2. Create Veiculo (Create single vehicle)
    const createVeiculoFn = this.createLambdaFunction('CreateVeiculo', 'create-veiculo', dynamoTable, ['dynamodb:PutItem']);
    const createVeiculoIntegration = new apigateway.LambdaIntegration(createVeiculoFn, {
      proxy: true,
    });

    // 3. Get Veiculo by Placa (Get single vehicle)
    const getVeiculoFn = this.createLambdaFunction('GetVeiculo', 'get-veiculo', dynamoTable, ['dynamodb:GetItem']);
    const getVeiculoIntegration = new apigateway.LambdaIntegration(getVeiculoFn, {
      proxy: true,
    });

    // 4. Update Veiculo (Update vehicle)
    const updateVeiculoFn = this.createLambdaFunction('UpdateVeiculo', 'update-veiculo', dynamoTable, ['dynamodb:UpdateItem']);
    const updateVeiculoIntegration = new apigateway.LambdaIntegration(updateVeiculoFn, {
      proxy: true,
    });

    // 5. Delete Veiculo (Delete vehicle)
    const deleteVeiculoFn = this.createLambdaFunction('DeleteVeiculo', 'delete-veiculo', dynamoTable, ['dynamodb:DeleteItem']);
    const deleteVeiculoIntegration = new apigateway.LambdaIntegration(deleteVeiculoFn, {
      proxy: true,
    });

    // ========================================
    // API Gateway Resources and Methods
    // ========================================

    // Root resource
    const root = apiGateway.root;

    // /veiculos resource
    const veiculosResource = root.addResource('veiculos');

    // GET /veiculos
    veiculosResource.addMethod('GET', getVeiculosIntegration, {
      authorizationType: apigateway.AuthorizationType.COGNITO,
      authorizer: cognitoAuthorizer,
    });

    // POST /veiculos
    veiculosResource.addMethod('POST', createVeiculoIntegration, {
      authorizationType: apigateway.AuthorizationType.COGNITO,
      authorizer: cognitoAuthorizer,
    });

    // /veiculos/{placa} resource
    const veiculosPlacaResource = veiculosResource.addResource('{placa}');

    // GET /veiculos/{placa}
    veiculosPlacaResource.addMethod('GET', getVeiculoIntegration, {
      authorizationType: apigateway.AuthorizationType.COGNITO,
      authorizer: cognitoAuthorizer,
    });

    // PUT /veiculos/{placa}
    veiculosPlacaResource.addMethod('PUT', updateVeiculoIntegration, {
      authorizationType: apigateway.AuthorizationType.COGNITO,
      authorizer: cognitoAuthorizer,
    });

    // DELETE /veiculos/{placa}
    veiculosPlacaResource.addMethod('DELETE', deleteVeiculoIntegration, {
      authorizationType: apigateway.AuthorizationType.COGNITO,
      authorizer: cognitoAuthorizer,
    });
  }

  private createLambdaFunction(
    name: string,
    codeDir: string,
    dynamoTable: dynamodb.ITable,
    dynamoActions: string[]
  ): lambda.Function {
    const fn = new lambda.Function(this, `${name}Function`, {
      functionName: `testproject-${name}-${this.node.tryGetContext('environment') ?? 'dev'}`,
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: 'index.handler',
      code: lambda.Code.fromAsset(`../../lambda/${codeDir}`),
      environment: {
        DYNAMODB_TABLE: dynamoTable.tableName,
        ENVIRONMENT: this.node.tryGetContext('environment') ?? 'dev',
      },
      timeout: cdk.Duration.seconds(30),
      memorySize: 256,
    });

    // Grant DynamoDB access
    fn.addToRolePolicy(new iam.PolicyStatement({
      effect: iam.Effect.ALLOW,
      actions: dynamoActions,
      resources: [dynamoTable.tableArn],
    }));

    // Grant CloudWatch Logs access (default)
    fn.addToRolePolicy(new iam.PolicyStatement({
      effect: iam.Effect.ALLOW,
      actions: [
        'logs:CreateLogGroup',
        'logs:CreateLogStream',
        'logs:PutLogEvents',
      ],
      resources: ['arn:aws:logs:*:*:*'],
    }));

    return fn;
  }
}
