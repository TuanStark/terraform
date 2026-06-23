const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({ endpoint: process.env.LOCALSTACK_HOSTNAME ? `http://${process.env.LOCALSTACK_HOSTNAME}:4566` : undefined });
const ddbDocClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
    console.log("Sự kiện nhận được:", JSON.stringify(event));

    const body = JSON.parse(event.body || "{}");
    const userId = body.userId || "guest_" + Date.now();

    const params = {
        TableName: "Users",
        Item: {
            UserId: userId,
            Timestamp: new Date().toISOString(),
            Data: body.message || "No data provided"
        }
    };

    try {
        await ddbDocClient.send(new PutCommand(params));
        return {
            statusCode: 201,
            body: JSON.stringify({ status: "Success", message: "Ghi dữ liệu thành công!" })
        };
    } catch (err) {
        return {
            statusCode: 500,
            body: JSON.stringify({ error: err.message })
        };
    }
};