# ORDER_APP

In this lab, we will be using Step functions to process to send it to show payment /restaurant checking/ and sending notification to user about process.

In a real world scenario, when the orders are created by end users, the order has been processed by the system before writing into the databases. For instance, checking the payment method is valid, or getting validation from restaurant, etc. So, we will add these functionalities by using Step functions to our API.

##Note: Change the email in the code to your email address to receive email notification.

Now, let's build and deploy, then test the functionality of our API.

cd ~/environment/$ORDER_APP
sam build
sam deploy --no-confirm-changeset

We've deployed Step functions and related Lambda functions.

Check the lambda functions created:

Lambda functions

Check the step functions created:


Go to your email address that you specified in SNS Topic Configuration of template.yaml. Ensure that Confirmation email address arrived to your email address. Then confirm the subscription.

SNS Confirmation

Testing via Curl
Let's create an Order. API Gateway will send order to SQS as message. Then, Lambda consumer will poll it, process it and call the Step functions and, send it to restaurant to process order.

curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"name":"Step Functions Pizza","restaurantId":"Restaurant 99","quantity":3 }' \
  $API_ENDPOINT | python3 -m json.tool 

Output:

{
    "SendMessageResponse": {
        "ResponseMetadata": {
            "RequestId": "4cef435b-a878-50e4-9d72-1a91c5a02d4a"
        },
        "SendMessageResult": {
            "MD5OfMessageAttributes": null,
            "MD5OfMessageBody": "c94d45bc611e259517988901a8b65ec5",
            "MD5OfMessageSystemAttributes": null,
            "MessageId": "53e2e439-d785-4332-9ed8-327bd0640cac",
            "SequenceNumber": null
        }
    }
}

Here is the flow once you send POST request to API Gateway:

Client sends POST request with Order Payload to API Gateway
API Gateway sends Order Payload to SQS Queue.
Lambda Poller takes the Order Payload(s) from SQS Queue, and invokes the Step function execution per message with Order Payload.
Then Step functions invokes the ManageState function at the beginning, and write order to DynamoDB with Pending status.
After 30 sec. waiting period, Step functions call ProcessPayment and/or SendOrderToRestaurant functions according to choice.
According to result from ProcessPayment and/or SendOrderToRestaurant functions, ManageState function updates the order item in DynamoDB Table with SUCCESS or FAILURE.
