# TASK-012 Implementation Status

> ⚠️ **DEPRECATED — documento histórico.** Descreve a implementação via CDK (modelo híbrido), substituída pela consolidação em Terraform (stack único multi-ambiente). Mantido apenas como registro. Fonte da verdade atual: [`infra/terraform/README.md`](../../infra/terraform/README.md) e [ADR-003](adr-003-terraform-shared-model.md).

**Status:** 🔄 **PENDING DEPLOYMENT** (已完成代码, 待部署后真正改善)

## Branch
`feature/ISSUE-012-lambda-cdk` (已于 GitHub 使用 `gh issue develop` 从 Issue #12 标准创建, 为正确链接)

## 新建/修改文件

```
cdk/
  ├─ bootstrap.sh                          (新建 - 引用 Terraform outputs 到 .env 并调用 cdk bootstrap)
  ├─ sam-app-cdk/                         (新建 - CDK Application Stack)
  │   ├─ bin/sam-app.ts                  (新建 - CDK App 入口, 支持读取环境变量)
  │   ├─ lib/sam-app-stack.ts            (新建 - 导入 Terraform 资源并创建 Lambda + API 集成)
  │   ├─ package.json, tsconfig.json, cdk.json (CDK 配置与类型定义, TS 配置)
  │   └─ package-lock.json                (依赖锁定)
  └─ lambda/                               (新建 - 5 Lambda 函数目录)
      ├─ get-veiculos/index.js + package.json
      ├─ create-veiculo/index.js + package.json
      ├─ get-veiculo/index.js + package.json
      ├─ update-veiculo/index.js + package.json
      └─ delete-veiculo/index.js + package.json
```

## 集成关系（依据 ADR-002）

**Terraform (核心基础设施):**
- API Gateway REST API (`api_gateway_rest_api_id`)
- Stages (`dev`, `test`, `staging`, `production-blue`, `production-green`)
- DynamoDB Table `Veiculos` (`dynamodb_veiculos_table_name`)
- Cognito User Pool (`cognito_user_pool_id`, `cognito_user_pool_arn`)
- CloudFront ∈ клиент存放目录

**CDK (应用代码 + API 集成, 本次 TASK):**
- 导入 API Gateway (`RestApi.fromRestApiId()`)
导入 DynamoDB Table (`Table.fromTableName()`)
导入 Cognito User Pool (`UserPool.fromUserPoolId()`)

- 创建 Cognito JWT Authorizer (CognitoUserPoolsAuthorizer) → 用于所有路由必需鉴权
- 创建 5 Lambda Function (NODEJS_20_X Runtime):
  - get-veiculos (List)
  - create-veiculo (Create)
  - get-veiculo (Get by placa)
  - update-veiculo (Update)
  - delete-veiculo (Delete)

- 创建 API Gateway 资源与方法 (秒组):
  /veiculos (GET, POST) → 集成 Lambda Integrations
  /veiculos/{placa} (GET, PUT, DELETE) → 集成 Lambda Integrations
- 所有方法设置 Cognito Authorizer (鉴必需)

## 待完成部署步骤

1. 切换到 development 分支(已存在), 执行:
   cd infra/terraform
   terraform init
   terraform apply -var-file=dev.tfvars  ——必须完成 以导出 Outputs

2. 执行 CDK bootstrap 脚本, 从 Terraform outputs 注入 .env:
   cd ../../
   chmod +x cdk/bootstrap.sh
   ./cdk/bootstrap.sh

3. CDK 部署(一口):
   cd cdk/sam-app-cdk
   npm install (已有)
   npm run build
   npx cdk synth
   npx cdk deploy

## 验证验收

- VPC/从数量 验证: Lambda 函数 5 个已创建?
- API Gateway resource/method/integration 验证: 已有对应路由?
- Authorizer 验证: Cognito JWT Authorizer 已挂于所有方法?
- CORS/Response 格式: Access-Control-Allow-Origin: *; 标准化 JSON 提供
- 功能验证: 使用 Cognito Token 测试 CRUD Get/Post/Put/Delete

## 说明

本 TASK 严格执行 ADR-002 的架构决策。
- 所有 Terraform 资源保持不可变和稳定
- CDK 负责并行/增量代码部署更新
- 两者均免费开源 (Apache 2.0 许可)
- Lambda function 代码 (Node.js 20.x runtime) 存在 cdk/lambda 中
- 环境变量来自 Terraform `.env` 导出/读取, 经过 GitHub 授权保证同步

注意: 本次分支仅包含代码(未执行部署)。需要执行 bootstrap.sh 与 cdk deploy 才真正创建资源并替换 TASK-011 头的 mock integrations。
