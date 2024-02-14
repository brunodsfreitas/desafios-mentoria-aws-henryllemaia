const AWS = require('aws-sdk');

AWS.config.update({ region: 'us-east-2' });
const ec2 = new AWS.EC2({ apiVersion: "2016-11-15" });
const params = { 
    InstanceIds: ["i-00c7c91ca3bda3ed3"] 
};

exports.startEC2Instances = () => {
    return ec2.startInstances(params, function (err, data) {
        if (err) console.log(err,err.stack);
        else console.log("Evento Ligar Porteiro EC2 Realizado.")
    });
}

exports.stopEC2Instances = () => {
    return ec2.stopInstances(params, function (err, data) {
        if (err) console.log(err,err.stack);
        else console.log("Evento Desligar Porteiro EC2 Realizado.")
    });
}

