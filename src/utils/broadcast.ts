import CustomDynamoClient from "./dynamodb";

import AWS from "aws-sdk";


export async function sendMessage(connectionId, body, endpoint) {
    try {
        const apig = new AWS.ApiGatewayManagementApi({
            endpoint
        });
        await apig.postToConnection({
            ConnectionId: connectionId,
            Data: JSON.stringify(body)
        }).promise();
    } catch (err) {
        // Ignore if connection no longer exists
        if (err.statusCode !== 400 && err.statusCode !== 410) {
            throw err;
        }
    }
}

export async function getAllConnections() {
    const client = new CustomDynamoClient();
    const {Items, LastEvaluatedKey} = await client.readAllAttributes(['connectionId'])

    const connections = Items.map(({connectionId}) => connectionId);
    if (LastEvaluatedKey) {
        connections.push(...await this.getAllConnections());
    }

    return connections;
}