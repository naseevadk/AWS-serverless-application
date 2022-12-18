# ORDER_APP

In this lab, we will be building an Order API by using the AWS Serverless Stack (ApiGateway - Lambda - DynamoDB) and the synchronous request-response pattern with AWS SAM. Users will create an Order, GET the list of Orders, and GET/UPDATE/DELETE a specific Order.

In this lab, our API will have following resources and HTTP methods.

/orders: This resources allows users to list their orders and create new ones
 - GET: List orders - API Gateway -> Lambda -> DynamoDB
 - POST: Create New Order - API Gateway -> Lambda -> DynamoDB

/orders/{id}: Users can call this resource to show their order details
 - GET: Show order details - API Gateway -> Lambda -> DynamoDB
 - PUT: Update order status - API Gateway -> Lambda -> DynamoDB
 - DELETE: Cancel order - API Gateway -> Lambda -> DynamoDB

Populating Order Table
Let's populate order-table with sample data. In order to do that, enter the following command in your terminal.

cd ~/environment/$ORDER_APP/populate-db
node seed-orderdb.js

Build and Deploy the SAM project:

cd ~/environment/$ORDER_APP
sam build
sam deploy --no-confirm-changeset


After deploying, Let's receive the API_ENDPOINT from SAM output, and set it as environment variable:

API_ENDPOINT=`aws cloudformation describe-stacks --stack-name $ORDER_APP --region $AWS_REGION | jq -r '.Stacks[0].Outputs[] | select( .OutputValue | contains("execute-api"))' | jq -r ".OutputValue"`

echo "export API_ENDPOINT=${API_ENDPOINT::-1}" | tee -a ~/.bash_profile # It will be saved to env. variable to use in next sections of labs

source ~/.bash_profile

Curl:

curl -s $API_ENDPOINT | python3 -m json.tool

From the above curl command you will get all the orders from our custom Order API Gateway calling our GetOrders Lambda function.


Let's create an Order now! We will be sending a JSON Payload to our API Gateway.

Sample Payload:

{
    "quantity": 2,
    "name": "Burger",
    "restaurantId": "Restaurant 2"
}
Curl:

curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"name":"Burger","restaurantId":"Restaurant 2","quantity":2 }' \
  $API_ENDPOINT | python3 -m json.tool 

Output:

{
    "user_id": "static_user",
    "id": "8836f1ff-c20b-4377-918f-1955ba2c27b2",
    "name": "Burger",
    "restaurantId": "Restaurant 2",
    "quantity": 2,
    "createdAt": "2021-09-25T16:15:27",
    "orderStatus": "PENDING"
    
}


Replace the OrderID into <YOUR-ORDER-ID> field:

# Grab one of the Order ID after fetching all orders. 
export ORDERID=<YOUR-ORDER-ID> 

curl -s $API_ENDPOINT/$ORDERID | python3 -m json.tool
      

Let's update an Order now! We will now update the Burger order's quantity from 2 to 3. You have to put order id into path at the end of url. To do that, you can fetch orders first, then grab the order Id for single order.(Check the curl command in the Fetch Orders Testing Section).

Replace the OrderID into <YOUR-ORDER-ID> field:

export ORDERID=<YOUR-ORDER-ID> # Check Fetch Orders Testing Section, and grab one of the Order ID after fetching all orders. 

Curl:

curl -s --header "Content-Type: application/json" \
  --request PUT \
  --data '{"name":"Sushi","restaurantId":"Fancy Restaurant","quantity":12 }' \
  $API_ENDPOINT/$ORDERID | python3 -m json.tool 

Now, you updated order with new values.
      
      
      
Let's delete Delete from previous section to delete this Order. You have to put order id into path at the end of url. To do that, you can fetch orders first, then grab the order Id for single order.(Check the curl command in the Fetch Orders Testing Section)

Replace the OrderID into <YOUR-ORDER-ID> field:

export ORDERID=<YOUR-ORDER-ID> # Check Fetch Orders Testing Section, and grab one of the Order ID after fetching all orders. 

Curl:

curl -I -s --request DELETE $API_ENDPOINT/$ORDERID

Output should return HTTP 204 method.

HTTP/2 204
