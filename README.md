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

Click here to expand SAM Output:
Here is the SAM project structure for order-app:

├── order-app
│   ├── events
│   │   └── event.json
│   ├── hello-world
│   │   ├── app.js
│   │   ├── package.json
│   │   └── tests
│   │       └── unit
│   │           └── test-handler.js
│   ├── README.md
│   └── template.yaml
└── README.md

Project Components

hello-world folder contains Lambda source code and tests written in Nodejs. The sample Lambda code returns a HTTP 200 status with a Hello World message.
template.yaml file is one of the essential component of AWS SAM. You define each and every infrastructure components that you wish to deploy into your AWS environment.
Let's view the template.yaml file:

1
2
cd ~/environment/$ORDER_APP
cat template.yaml

Click here to expand Template.yaml:
As you can see template.yaml file deploys a Lambda function, and it also creates event sourcing to Amazon API Gateway (while doing that it creates the API Gateway too. Yes, I know!!! It is magical ;) )
