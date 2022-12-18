# ORDER_APP

In this lab, we will be adding Authentication to our API to create/fetch/update/delete order and access our APIs securely.

The API that we have created is open to everyone. Anyone can create or delete orders. We need to control access to our API.

We will be creating Cognito User Pool, and will be attaching it into API Gateway HTTP Methods as Authorizer. So, the end users or api developers who want to reach the API will first need to get ID token from Cognito by using their Cognito credentials(username/password/client id/client secret). Then using IDToken as Bearer token in HTTP requests.

