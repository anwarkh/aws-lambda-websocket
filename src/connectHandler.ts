
import {
    APIGatewayProxyEvent,
    APIGatewayProxyResult
} from "aws-lambda";
import CustomDynamoClient from "./utils/dynamodb";
import {getAllConnections, sendMessage} from "./utils/broadcast";


/**
 * A simple example includes a HTTP get method to get one item by id from a DynamoDB table.
 */
export const handle = async (
    event: APIGatewayProxyEvent,
): Promise<APIGatewayProxyResult> => {

    const {body, requestContext: {connectionId, routeKey, domainName, stage}} = event;
    const client = new CustomDynamoClient();
    switch (routeKey) {
        case '$connect':
            await client.write({
                connectionId,
                ttl: parseInt((Date.now() / 1000).toString() + 3600)
            })
            break;
        case '$disconnect':
            await client.remove(connectionId)
            break;

        case '$default':
        default: {
            const connections = await getAllConnections();
            await Promise.all(
                connections.map(connectionId => sendMessage(connectionId, body, domainName+'/'+stage)
            ));
            break;
        }
    }

    const response = {
        statusCode: 200,
        body:  JSON.stringify({ connectionId: connectionId})
    };

    // All log statements are written to CloudWatch
    console.info(`response from: ${event.path} statusCode: ${response.statusCode} body: ${response.body}`);
    return response;
}