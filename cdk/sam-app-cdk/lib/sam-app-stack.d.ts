import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
export interface SamAppStackProps extends cdk.StackProps {
    apiGatewayId: string;
    apiGatewayRootResourceId: string;
    dynamoDbTableName: string;
    cognitoUserPoolId: string;
    cognitoUserPoolArn: string;
    stageName: string;
}
export declare class SamAppStack extends cdk.Stack {
    constructor(scope: Construct, id: string, props: SamAppStackProps);
    private createLambdaFunction;
}
