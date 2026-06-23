"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SamAppStack = void 0;
const cdk = require("aws-cdk-lib");
const lambda = require("aws-cdk-lib/aws-lambda");
const apigateway = require("aws-cdk-lib/aws-apigateway");
const dynamodb = require("aws-cdk-lib/aws-dynamodb");
const cognito = require("aws-cdk-lib/aws-cognito");
const iam = require("aws-cdk-lib/aws-iam");
class SamAppStack extends cdk.Stack {
    constructor(scope, id, props) {
        super(scope, id, props);
        // Import API Gateway from Terraform (root resource id is required so we
        // can attach resources/methods to the imported REST API).
        const apiGateway = apigateway.RestApi.fromRestApiAttributes(this, 'ImportedApiGateway', {
            restApiId: props.apiGatewayId,
            rootResourceId: props.apiGatewayRootResourceId,
        });
        // Import DynamoDB table from Terraform
        const dynamoTable = dynamodb.Table.fromTableName(this, 'ImportedDynamoTable', props.dynamoDbTableName);
        // Import Cognito User Pool from Terraform
        const cognitoUserPool = cognito.UserPool.fromUserPoolId(this, 'ImportedCognitoUserPool', props.cognitoUserPoolId);
        const cognitoUserPoolArn = props.cognitoUserPoolArn;
        // Create Cognito JWT Authorizer
        const cognitoAuthorizer = new apigateway.CognitoUserPoolsAuthorizer(this, 'CognitoAuthorizer', {
            cognitoUserPools: [cognitoUserPool],
            identitySource: apigateway.IdentitySource.header('Authorization'),
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
        const getVeiculosMethod = veiculosResource.addMethod('GET', getVeiculosIntegration, {
            authorizationType: apigateway.AuthorizationType.COGNITO,
            authorizer: cognitoAuthorizer,
        });
        // POST /veiculos
        const createVeiculoMethod = veiculosResource.addMethod('POST', createVeiculoIntegration, {
            authorizationType: apigateway.AuthorizationType.COGNITO,
            authorizer: cognitoAuthorizer,
        });
        // /veiculos/{placa} resource
        const veiculosPlacaResource = veiculosResource.addResource('{placa}');
        // GET /veiculos/{placa}
        const getVeiculoMethod = veiculosPlacaResource.addMethod('GET', getVeiculoIntegration, {
            authorizationType: apigateway.AuthorizationType.COGNITO,
            authorizer: cognitoAuthorizer,
        });
        // PUT /veiculos/{placa}
        const updateVeiculoMethod = veiculosPlacaResource.addMethod('PUT', updateVeiculoIntegration, {
            authorizationType: apigateway.AuthorizationType.COGNITO,
            authorizer: cognitoAuthorizer,
        });
        // DELETE /veiculos/{placa}
        const deleteVeiculoMethod = veiculosPlacaResource.addMethod('DELETE', deleteVeiculoIntegration, {
            authorizationType: apigateway.AuthorizationType.COGNITO,
            authorizer: cognitoAuthorizer,
        });
        // ========================================
        // Deployment + Stage
        // ========================================
        // The base REST API is created by Terraform without any methods, so we
        // create the deployment/stage here (after the methods exist) to make the
        // API invokable.
        const methods = [
            getVeiculosMethod,
            createVeiculoMethod,
            getVeiculoMethod,
            updateVeiculoMethod,
            deleteVeiculoMethod,
        ];
        const deployment = new apigateway.Deployment(this, 'Deployment', {
            api: apiGateway,
        });
        // Force a new deployment whenever the set of methods changes, and ensure
        // the deployment is created only after every method.
        deployment.addToLogicalId(methods.map((m) => m.methodId).join(','));
        methods.forEach((m) => deployment.node.addDependency(m));
        const stage = new apigateway.Stage(this, 'Stage', {
            deployment,
            stageName: props.stageName,
        });
        new cdk.CfnOutput(this, 'ApiInvokeUrl', {
            value: stage.urlForPath('/veiculos'),
            description: 'Invoke URL for GET/POST /veiculos',
        });
    }
    createLambdaFunction(name, codeDir, dynamoTable, dynamoActions) {
        const fn = new lambda.Function(this, `${name}Function`, {
            functionName: `testproject-${name}-${this.node.tryGetContext('environment') ?? 'dev'}`,
            runtime: lambda.Runtime.NODEJS_20_X,
            handler: 'index.handler',
            code: lambda.Code.fromAsset(`../lambda/${codeDir}`),
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
exports.SamAppStack = SamAppStack;
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoic2FtLWFwcC1zdGFjay5qcyIsInNvdXJjZVJvb3QiOiIiLCJzb3VyY2VzIjpbInNhbS1hcHAtc3RhY2sudHMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7O0FBQUEsbUNBQW1DO0FBQ25DLGlEQUFpRDtBQUNqRCx5REFBeUQ7QUFDekQscURBQXFEO0FBQ3JELG1EQUFtRDtBQUNuRCwyQ0FBMkM7QUFZM0MsTUFBYSxXQUFZLFNBQVEsR0FBRyxDQUFDLEtBQUs7SUFDeEMsWUFBWSxLQUFnQixFQUFFLEVBQVUsRUFBRSxLQUF1QjtRQUMvRCxLQUFLLENBQUMsS0FBSyxFQUFFLEVBQUUsRUFBRSxLQUFLLENBQUMsQ0FBQztRQUV4Qix3RUFBd0U7UUFDeEUsMERBQTBEO1FBQzFELE1BQU0sVUFBVSxHQUFHLFVBQVUsQ0FBQyxPQUFPLENBQUMscUJBQXFCLENBQUMsSUFBSSxFQUFFLG9CQUFvQixFQUFFO1lBQ3RGLFNBQVMsRUFBRSxLQUFLLENBQUMsWUFBWTtZQUM3QixjQUFjLEVBQUUsS0FBSyxDQUFDLHdCQUF3QjtTQUMvQyxDQUFDLENBQUM7UUFFSCx1Q0FBdUM7UUFDdkMsTUFBTSxXQUFXLEdBQUcsUUFBUSxDQUFDLEtBQUssQ0FBQyxhQUFhLENBQUMsSUFBSSxFQUFFLHFCQUFxQixFQUFFLEtBQUssQ0FBQyxpQkFBaUIsQ0FBQyxDQUFDO1FBRXZHLDBDQUEwQztRQUMxQyxNQUFNLGVBQWUsR0FBRyxPQUFPLENBQUMsUUFBUSxDQUFDLGNBQWMsQ0FBQyxJQUFJLEVBQUUseUJBQXlCLEVBQUUsS0FBSyxDQUFDLGlCQUFpQixDQUFDLENBQUM7UUFDbEgsTUFBTSxrQkFBa0IsR0FBRyxLQUFLLENBQUMsa0JBQWtCLENBQUM7UUFFcEQsZ0NBQWdDO1FBQ2hDLE1BQU0saUJBQWlCLEdBQUcsSUFBSSxVQUFVLENBQUMsMEJBQTBCLENBQUMsSUFBSSxFQUFFLG1CQUFtQixFQUFFO1lBQzdGLGdCQUFnQixFQUFFLENBQUMsZUFBZSxDQUFDO1lBQ25DLGNBQWMsRUFBRSxV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QUcsQ0FBQyxlQUFlLENBQUM7WUFDekMsTUFBTSxFQUFFLEdBQUcsQ0FBQyxNQUFNLENBQUMsS0FBSztZQUN4QixPQUFPLEVBQUUsYUFBYTtZQUN0QixTQUFTLEVBQUUsQ0FBQyxXQUFXLENBQUMsUUFBUSxDQUFDO1NBQ2xDLENBQUMsQ0FBQyxDQUFDO1FBRUoseUNBQXlDO1FBQ3pDLEVBQUUsQ0FBQyxlQUFlLENBQUMsSUFBSSxHQUFHLENBQUMsZUFBZSxDQUFDO1lBQ3pDLE1BQU0sRUFBRSxHQUFHLENBQUMsTUFBTSxDQUFDLEtBQUs7WUFDeEIsT0FBTyxFQUFFO2dCQUNQLHFCQUFxQjtnQkFDckIsc0JBQXNCO2dCQUN0QixtQkFBbUI7YUFDcEI7WUFDRCxTQUFTLEVBQUUsQ0FBQyxvQkFBb0IsQ0FBQztTQUNsQyxDQUFDLENBQUMsQ0FBQztRQUVKLE9BQU8sRUFBRSxDQUFDO0lBQ1osQ0FBQztDQUNGO0FBN0tELGtDQTZLQyIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCAqIGFzIGNkayBmcm9tICdhd3MtY2RrLWxpYic7XHJcbmltcG9ydCAqIGFzIGxhbWJkYSBmcm9tICdhd3MtY2RrLWxpYi9hd3MtbGFtYmRhJztcclxuaW1wb3J0ICogYXMgYXBpZ2F0ZXdheSBmcm9tICdhd3MtY2RrLWxpYi9hd3MtYXBpZ2F0ZXdheSc7XHJcbmltcG9ydCAqIGFzIGR5bmFtb2RiIGZyb20gJ2F3cy1jZGstbGliL2F3cy1keW5hbW9kYic7XHJcbmltcG9ydCAqIGFzIGNvZ25pdG8gZnJvbSAnYXdzLWNkay1saWIvYXdzLWNvZ25pdG8nO1xyXG5pbXBvcnQgKiBhcyBpYW0gZnJvbSAnYXdzLWNkay1saWIvYXdzLWlhbSc7XHJcbmltcG9ydCB7IENvbnN0cnVjdCB9IGZyb20gJ2NvbnN0cnVjdHMnO1xyXG5cclxuZXhwb3J0IGludGVyZmFjZSBTYW1BcHBTdGFja1Byb3BzIGV4dGVuZHMgY2RrLlN0YWNrUHJvcHMge1xyXG4gIGFwaUdhdGV3YXlJZDogc3RyaW5nO1xyXG4gIGFwaUdhdGV3YXlSb290UmVzb3VyY2VJZDogc3RyaW5nO1xyXG4gIGR5bmFtb0RiVGFibGVOYW1lOiBzdHJpbmc7XHJcbiAgY29nbml0b1VzZXJQb29sSWQ6IHN0cmluZztcclxuICBjb2duaXRvVXNlclBvb2xBcm46IHN0cmluZztcclxuICBzdGFnZU5hbWU6IHN0cmluZztcclxufVxyXG5cclxuZXhwb3J0IGNsYXNzIFNhbUFwcFN0YWNrIGV4dGVuZHMgY2RrLlN0YWNrIHtcclxuICBjb25zdHJ1Y3RvcihzY29wZTogQ29uc3RydWN0LCBpZDogc3RyaW5nLCBwcm9wczogU2FtQXBwU3RhY2tQcm9wcykge1xyXG4gICAgc3VwZXIoc2NvcGUsIGlkLCBwcm9wcyk7XHJcblxyXG4gICAgLy8gSW1wb3J0IEFQSSBHYXRld2F5IGZyb20gVGVycmFmb3JtIChyb290IHJlc291cmNlIGlkIGlzIHJlcXVpcmVkIHNvIHdlXHJcbiAgICAvLyBjYW4gYXR0YWNoIHJlc291cmNlcy9tZXRob2RzIHRvIHRoZSBpbXBvcnRlZCBSRVNUIEFQSSkuXHJcbiAgICBjb25zdCBhcGlHYXRld2F5ID0gYXBpZ2F0ZXdheS5SZXN0QXBpLmZyb21SZXN0QXBpQXR0cmlidXRlcyh0aGlzLCAnSW1wb3J0ZWRBcGlHYXRld2F5Jywge1xyXG4gICAgICByZXN0QXBpSWQ6IHByb3BzLmFwaUdhdGV3YXlJZCxcclxuICAgICAgcm9vdFJlc291cmNlSWQ6IHByb3BzLmFwaUdhdGV3YXlSb290UmVzb3VyY2VJZCxcclxuICAgIH0pO1xyXG5cclxuICAgIC8vIEltcG9ydCBEeW5hbW9EQiB0YWJsZSBmcm9tIFRlcnJhZm9ybVxyXG4gICAgY29uc3QgZHluYW1vVGFibGUgPSBkeW5hbW9kYi5UYWJsZS5mcm9tVGFibGVOYW1lKHRoaXMsICdJbXBvcnRlZER5bmFtb1RhYmxlJywgcHJvcHMuZHluYW1vRGJUYWJsZU5hbWUpO1xyXG5cclxuICAgIC8vIEltcG9ydCBDb2duaXRvIFVzZXIgUG9vbCBmcm9tIFRlcnJhZm9ybVxyXG4gICAgY29uc3QgY29nbml0b1VzZXJQb29sID0gY29nbml0by5Vc2VyUG9vbC5mcm9tVXNlclBvb2xJZCh0aGlzLCAnSW1wb3J0ZWRDb2duaXRvVXNlclBvb2wnLCBwcm9wcy5jb2duaXRvVXNlclBvb2xJZCk7XHJcbiAgICBjb25zdCBjb2duaXRvVXNlclBvb2xBcm4gPSBwcm9wcy5jb2duaXRvVXNlclBvb2xBcm47XHJcblxyXG4gICAgLy8gQ3JlYXRlIENvZ25pdG8gSldUIEF1dGhvcml6ZXJcclxuICAgIGNvbnN0IGNvZ25pdG9BdXRob3JpemVyID0gbmV3IGFwaWdhdGV3YXkuQ29nbml0b1VzZXJQb29sc0F1dGhvcml6ZXIodGhpcywgJ0NvZ25pdG9BdXRob3JpemVyJywge1xyXG4gICAgICBjb2duaXRvVXNlclBvb2xzOiBbY29nbml0b1VzZXJQb29sXSxcclxuICAgICAgaWRlbnRpdHlTb3VyY2U6IGFwaWdhdGV3YXkuSWRlbnRpdHlTb3VyY2UuaGVhZGVyKCdBdXRob3JpemF0aW9uJyksXHJcbiAgICB9KTtcclxuXHJcbiAgICAvLyA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09XHJcbiAgICAvLyBMYW1iZGEgRnVuY3Rpb25zIGZvciBWZWljdWxvc1xyXG4gICAgLy8gPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PVxyXG5cclxuICAgIC8vIDEuIEdldCBWZWljdWxvcyAoTGlzdCBhbGwgdmVoaWNsZXMpXHJcbiAgICBjb25zdCBnZXRWZWljdWxvc0ZuID0gdGhpcy5jcmVhdGVMYW1iZGFGdW5jdGlvbignR2V0VmVpY3Vsb3MnLCAnZ2V0LXZlaWN1bG9zJywgZHluYW1vVGFibGUsIFsnZHluYW1vZGI6U2NhbicsICdkeW5hbW9kYjpRdWVyeSddKTtcclxuICAgIGNvbnN0IGdldFZlaWN1bG9zSW50ZWdyYXRpb24gPSBuZXcgYXBpZ2F0ZXdheS5MYW1iZGFJbnRlZ3JhdGlvbihnZXRWZWljdWxvc0ZuLCB7XHJcbiAgICAgIHByb3h5OiB0cnVlLFxyXG4gICAgfSk7XHJcblxyXG4gICAgLy8gMi4gQ3JlYXRlIFZlaWN1bG8gKENyZWF0ZSBzaW5nbGUgdmVoaWNsZSlcclxuICAgIGNvbnN0IGNyZWF0ZVZlaWN1bG9GbiA9IHRoaXMuY3JlYXRlTGFtYmRhRnVuY3Rpb24oJ0NyZWF0ZVZlaWN1bG8nLCAnY3JlYXRlLXZlaWN1bG8nLCBkeW5hbW9UYWJsZSwgWydkeW5hbW9kYjpQdXRJdGVtJ10pO1xyXG4gICAgY29uc3QgY3JlYXRlVmVpY3Vsb0ludGVncmF0aW9uID0gbmV3IGFwaWdhdGV3YXkuTGFtYmRhSW50ZWdyYXRpb24oY3JlYXRlVmVpY3Vsb0ZuLCB7XHJcbiAgICAgIHByb3h5OiB0cnVlLFxyXG4gICAgfSk7XHJcblxyXG4gICAgLy8gMy4gR2V0IFZlaWN1bG8gYnkgUGxhY2EgKEdldCBzaW5nbGUgdmVoaWNsZSlcclxuICAgIGNvbnN0IGdldFZlaWN1bG9GbiA9IHRoaXMuY3JlYXRlTGFtYmRhRnVuY3Rpb24oJ0dldFZlaWN1bG8nLCAnZ2V0LXZlaWN1bG8nLCBkeW5hbW9UYWJsZSwgWydkeW5hbW9kYjpHZXRJdGVtJ10pO1xyXG4gICAgY29uc3QgZ2V0VmVpY3Vsb0ludGVncmF0aW9uID0gbmV3IGFwaWdhdGV3YXkuTGFtYmRhSW50ZWdyYXRpb24oZ2V0VmVpY3Vsb0ZuLCB7XHJcbiAgICAgIHByb3h5OiB0cnVlLFxyXG4gICAgfSk7XHJcblxyXG4gICAgLy8gNC4gVXBkYXRlIFZlaWN1bG8gKFVwZGF0ZSB2ZWhpY2xlKVxyXG4gICAgY29uc3QgdXBkYXRlVmVpY3Vsb0ZuID0gdGhpcy5jcmVhdGVMYW1iZGFGdW5jdGlvbignVXBkYXRlVmVpY3VsbycsICd1cGRhdGUtdmVpY3VsbycsIGR5bmFtb1RhYmxlLCBbJ2R5bmFtb2RiOlVwZGF0ZUl0ZW0nXSk7XHJcbiAgICBjb25zdCB1cGRhdGVWZWljdWxvSW50ZWdyYXRpb24gPSBuZXcgYXBpZ2F0ZXdheS5MYW1iZGFJbnRlZ3JhdGlvbih1cGRhdGVWZWljdWxvRm4sIHtcclxuICAgICAgcHJveHk6IHRydWUsXHJcbiAgICB9KTtcclxuXHJcbiAgICAvLyA1LiBEZWxldGUgVmVpY3VsbyAoRGVsZXRlIHZlaGljbGUpXHJcbiAgICBjb25zdCBkZWxldGVWZWljdWxvRm4gPSB0aGlzLmNyZWF0ZUxhbWJkYUZ1bmN0aW9uKCdEZWxldGVWZWljdWxvJywgJ2RlbGV0ZS12ZWljdWxvJywgZHluYW1vVGFibGUsIFsnZHluYW1vZGI6RGVsZXRlSXRlbSddKTtcclxuICAgIGNvbnN0IGRlbGV0ZVZlaWN1bG9JbnRlZ3JhdGlvbiA9IG5ldyBhcGlnYXRld2F5LkxhbWJkYUludGVncmF0aW9uKGRlbGV0ZVZlaWN1bG9Gbiwge1xyXG4gICAgICBwcm94eTogdHJ1ZSxcclxuICAgIH0pO1xyXG5cclxuICAgIC8vID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT1cclxuICAgIC8vIEFQSSBHYXRld2F5IFJlc291cmNlcyBhbmQgTWV0aG9kc1xyXG4gICAgLy8gPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PVxyXG5cclxuICAgIC8vIFJvb3QgcmVzb3VyY2VcclxuICAgIGNvbnN0IHJvb3QgPSBhcGlHYXRld2F5LnJvb3Q7XHJcblxyXG4gICAgLy8gL3ZlaWN1bG9zIHJlc291cmNlXHJcbiAgICBjb25zdCB2ZWljdWxvc1Jlc291cmNlID0gcm9vdC5hZGRSZXNvdXJjZSgndmVpY3Vsb3MnKTtcclxuXHJcbiAgICAvLyBHRVQgL3ZlaWN1bG9zXHJcbiAgICBjb25zdCBnZXRWZWljdWxvc01ldGhvZCA9IHZlaWN1bG9zUmVzb3VyY2UuYWRkTWV0aG9kKCdHRVQnLCBnZXRWZWljdWxvc0ludGVncmF0aW9uLCB7XHJcbiAgICAgIGF1dGhvcml6YXRpb25UeXBlOiBhcGlnYXRld2F5LkF1dGhvcml6YXRpb25UeXBlLkNPR05JVE8sXHJcbiAgICAgIGF1dGhvcml6ZXI6IGNvZ25pdG9BdXRob3JpemVyLFxyXG4gICAgfSk7XHJcblxyXG4gICAgLy8gUE9TVCAvdmVpY3Vsb3NcclxuICAgIGNvbnN0IGNyZWF0ZVZlaWN1bG9NZXRob2QgPSB2ZWljdWxvc1Jlc291cmNlLmFkZE1ldGhvZCgnUE9TVCcsIGNyZWF0ZVZlaWN1bG9JbnRlZ3JhdGlvbiwge1xyXG4gICAgICBhdXRob3JpemF0aW9uVHlwZTogYXBpZ2F0ZXdheS5BdXRob3JpemF0aW9uVHlwZS5DT0dOSVRPLFxyXG4gICAgICBhdXRob3JpemVyOiBjb2duaXRvQXV0aG9yaXplcixcclxuICAgIH0pO1xyXG5cclxuICAgIC8vIC92ZWljdWxvcy97cGxhY2F9IHJlc291cmNlXHJcbiAgICBjb25zdCB2ZWljdWxvc1BsYWNhUmVzb3VyY2UgPSB2ZWljdWxvc1Jlc291cmNlLmFkZFJlc291cmNlKCd7cGxhY2F9Jyk7XHJcblxyXG4gICAgLy8gR0VUIC92ZWljdWxvcy97cGxhY2F9XHJcbiAgICBjb25zdCBnZXRWZWljdWxvTWV0aG9kID0gdmVpY3Vsb3NQbGFjYVJlc291cmNlLmFkZE1ldGhvZCgnR0VUJywgZ2V0VmVpY3Vsb0ludGVncmF0aW9uLCB7XHJcbiAgICAgIGF1dGhvcml6YXRpb25UeXBlOiBhcGlnYXRld2F5LkF1dGhvcml6YXRpb25UeXBlLkNPR05JVE8sXHJcbiAgICAgIGF1dGhvcml6ZXI6IGNvZ25pdG9BdXRob3JpemVyLFxyXG4gICAgfSk7XHJcblxyXG4gICAgLy8gUFVUIC92ZWljdWxvcy97cGxhY2F9XHJcbiAgICBjb25zdCB1cGRhdGVWZWljdWxvTWV0aG9kID0gdmVpY3Vsb3NQbGFjYVJlc291cmNlLmFkZE1ldGhvZCgnUFVUJywgdXBkYXRlVmVpY3Vsb0ludGVncmF0aW9uLCB7XHJcbiAgICAgIGF1dGhvcml6YXRpb25UeXBlOiBhcGlnYXRld2F5LkF1dGhvcml6YXRpb25UeXBlLkNPR05JVE8sXHJcbiAgICAgIGF1dGhvcml6ZXI6IGNvZ25pdG9BdXRob3JpemVyLFxyXG4gICAgfSk7XHJcblxyXG4gICAgLy8gREVMRVRFIC92ZWljdWxvcy97cGxhY2F9XHJcbiAgICBjb25zdCBkZWxldGVWZWljdWxvTWV0aG9kID0gdmVpY3Vsb3NQbGFjYVJlc291cmNlLmFkZE1ldGhvZCgnREVMRVRFJywgZGVsZXRlVmVpY3Vsb0ludGVncmF0aW9uLCB7XHJcbiAgICAgIGF1dGhvcml6YXRpb25UeXBlOiBhcGlnYXRld2F5LkF1dGhvcml6YXRpb25UeXBlLkNPR05JVE8sXHJcbiAgICAgIGF1dGhvcml6ZXI6IGNvZ25pdG9BdXRob3JpemVyLFxyXG4gICAgfSk7XHJcblxyXG4gICAgLy8gPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PVxyXG4gICAgLy8gRGVwbG95bWVudCArIFN0YWdlXHJcbiAgICAvLyA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09XHJcbiAgICAvLyBUaGUgYmFzZSBSRVNUIEFQSSBpcyBjcmVhdGVkIGJ5IFRlcnJhZm9ybSB3aXRob3V0IGFueSBtZXRob2RzLCBzbyB3ZVxyXG4gICAgLy8gY3JlYXRlIHRoZSBkZXBsb3ltZW50L3N0YWdlIGhlcmUgKGFmdGVyIHRoZSBtZXRob2RzIGV4aXN0KSB0byBtYWtlIHRoZVxyXG4gICAgLy8gQVBJIGludm9rYWJsZS5cclxuICAgIGNvbnN0IG1ldGhvZHMgPSBbXHJcbiAgICAgIGdldFZlaWN1bG9zTWV0aG9kLFxyXG4gICAgICBjcmVhdGVWZWljdWxvTWV0aG9kLFxyXG4gICAgICBnZXRWZWljdWxvTWV0aG9kLFxyXG4gICAgICB1cGRhdGVWZWljdWxvTWV0aG9kLFxyXG4gICAgICBkZWxldGVWZWljdWxvTWV0aG9kLFxyXG4gICAgXTtcclxuXHJcbiAgICBjb25zdCBkZXBsb3ltZW50ID0gbmV3IGFwaWdhdGV3YXkuRGVwbG95bWVudCh0aGlzLCAnRGVwbG95bWVudCcsIHtcclxuICAgICAgYXBpOiBhcGlHYXRld2F5LFxyXG4gICAgfSk7XHJcbiAgICAvLyBGb3JjZSBhIG5ldyBkZXBsb3ltZW50IHdoZW5ldmVyIHRoZSBzZXQgb2YgbWV0aG9kcyBjaGFuZ2VzLCBhbmQgZW5zdXJlXHJcbiAgICAvLyB0aGUgZGVwbG95bWVudCBpcyBjcmVhdGVkIG9ubHkgYWZ0ZXIgZXZlcnkgbWV0aG9kLlxyXG4gICAgZGVwbG95bWVudC5hZGRUb0xvZ2ljYWxJZChtZXRob2RzLm1hcCgobSkgPT4gbS5tZXRob2RJZCkuam9pbignLCcpKTtcclxuICAgIG1ldGhvZHMuZm9yRWFjaCgobSkgPT4gZGVwbG95bWVudC5ub2RlLmFkZERlcGVuZGVuY3kobSkpO1xyXG5cclxuICAgIGNvbnN0IHN0YWdlID0gbmV3IGFwaWdhdGV3YXkuU3RhZ2UodGhpcywgJ1N0YWdlJywge1xyXG4gICAgICBkZXBsb3ltZW50LFxyXG4gICAgICBzdGFnZU5hbWU6IHByb3BzLnN0YWdlTmFtZSxcclxuICAgIH0pO1xyXG5cclxuICAgIG5ldyBjZGsuQ2ZuT3V0cHV0KHRoaXMsICdBcGlJbnZva2VVcmwnLCB7XHJcbiAgICAgIHZhbHVlOiBzdGFnZS51cmxGb3JQYXRoKCcvdmVpY3Vsb3MnKSxcclxuICAgICAgZGVzY3JpcHRpb246ICdJbnZva2UgVVJMIGZvciBHRVQvUE9TVCAvdmVpY3Vsb3MnLFxyXG4gICAgfSk7XHJcbiAgfVxyXG5cclxuICBwcml2YXRlIGNyZWF0ZUxhbWJkYUZ1bmN0aW9uKFxyXG4gICAgbmFtZTogc3RyaW5nLFxyXG4gICAgY29kZURpcjogc3RyaW5nLFxyXG4gICAgZHluYW1vVGFibGU6IGR5bmFtb2RiLklUYWJsZSxcclxuICAgIGR5bmFtb0FjdGlvbnM6IHN0cmluZ1tdXHJcbiAgKTogbGFtYmRhLkZ1bmN0aW9uIHtcclxuICAgIGNvbnN0IGZuID0gbmV3IGxhbWJkYS5GdW5jdGlvbih0aGlzLCBgJHtuYW1lfUZ1bmN0aW9uYCwge1xyXG4gICAgICBmdW5jdGlvbk5hbWU6IGB0ZXN0cHJvamVjdC0ke25hbWV9LSR7dGhpcy5ub2RlLnRyeUdldENvbnRleHQoJ2Vudmlyb25tZW50JykgPz8gJ2Rldid9YCxcclxuICAgICAgcnVudGltZTogbGFtYmRhLlJ1bnRpbWUuTk9ERUpTXzIwX1gsXHJcbiAgICAgIGhhbmRsZXI6ICdpbmRleC5oYW5kbGVyJyxcclxuICAgICAgY29kZTogbGFtYmRhLkNvZGUuZnJvbUFzc2V0KGAuLi9sYW1iZGEvJHtjb2RlRGlyfWApLFxyXG4gICAgICBlbnZpcm9ubWVudDoge1xyXG4gICAgICAgIERZTkFNT0RCX1RBQkxFOiBkeW5hbW9UYWJsZS50YWJsZU5hbWUsXHJcbiAgICAgICAgRU5WSVJPTk1FTlQ6IHRoaXMubm9kZS50cnlHZXRDb250ZXh0KCdlbnZpcm9ubWVudCcpID8/ICdkZXYnLFxyXG4gICAgICB9LFxyXG4gICAgICB0aW1lb3V0OiBjZGsuRHVyYXRpb24uc2Vjb25kcygzMCksXHJcbiAgICAgIG1lbW9yeVNpemU6IDI1NixcclxuICAgIH0pO1xyXG5cclxuICAgIC8vIEdyYW50IER5bmFtb0RCIGFjY2Vzc1xyXG4gICAgZm4uYWRkVG9Sb2xlUG9saWN5KG5ldyBpYW0uUG9saWN5U3RhdGVtZW50KHtcclxuICAgICAgZWZmZWN0OiBpYW0uRWZmZWN0LkFMTE9XLFxyXG4gICAgICBhY3Rpb25zOiBkeW5hbW9BY3Rpb25zLFxyXG4gICAgICByZXNvdXJjZXM6IFtkeW5hbW9UYWJsZS50YWJsZUFybl0sXHJcbiAgICB9KSk7XHJcblxyXG4gICAgLy8gR3JhbnQgQ2xvdWRXYXRjaCBMb2dzIGFjY2VzcyAoZGVmYXVsdClcclxuICAgIGZuLmFkZFRvUm9sZVBvbGljeShuZXcgaWFtLlBvbGljeVN0YXRlbWVudCh7XHJcbiAgICAgIGVmZmVjdDogaWFtLkVmZmVjdC5BTExPVyxcclxuICAgICAgYWN0aW9uczogW1xyXG4gICAgICAgICdsb2dzOkNyZWF0ZUxvZ0dyb3VwJyxcclxuICAgICAgICAnbG9nczpDcmVhdGVMb2dTdHJlYW0nLFxyXG4gICAgICAgICdsb2dzOlB1dExvZ0V2ZW50cycsXHJcbiAgICAgIF0sXHJcbiAgICAgIHJlc291cmNlczogWydhcm46YXdzOmxvZ3M6KjoqOionXSxcclxuICAgIH0pKTtcclxuXHJcbiAgICByZXR1cm4gZm47XHJcbiAgfVxyXG59XHJcbiJdfQ==