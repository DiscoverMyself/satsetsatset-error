#!/bin/bash

#set vars
if [ ! $DISCORD_ID ]; then
	read -p "Enter your Dicord ID: " DISCORD_ID
	echo 'export DISCORD_ID='$DISCORD_ID >> $HOME/.bash_profile
fi

MONIKER=$(planqd status | jq -r .NodeInfo.moniker)
RPCADDRESS=$(planqd status | jq -r .NodeInfo.other.rpc_address)
CONSENSUSADDRESS=$(planqd tendermint show-address)


# build 
cd $HOME
git clone https://github.com/strangelove-ventures/half-life
cd half-life
wget -cO - https://raw.githubusercontent.com/planq-network/half-life/main/config.yaml.example > config.yaml

# change value
sed -i "s/DISCORD_WEBHOOK_ID/1072203008106041457/" $HOME/half-life/config.yaml
sed -i "s/DISCORD_WEBHOOK_TOKEN/1HnyTKIFWu3Y07XzYxWS2xcw_zRphjQ5ZntCSfiIYwxI0SMQtLngXiKJKGSXjGIRngRF/" $HOME/half-life/config.yaml
sed -i "s/monikername/$MONIKER/" $HOME/half-life/config.yaml
sed -i "s#tcp://localhost:26657#$RPCADDRESS#" $HOME/half-life/config.yaml
sed -i "s/plqvalcons1/$CONSENSUSADDRESS/" $HOME/half-life/config.yaml
sed -i "s/DISCORD_USER_ID/$DISCORD_ID/" $HOME/half-life/config.yaml

# install
go install

# create service file
sudo tee /etc/systemd/system/halflife.service << EOF
[Unit]
Description=Halflife
After=network.target
[Service]
Type=simple
Restart=always
RestartSec=5
TimeoutSec=180
User=$(whoami)
WorkingDirectory=$HOME/half-life
ExecStart=$(which halflife) monitor
LimitNOFILE=infinity
NoNewPrivileges=true
ProtectSystem=strict
RestrictSUIDSGID=true
LockPersonality=true
PrivateUsers=true
PrivateDevices=true
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF

# start service
systemctl daemon-reload
systemctl enable halflife
systemctl start halflife

sleep 2
clear

echo '===================================================='
echo -e "\e[1m\e[36mTo check service status : systemctl status halflife\e[0m"
echo -e "\e[1m\e[33mTo check logs status : journalctl -u halflife -f\e[0m"
echo '===================================================='
sleep 2
