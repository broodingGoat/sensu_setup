apt-get update
adduser --disabled-password --gecos "" sensu
echo "sensu ALL=(ALL:ALL) ALL" | (EDITOR="tee -a" visudo)
echo "deb http://www.rabbitmq.com/debian/ testing main" | tee -a /etc/apt/sources.list.d/rabbitmq.list
curl -L -o ~/rabbitmq-signing-key-public.asc http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
apt-key add ~/rabbitmq-signing-key-public.asc
apt-get install -y rabbitmq-server erlang-nox
service rabbitmq-server start

# ssl setup
mkdir -p /etc/rabbitmq/ssl
cp ./ssl_certs/sensu_ca/cacert.pem ./ssl_certs/server/cert.pem ./ssl_certs/server/key.pem /etc/rabbitmq/ssl
cp ./config/sensu_server/rabbitmq.config  /etc/rabbitmq/.
service rabbitmq-server restart
rabbitmqctl add_vhost /sensu
rabbitmqctl add_user sensu pass
rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"
apt-get -y install redis-server
service redis-server start
wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
echo "deb     http://repos.sensuapp.org/apt sensu main" | tee -a /etc/apt/sources.list.d/sensu.list
apt-get install -y sensu uchiwa
mkdir -p /etc/sensu/ssl
cp ./ssl_certs/client/cert.pem ./ssl_certs/client/key.pem /etc/sensu/ssl
mkdir -p /etc/sensu/conf.d
cp ./config/sensu_server/config.json /etc/sensu
cp ./config/sensu_server/rabbitmq.json /etc/sensu
cp ./config/sensu_server/redis.json /etc/sensu
cp ./config/sensu_server/api.json /etc/sensu
cp ./config/sensu_server/uchiwa.json /etc/sensu
cp ./config/sensu_server/client.json /etc/sensu
update-rc.d sensu-server defaults
update-rc.d sensu-client defaults
update-rc.d sensu-api defaults
update-rc.d uchiwa defaults
service sensu-server start
service sensu-client start
service sensu-api start
service uchiwa start
