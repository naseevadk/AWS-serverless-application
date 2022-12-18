Initalize Project
Before we start to create the SAM project, let's first install jq (a lightweight and flexible command line JSON processor) to help us parse json outputs in order to export AWS Region (i.e. us-west-2 ) and Project name (i.e. order-app) as environment variables.

Copy the below commands into terminal.

sudo yum install -y jq

export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile
echo "export ORDER_APP=order-app" | tee -a ~/.bash_profile
source ~/.bash_profile

Run the following command to scaffold a new project. The command will clone from the hello-world sample SAM template app, and create order-app project folder under the current path.

cd ~/environment

sam init \
    --name $ORDER_APP \
    --runtime nodejs14.x  \
    --dependency-manager npm \
    --app-template hello-world


Project Components

hello-world folder contains Lambda source code and tests written in Nodejs. The sample Lambda code returns a HTTP 200 status with a Hello World message.
template.yaml file is one of the essential component of AWS SAM. You define each and every infrastructure components that you wish to deploy into your AWS environment.
Let's view the template.yaml file:

cd ~/environment/$ORDER_APP
cat template.yaml

As you can see template.yaml file deploys a Lambda function, and it also creates event sourcing to Amazon API Gateway (while doing that it creates the API Gateway too. Yes, I know!!! It is magical ;) )

Execute the following commands to build the SAM project.

cd ~/environment/$ORDER_APP
sam build

Once the SAM project is built, you can deploy the infrastructure to your AWS account.

1
sam deploy --stack-name $ORDER_APP --region $AWS_REGION --guided

Please enter following inputs when prompted after running the above command. For default one please Press Enter key.

Stack Name [order-app]: Press Enter key
AWS Region []: Press Enter key
Confirm changes before deploy [y/N]: y
Allow SAM CLI IAM role creation [Y/n]: Y
HelloWorldFunction may not have authorization defined, Is this okay? [y/N]: y
Save arguments to configuration file [Y/n]: Y
SAM configuration file [samconfig.toml]: Press Enter key
SAM configuration environment [default]: Press Enter key
Previewing CloudFormation changeset before deployment:

Deploy this changeset? [y/N]: y

Test the deployed endpoint

You can test if your hello world app is reachable by making a request to the HelloWorldApi URL found in the Deployment Output above.

Get the API Gateway Endpoint and execute the command to call the API Gateway endpoint.

API_ENDPOINT=`aws cloudformation describe-stacks --stack-name $ORDER_APP --region $AWS_REGION | jq -r '.Stacks[0].Outputs[] | select( .OutputValue | contains("execute-api"))' | jq -r ".OutputValue"`

curl -s $API_ENDPOINT | python3 -m json.tool

Output:

{"message":"hello world"}
