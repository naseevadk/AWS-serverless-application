# ORDER_APP

In this lab, we will be adding Authentication to our API to create/fetch/update/delete order and access our APIs securely.

The API that we have created is open to everyone. Anyone can create or delete orders. We need to control access to our API.

We will be creating Cognito User Pool, and will be attaching it into API Gateway HTTP Methods as Authorizer. So, the end users or api developers who want to reach the API will first need to get ID token from Cognito by using their Cognito credentials(username/password/client id/client secret). Then using IDToken as Bearer token in HTTP requests.


Let's build and deploy all changes!

cd ~/environment/$ORDER_APP
sam build
sam deploy --no-confirm-changeset


Using the curl command from the command line.


curl -s $API_ENDPOINT | python3 -m json.tool

You should receive the following response

{
    "message": "Unauthorized"
}

The orders API will now only accept authenticated requests.

Lets create and add users to User pool in order to test the API with Authenticated user. You will need the following values from the output of the SAM template.You can grab them from latest SAM build and deploy output or go to Cognito Console, and look for them.

CognitoClientID
CognitoClientSecret
CognitoUserPoolID
Set your personal email address as USERNAME and put your dummy password as PASSWORD with the length of at least 8 characters as below

export USERNAME='<EMAIL_ADDRESS>'
export PASSWORD='<MY-DUMMY-PASSWORD>'
Then, execute the below commands to receive from cognito and set cognito user pool id, app client id and app client secret variables.

export USER_POOL_ID=`aws cloudformation describe-stacks --stack-name $ORDER_APP --region $AWS_REGION | jq -r '.Stacks[0].Outputs[] | select( .OutputKey | contains("CognitoUserPoolID"))' | jq -r ".OutputValue"`

export CLIENT_ID=`aws cloudformation describe-stacks --stack-name $ORDER_APP --region $AWS_REGION | jq -r '.Stacks[0].Outputs[] | select( .OutputKey | contains("CognitoClientID"))' | jq -r ".OutputValue"`

export CLIENT_SECRET=`aws cognito-idp describe-user-pool-client --user-pool-id $USER_POOL_ID --client-id $CLIENT_ID  --region $AWS_REGION | jq -r ".UserPoolClient.ClientSecret"`


Create Secret Hash from Username, clientid and clientsecret.

msg="$USERNAME$CLIENT_ID"
export SECRET_HASH=`echo -n $msg | openssl dgst -sha256 -hmac $CLIENT_SECRET -binary | base64`

  
Then, sign up the Username with its email address and Password by using ClientID and SecretHash.

aws cognito-idp sign-up \
    --client-id $CLIENT_ID \
    --secret-hash $SECRET_HASH \
    --username $USERNAME \
    --password $PASSWORD \
    --user-attributes Name=email,Value=$USERNAME \
    --region $AWS_REGION

You should see the following response.

{
    "UserConfirmed": false,
    "UserSub": "ec62a10b-bb74-4395-b9fe-bd1997609526"
}

To confirm the user, execute the following command from the command line.

aws cognito-idp admin-confirm-sign-up \
    --user-pool-id $USER_POOL_ID \
    --username $USERNAME \
    --region $AWS_REGION

No response will be returned.

2. Authenticate with created user
Authenticate with created user will generate ID Token.


export IDTOKEN=`aws cognito-idp admin-initiate-auth \
        --user-pool-id $USER_POOL_ID \
        --client-id $CLIENT_ID \
        --auth-flow ADMIN_NO_SRP_AUTH \
        --auth-parameters USERNAME=$USERNAME,PASSWORD=$PASSWORD,SECRET_HASH=$SECRET_HASH \
        --region $AWS_REGION \
        | jq -r ".AuthenticationResult.IdToken"`

Copy the value of IdToken and use it in the snippet below after "Bearer"

curl -s --header "Authorization: Bearer $IDTOKEN" \
    --request GET $API_ENDPOINT | python3 -m json.tool

The output should be similar to the following.

[
    {
        "quantity": 2,
        "createdAt": "2021-10-04T08:59:07+0000",
        "user_id": "static_user",
        "orderStatus": "SUCCESS",
        "id": "047e55e9-641d-4b58-bb13-4128c4821ec4",
        "name": "Burger",
        "restaurantId": "Restaurant 2"
    },
    {
        "quantity": 2,
        "createdAt": "Mon Oct 04 2021 10:44:57 GMT+0200 (South Africa Standard Time)",
        "user_id": "static_user",
        "status": "Pending",
        "id": "153d6fda-7d20-4ec2-a7b6-e9c9d1c2b72a",
        "name": "Doner Kebap",
        "restaurantId": "Restaurant 1"
    },
    {
        "quantity": 3,
        "createdAt": "Mon Oct 04 2021 10:44:57 GMT+0200 (South Africa Standard Time)",
        "user_id": "static_user",
        "status": "Pending",
        "id": "1d14dcfd-50a9-485c-81ce-0a115e6e88dd",
        "name": "Spaghetti",
        "restaurantId": "Restaurant 1"
    },
    {
        "quantity": 2,
        "createdAt": "Mon Oct 04 2021 10:44:57 GMT+0200 (South Africa Standard Time)",
        "user_id": "static_user",
        "status": "Pending",
        "id": "3bdd4083-c078-4268-b9a9-2fb7e531735f",
        "name": "Beef",
        "restaurantId": "Restaurant 2"
    }
]
  

  
Testing with Create Order: We will be using IDTOKEN to access API Gateway. Replace your API Gateway endpoint as below

curl -s --header "Content-Type: application/json" \
  --header "Authorization: Bearer $IDTOKEN" \
  --data '{ "name" : "Pizza with user", "restaurantId" : "Restaurant 11199", "quantity":3 }' \
  --request POST $API_ENDPOINT | python3 -m json.tool

It will POST the order with cognito userid in the Dynamodb table
  
  
Testing with Delete Order: We will be using IDTOKEN to access API Gateway. Replace your API Gateway endpoint and <ORDER_ID> which you want to specifically delete. (Check the curl command in the Fetch Orders Testing Section)

Replace the OrderID into <YOUR-ORDER-ID> field:

1
ORDERID=<YOUR-ORDER-ID> # Check Fetch Orders Testing Section, and grab one of the Order ID after fetching all orders.

1
curl -I -s --header "Authorization: Bearer $IDTOKEN" --request DELETE $API_ENDPOINT/$ORDERID

It will delete the order of specific userId from the DynamoDB Table.

