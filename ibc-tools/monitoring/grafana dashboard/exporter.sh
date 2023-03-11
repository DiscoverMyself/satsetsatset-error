#!/usr/bin/env bash

read -p "Enter denom value. (Eg: \"aplanq\" on PLANQ): " DENOM
read -p "Enter bench_prefix value (Eg: planq128.. then input \"planq\"): " BENCH_PREFIX
read -p "Enter your RPC port : " RPC_PORT
read -p "Enter your gRPC port: " GRPC_PORT

echo '================================================='
echo -e "DENOM: \e[1m\e[32m$DENOM\e[0m"
echo -e "BENCH_PREFIX: \e[1m\e[32m$BENCH_PREFIX\e[0m"
echo -e "RPC PORT: \e[1m\e[32m$RPC_PORT\e[0m"
echo -e "GRPC PORT: \e[1m\e[32m$GRPC_PORT\e[0m"
echo '================================================='
sleep 3

echo -e "\e[1m\e[32m1. Installing cosmos-exporter... \e[0m" && sleep 1
# install cosmos-exporter
wget https://github.com/solarlabsteam/cosmos-exporter/releases/download/v0.2.2/cosmos-exporter_0.2.2_Linux_x86_64.tar.gz
tar xvfz cosmos-exporter*
sudo cp ./cosmos-exporter /usr/bin
rm cosmos-exporter* -rf

sudo useradd -rs /bin/false cosmos_exporter

sudo tee <<EOF >/dev/null /etc/systemd/system/cosmos-exporter.service
[Unit]
Description=Cosmos Exporter
After=network-online.target

[Service]
User=cosmos_exporter
Group=cosmos_exporter
TimeoutStartSec=0
CPUWeight=95
IOWeight=95
ExecStart=cosmos-exporter --denom ${DENOM} --denom-coefficient 1000000 --bech-prefix ${BENCH_PREFIX} --tendermint-rpc http://localhost:${RPC_PORT} --node http://localhost:${GRPC_PORT}
Restart=always
RestartSec=2
LimitNOFILE=800000
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF

echo -e "\e[1m\e[32m2. Installing node-exporter... \e[0m" && sleep 1
# install node-exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar xvfz node_exporter-*.*-amd64.tar.gz
sudo mv node_exporter-*.*-amd64/node_exporter /usr/local/bin/
rm node_exporter-* -rf

sudo useradd -rs /bin/false node_exporter

sudo tee <<EOF >/dev/null /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable cosmos-exporter
sudo systemctl start cosmos-exporter
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

echo -e "\e[1m\e[32mInstallation finished... \e[0m" && sleep 1
echo -e "\e[1m\e[32mPlease, make sure ports 9100 and 9300 are open \e[0m" && sleep 1
