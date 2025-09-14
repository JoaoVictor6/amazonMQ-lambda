const AWS = require('aws-sdk');

exports.handler = async (event) => {
    const mq = new AWS.MQ({
        endpoint: 'http://localhost:4566',
        region: 'us-east-1'
    });

    const params = {
        BrokerId: 'poc-amazon-mq',
        QueueName: 'edicao-de-proposta',
        MessageBody: JSON.stringify({
            ...event,
            isObsoleto: Boolean(event.isObsoleto)
        })
    };

    await mq.sendMessage(params).promise();

    return {
        statusCode: 200,
        body: JSON.stringify('Message sent successfully!')
    };
};