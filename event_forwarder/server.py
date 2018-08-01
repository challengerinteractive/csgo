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

    kinesis_payload = {}
    if json_data.get('event_type') == 'player_death':
        kinesis_payload = {'game':{'id':'1',
                                   'name': 'counterstrike',
                                   'type': 'FPS',
                                   'match': {'id':'',
                                             'map': json_data.get('map'),
                                             'type': str(os.getenv('GAME_TYPE'))}},
                           'type': 'action',
                           'name': 'kill',
                           'event_type': json_data.get('event_type'),
                           'time': json_data.get('timestamp', str(time.time())),
                           'winner': {'steam_id': json_data.get('attacker_steam_id', 'BOT'),
                                      'headshot': str(json_data.get('headshot', False))},
                           'loser': {'steam_id': json_data.get('victim_steam_id', 'BOT')},
                           'assister': {'steam_id': json_data.get('assister_steam_id', 'BOT')},
                           'platform': {'id': '1', 'name': 'PC'},
                           'system': {'name': 'Steam'},
                           'server': {'ip': public_ip,
                                      'system_id': json_data.get('steam_server_id'),
                                      'name': os.getenv('SERVER_HOSTNAME')}}

    for direction in ['up', 'down']:
        for key in ['victim_latency', 'victim_avg_loss', 'victim_avg_choke']:
            idx = "%s_%s" % (key, direction)
            if json_data.get(idx):
                if not kinesis_payload.get('debug'):
                    kinesis_payload['debug'] = {}
                kinesis_payload['debug'][idx] = json_data.get(idx)

    if os.getenv('DRY_RUN', False):
        logging.info('DryRun - Payload: ' + json.dumps(kinesis_payload))
    else:
        response = kinesis_client.put_record(
            StreamName=kinesis_stream,
            Data=kinesis_payload,
            PartitionKey=str(json_data.get("attacker_serial", "")) + "-" + str(json_data.get('victim_serial', ''))
        )
        logging.info('kinesis.put_record Response: ' + json.dumps(response))


if __name__ == "__main__":
    if not os.getenv('DRY_RUN'):
        kinesis_client.put_record(
            StreamName=kinesi_stream,
            Data=json.dumps({'type': 'server', 'name':'server_start', 'ip': public_ip, 'name': os.getenv('SERVER_HOSTNAME')}),
            PartitionKey='server'
        )
    app.run(port=5000, host='0.0.0.0')
