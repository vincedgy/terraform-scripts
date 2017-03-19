#!/usr/local/bin/python3
import boto3
import time

def printPoint():
    print('.', end='', flush=True)

# Get the service resource
sqs = boto3.resource('sqs')

# Get the queue
queue = sqs.get_queue_by_name(QueueName='VDY_SQS_2')

# Process messages by printing out body and optional author name
try:
    print ('Start processing.\n')
    while True:
        # Wait 1""
        time.sleep(1)
        printPoint()
        for message in queue.receive_messages(MessageAttributeNames=['Author']):
            # Get the custom author message attribute if it was set
            author_text = ''
            if message.message_attributes is not None:
                author_name = message.message_attributes.get('Author').get('StringValue')
                if author_name:
                    author_text = ' ({0})'.format(author_name)
            # Print out the body and author (if set)
            print('\nReceiving at {0} : {1} ({2})'.format(time.ctime(), message.body, author_text))
            # Let the queue know that the message is processed
            message.delete()
except KeyboardInterrupt:
    print ('\nProcessing interrupted!')