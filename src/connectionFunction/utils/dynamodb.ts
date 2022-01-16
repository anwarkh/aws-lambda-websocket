
import DynamoDB from 'aws-sdk/clients/dynamodb';
import {AttributeNameList} from "aws-sdk/clients/dynamodb";

export default class CustomDynamoClient {
    table: string;
    docClient: DynamoDB.DocumentClient;

    constructor(table = process.env.CONNECTIONS_TABLE) {
        this.docClient = new DynamoDB.DocumentClient();
        this.table = table!;
    }

    async readAll() {
        const data = await this.docClient.scan({TableName: this.table}).promise();
        return data.Items;
    }


    async readAllAttributes(attributesToGet: AttributeNameList){
        return  await this.docClient.scan({
            TableName: this.table,
            AttributesToGet: attributesToGet
        }).promise();
    }

    async read(id: any) {
        var params = {
            TableName: this.table,
            Key: {id: id},
        };
        const data = await this.docClient.get(params).promise();
        return data.Item;
    }

    async write(Item: object) {
        const params = {
            TableName: this.table,
            Item,
        };

        return await this.docClient.put(params).promise();
    }

    async remove(connectionId: string) {
        const params = {
            TableName: this.table,
            Key: {connectionId},
        };

        return await this.docClient.delete(params).promise();
    }
}