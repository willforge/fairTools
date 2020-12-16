#

screen -dmS "CONFIG" ../bin/serve_config.pl

sleep 1
curl -iL http://127.0.0.1:1124/config.json
