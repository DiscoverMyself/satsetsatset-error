

#
# Thanks to: RoomIT && kj89nodes
# Edited by: Aprame
#

# User Input
read -p "Enter your ip address : " IP
read -p "Enter your prometheus port : " PORT
read -p "Enter network chain-id  : " CHAIN
echo 'export IP='$IP >> $HOME/.bash_profile
echo 'export PORT='$PORT >> $HOME/.bash_profile
echo 'export CHAIN='$CHAIN >> $HOME/.bash_profile
source $HOME/.bash_profile

# Download and delete previous existing grafana & prrometheus
cd $HOME
rm -rf grafana.sh
rm -rf exporter.sh
wget https://raw.githubusercontent.com/DiscoverMyself/satsetsatset-error/main/ibc-tools/monitoring/grafana%20dashboard/resources.sh
chmod +x resources.sh
./resources.sh uninstall grafana
./resources.sh uninstall prometheus

# Deploy Grafana And Prometheus
./resources.sh deploy grafana
./resources.sh deploy prometheus
rm -f resources.sh

# Install Packages
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install make build-essential gcc git jq chrony lz4 nginx unzip nodejs yarn -y

# Download Grafana Render And Move
wget https://github.com/grafana/grafana-image-renderer/archive/refs/heads/master.zip
unzip master.zip -d /opt/
rm -f master.zip
sudo mkdir -p /opt/grafana-plugin
sudo mv /opt/grafana-image-renderer-master /opt/grafana-plugin/

# set grafana config
curl -Ls https://raw.githubusercontent.com/DiscoverMyself/satsetsatset-error/main/ibc-tools/monitoring/grafana%20dashboard/grafana.ini > /etc/grafana/grafana.ini

# set grafana login config
sudo tee /etc/default/grafana-server <<EOF
GRAFANA_USER=grafana

GRAFANA_GROUP=grafana

GRAFANA_HOME=/usr/share/grafana

LOG_DIR=/var/log/grafana

DATA_DIR=/var/lib/grafana

MAX_OPEN_FILES=10000

CONF_DIR=/etc/grafana

CONF_FILE=/etc/grafana/grafana.ini

RESTART_ON_UPGRADE=true

PLUGINS_DIR=/var/lib/grafana/plugins

PROVISIONING_CFG_DIR=/etc/grafana/provisioning

GF_AUTH_ANONYMOUS_ENABLED=true
# Only used on systemd systems
PID_FILE_DIR=/run/grafana
EOF



# Set prometheus config
sudo tee /etc/prometheus/prometheus.yml <<EOF
global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['$IP:9090']
  - job_name: 'node_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['$IP:9100']
  - job_name: "interchains"
    metrics_path: '/metrics'
    static_configs:
      - targets: ["127.0.0.1:$PORT"]
        labels:
          group: 'planq_7070-2'
# you can add another chain in here, for example:
#      - targets: ["127.0.0.1:<PROMETHEUS_PORT>"]
#       labels:
#         group: '<CHAIN_ID>'
EOF

clear
sleep 1

# Build Grafana Render
cd /opt/grafana-plugin/grafana-image-renderer-master
yarn install --pure-lockfile
yarn run build

# Create Service
sudo tee /etc/systemd/system/grafana-render.service > /dev/null <<EOF
[Unit]
Description=Grafana instance
Documentation=http://docs.grafana.org
Wants=network-online.target
After=network-online.target
After=postgresql.service mariadb.service mysql.service

[Service]
User=grafana
Group=grafana
Type=simple
ExecStart=/usr/bin/node /opt/grafana-plugin/grafana-image-renderer-master/build/app.js server --port=8081

[Install]
WantedBy=multi-user.target
EOF

clear
sleep 1

# Register Start Service And Install Plugin
sudo systemctl daemon-reload
sudo systemctl start grafana-render
grafana-cli plugins install grafana-image-renderer

# Setting Port || Config Grafana
# sed -i.bak \
#   -e "s|^;http_port *=.*|;http_port = 3000|" \
#   -e "s|^;server_url *=.*|;server_url = http://127.0.0.1:8081/render|" \
#   -e "s|^;callback_url *=.*|;callback_url = http://127.0.0.1:3000|" \
#   /etc/grafana/grafana.ini

# Start all services
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus
systemctl enable grafana-server
systemctl start grafana-server


echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "USERNAME : \e[1m\e[31madmin\e[0m"
echo -e "PASSWORD : \e[1m\e[31madmin\e[0m"
echo -e "LOGIN TO YOUR GRAFANA DASHBOARD : \e[1m\e[31mhttp://$(curl -s ifconfig.me):3000/login\e[0m"
echo ""
echo -e "CHECK GRAFANA LOGS   : \e[1m\e[31msystemctl status grafana-server\e[0m"
echo -e "CHECK PROMETHEUS LOGS : \e[1m\e[31msystemctl status prometheus\e[0m"
echo ""

cd #HOME
rm -f grafana.sh
