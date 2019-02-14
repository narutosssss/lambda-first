# aws-lambda-function

Example C# though .Net Core 2 working with AWS Lambda Function, Passing value by PathParameters via APIGatewayEvents Lib

## This code to show about

- Simple code to explain about lambda
- Passing value by PathParameters via APIGatewayEvents Lib
- Dependency Injection
- Unit Test

## If you integrate with API Gateway

1. go to Integration Request > check box "Use Lambda Proxy integration"

## Test and Deploy with AWS CLI

**Try to Run and Get result**
```
$ cd src/aws-lambda-function
$ aws lambda invoke --function-name {LAMBDA_FUNCTION_NAME} output.txt
```

**Deploy**
```
$ cd src/aws-lambda-function
$ dotnet lambda deploy-function {LAMBDA_FUNCTION_NAME} –-function-role {ROLE_NAME}
```