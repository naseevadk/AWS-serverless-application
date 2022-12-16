version = 0.1
[default]
[default.deploy]
[default.deploy.parameters]
stack_name = "Order-App"
s3_bucket = "aws-sam-cli-managed-default-samclisourcebucket-loz3ulcaxtv5"
s3_prefix = "Order-App"
region = "us-east-2"
confirm_changeset = true
capabilities = "CAPABILITY_IAM"
disable_rollback = true
image_repositories = []
