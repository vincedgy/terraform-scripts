#!/usr/local/bin/python3
import boto3
import time

# Get the service resource
sqs = boto3.resource('sqs')

# Get the queue
queue = sqs.get_queue_by_name(QueueName='VDY_SQS_2')

# Create a new message
# response = queue.send_message(MessageBody='world')

# The response is NOT a resource, but gives you a message ID and MD5
# print(response.get('MessageId'))
#print(response.get('MD5OfMessageBody'))


i=10
while (i>1):
    currentTime = time.ctime()
    response = queue.send_message(MessageBody='Boto3 message', MessageAttributes={
        'Author': {
            'StringValue': currentTime,
            'DataType': 'String'
        }
    })
    print(response.get('MessageId'))
    i -= 1