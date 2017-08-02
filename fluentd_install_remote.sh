#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "Usage fluentd_install_remote.sh <host:port>"
    exit 1
fi

IFS=':' read HOST PORT <<< $1

if [ -z "$HOST" ] || [ -z "$PORT" ]; then
    echo "Invalid host" $1
    exit 1
fi 


if ! type "fluentd" 1> /dev/null 2> /dev/null; then
  echo "Installing fluentd"
  sudo apt-get update; apt-get install -y ruby ruby-dev gcc make netcat
  gem install fluentd -v "0.14.19"
  gem install fluent-plugin-parser
fi
nc -z $HOST $PORT
if [ $? ]; then
    echo "WARNING! Failed to connect to" $1
fi

mkdir -p /usr/local/fluentd/conf
echo "<source>
  @type forward
  port 24224
</source>
<match shop>
  type parser
  key_name messages
  format json
  tag rails
  reserve_data yes
</match>
<match rails>
  @type forward
  flush_interval 1s
  <server>
    host" $HOST"
    port" $PORT"
  </server>
</match>" > /usr/local/fluentd/conf/remote.conf

echo "To start connector run fluentd -c /usr/local/fluentd/conf/remote.conf"