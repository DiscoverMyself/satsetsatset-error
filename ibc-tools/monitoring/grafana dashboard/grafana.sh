

#
# Thanks to: RoomIT && kj89nodes
# Edited by: Aprame
#

# User Input
read -p "Enter your job : " JOB
read -p "Enter your ip address : " IP
read -p "Enter your prometheus port : " PORT
read -p "Enter your valoper address : " VALOPER
read -p "Enter your operator address : " OPERATOR
echo 'export JOB='$JOB >> $HOME/.bash_profile
echo 'export IP='$IP >> $HOME/.bash_profile
echo 'export PORT='$PORT >> $HOME/.bash_profile
echo 'export VALOPER='$VALOPER >> $HOME/.bash_profile
echo 'export OPERATOR='$OPERATOR >> $HOME/.bash_profile
source $HOME/.bash_profile

# Download and delete previous existing grafana & prrometheus
cd $HOME
rm -rf grafana.sh
rm -rf exporter.sh
wget https://raw.githubusercontent.com/DiscoverMyself/satsetsatset-error/main/ibc-tools/monitoring/grafana%20dashboard/resources.sh && wget https://raw.githubusercontent.com/DiscoverMyself/satsetsatset-error/main/ibc-tools/monitoring/grafana%20dashboard/exporter.sh
chmod +x resources.sh
chmod +x exporter.sh
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

# set grafana & prometheus config for public dashboard
curl -Ls https://raw.githubusercontent.com/DiscoverMyself/satsetsatset-error/main/ibc-tools/monitoring/grafana%20dashboard/grafana.ini > /etc/grafana/grafana.ini

sudo tee /etc/prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 15s
  scrape_timeout: 10s
  evaluation_interval: 15s
alerting:
  alertmanagers:
    - follow_redirects: true
      scheme: http
      timeout: 10s
      api_version: v2
      static_configs:
        - targets:
            - alertmanager:9093
rule_files:
  - /etc/prometheus/alerts/alert.rules
scrape_configs:
  - job_name: prometheus
    metrics_path: /metrics
    static_configs:
      - targets:
          - ${IP}:9090
  - job_name: cosmos
    metrics_path: /metrics
    static_configs:
      - targets:
          - ${IP}:${PORT}
        labels: {}
  - job_name: node
    metrics_path: /metrics
    static_configs:
      - targets:
          - ${IP}:9100
        labels:
          instance: ${JOB}
  - job_name: validators
    metrics_path: /metrics/validators
    static_configs:
      - targets:
          - $IP:9300
        labels: {}
  - job_name: validator
    metrics_path: /metrics/validator
    relabel_configs:
      - source_labels:
          - address
        target_label: __param_address
    static_configs:
      - targets:
          - ${IP}:9300
        labels:
          address: ${VALOPER}
  - job_name: wallet
    metrics_path: /metrics/wallet
    relabel_configs:
      - source_labels:
          - address
        target_label: __param_address
    static_configs:
      - targets:
          - ${IP}:9300
        labels:
          address: ${OPERATOR}
EOF

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
