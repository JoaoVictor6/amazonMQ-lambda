exports.handler = async (event) => {
    console.log('Receptor Principal:', event);
    return {
        statusCode: 200,
        body: JSON.stringify('Message received successfully!')
    };
};