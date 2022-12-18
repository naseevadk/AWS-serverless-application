# ORDER_APP

In this lab, we've updated template.yaml, api.yaml and PostOrders to create the SQS Queue and connect this via API Gateway to our Lambda function. Now, let's build and deploy, then test the functionality of our API.

cd ~/environment/$ORDER_APP
sam build
sam deploy --no-confirm-changeset

Testing via Curl
Let's create an order again. This time, API Gateway will send the order to SQS instead of directly calling our Lambda function. Our modified Lambda, that is now connected to the SQS queue via an event trigger, will then consume the message, process it, and insert a new order into DynamoDB.

curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"name":"Pizza","restaurantId":"Restaurant 99","quantity":3 }' \
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

This output message is the response API Gateway received from SQS Queue after posting the message to it. Let's fetch the whole orders (GET ../orders/) to check if the new order has been processed by the Lambda function and inserted into the DynamoDB table.

1
curl -s $API_ENDPOINT | python3 -m json.tool

Output:

[
    {
        "quantity": 3,
        "createdAt": "2021-09-26T12:46:16",
        "user_id": "static_user",
        "orderStatus": "PENDING",
        "id": "53e2e439-d785-4332-9ed8-327bd0640cac",
        "name": "Pizza",
        "restaurantId": "Restaurant 99"
    },
    .
    .
    .
]
