# terraform-workshop
example lambda with terraform

setup dotnet source
1 git clone <br />
2 cd to first-lambda/myProject/src/aws-lambda-function
3 run command dotnet publish -c Release

setup terraform

1 cd first-lambda/terraform
2 edit config provider in main.tf
3 run command terraform init
4 run command terraform plan
5 run terraform apply
