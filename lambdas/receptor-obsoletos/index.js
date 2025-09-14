exports.handler = async (event) => {
    console.log('Receptor Obsoletos:', event);
    return {
        statusCode: 200,
        body: JSON.stringify('Message received successfully!')
    };
};