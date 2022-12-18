# ORDER_APP

In this lab, we will be using more Advanced Authorization mechanism with OAuth 2.0 authorization framework to access API.

The OAuth 2.0 authorization framework is a protocol that allows a user to grant a third-party web site or application access to the user's protected resources, without necessarily revealing their long-term credentials or even their identity.

Let's build and deploy stack.


cd ~/environment/$ORDER_APP
sam build
sam deploy --no-confirm-changeset


Testing the API with OAuth2 Scopes
Now, let's create another Order to delete with OAuth2 scope.


curl -s --header "Content-Type: application/json" \
  --header "Authorization: Bearer $IDTOKEN" \
  --data '{ "name" : "Oauth2 Scope - Pizza with user", "restaurantId" : "Restaurant 11199", "quantity":3 }' \
  --request POST $API_ENDPOINT | python3 -m json.tool

Order Creation

Replace the OrderID into <YOUR-ORDER-ID> field:

export ORDERID=<YOUR-ORDER-ID>

curl -I -s --header "Content-Type: application/json" \
  --header "Authorization: Bearer $IDTOKEN" \
  --request DELETE $API_ENDPOINT/$ORDERID 

Note that, you can have a look at lab4 -> Testing the Authentication to get IDTOKEN.

It will give HTTP 401 Unauthorized error in response. Because, we have defined delete_order scope to Delete method.

In order to get Access token with Oauth2 scope, we have to access to Cognito domain with delete_scope. You can find the Cognito Domain name from Cognito console or SAM Output. But, we need response_code parameter, so we should login to HostedUI with Username and Password in Lab4, then copy the response code at the end of callbackurl.

Step1: Click the Hosted UI button in App Client Settings of Cognito Pool:

Step2: Enter the username and password:

Step3: It will redirect to localhost callback with response_code. Get it and copy it into RESPONSE_CODE parameter as below. Step3

Get the RESPONSE_CODE variable from Cognito Console.

      
export RESPONSE_CODE=<response-code-from-cognito-console>

Then, copy and execute below commands to set Cognito Domain url, App client id and App Client secret.

      
export USER_POOL_ID=`aws cloudformation describe-stacks --stack-name $ORDER_APP --region $AWS_REGION | jq -r '.Stacks[0].Outputs[] | select( .OutputKey | contains("CognitoUserPoolID"))' | jq -r ".OutputValue"`

export COGNITO_DOMAIN_URL=`aws cloudformation describe-stacks --stack-name $ORDER_APP --region $AWS_REGION | jq -r '.Stacks[0].Outputs[] | select( .OutputKey | contains("CognitoDomain"))' | jq -r ".OutputValue"`

export CLIENT_ID=`aws cloudformation describe-stacks --stack-name $ORDER_APP --region $AWS_REGION | jq -r '.Stacks[0].Outputs[] | select( .OutputKey | contains("CognitoClientID"))' | jq -r ".OutputValue"`

export CLIENT_SECRET=`aws cognito-idp describe-user-pool-client --user-pool-id $USER_POOL_ID --client-id $CLIENT_ID  --region $AWS_REGION | jq -r ".UserPoolClient.ClientSecret"`

Now, let's try to Curl request to Cognito Domain to receive Access Token with OAuth2 scope(order-api/delete_order), response_code, client id, client secret


export ACCESS_TOKEN=`curl -s -X POST --user $CLIENT_ID:$CLIENT_SECRET \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    "https://$COGNITO_DOMAIN_URL.auth.$AWS_REGION.amazoncognito.com/oauth2/token?grant_type=authorization_code&client_id=$CLIENT_ID&scope=openid+profile&redirect_uri=https://localhost/callback&code=$RESPONSE_CODE&identity_provider=COGNITO&scope=order-api/delete_order" | jq -r ".access_token"`

Now, lets try to execute Delete action with ACCESS_TOKEN and <ORDERID>.(Check the Fetch Orders Testing Section to list orders and get the single order id )

curl -I -s  --header "Content-Type: application/json"  \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --request DELETE $API_ENDPOINT/$ORDERID

Now the OrderId has been deleted thanks to Oauth2 scope.
