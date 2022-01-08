// Create a DocumentClient that represents the query to add an item
import DynamoDB from 'aws-sdk/clients/dynamodb';
import {AttributeNameList, ScanOutput} from "aws-sdk/clients/dynamodb";
import {PromiseResult, Request} from "aws-sdk/lib/request";
import {AWSError} from "aws-sdk/lib/error";
import {DocumentClient} from "aws-sdk/lib/dynamodb/document_client";

// Declare some custom client just to illustrate how TS will include only used files into lambda distribution
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