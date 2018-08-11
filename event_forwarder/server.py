import logging
import boto3
from flask import Flask, request
import json
import time
import requests
import os

public_ip = requests.get('http://ip.42.pl/raw').text
print('Public IP is: ' + public_ip)
app = Flask(__name__)

kinesis_client = boto3.client('kinesis', region_name=os.getenv('AWS_REGION', os.getenv('AWS_DEFAULT_REGION', 'us-west-2')))
kinesis_stream = os.getenv('KINESIS_STREAM_NAME')
partition_key = None

@app.route('/', methods=["POST"])
def csgo():
    data = request.data.decode('UTF-8')
    json_data = json.loads(data) # parse JSON
    event_type = json_data.pop('event_type')
    kinesis_payload = {'event_type': event_type,
                       'game': {'id': '730',
                                'name': 'cs:go',
                                'type': 'fps',
                                'platform': 'steam'},
                       'server': {'ip': public_ip,
                                  'mode': os.getenv('GAME_MODE'),
                                  'type': os.getenv('GAME_TYPE'),
                                  'timestamp': str(time.time()),
                                  'name': os.getenv('SERVER_HOSTNAME', 'CS:GO Server')},
                       'payload': json_data}

    if os.getenv('DRY_RUN', False):
        logging.info('DryRun - Payload: ' + json.dumps(kinesis_payload))
    else:
        response = kinesis_client.put_record(
            StreamName=kinesis_stream,
            Data=json.dumps(kinesis_payload),
            PartitionKey=str(json_data.get("attacker_serial", "")) + "-" + str(json_data.get('victim_serial', ''))
        )
        logging.info('kinesis.put_record Response: ' + json.dumps(response))
    return '', 204

if __name__ == "__main__":
    if not os.getenv('DRY_RUN'):
        kinesis_client.put_record(
            StreamName=kinesis_stream,
            Data=json.dumps({'type': 'server', 'name':'server_start', 'ip': public_ip, 'name': os.getenv('SERVER_HOSTNAME')}),
            PartitionKey='server'
        )
    app.run(port=5000, host='0.0.0.0')
