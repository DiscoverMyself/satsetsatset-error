#!/bin/sh

# install prerequisites
sudo apt-get update && sudo apt install jq && sudo apt install apt-transport-https ca-certificates curl software-properties-common -y && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" && sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin && sudo apt-get install docker-compose-plugin -y

# build binaries
git clone https://github.com/eco-stake/restake
cd restake
npm install

# setup .env file

echo "\e[1;93m=========================================================================================================================="
if [ ! $MNEMONIC ]; then
        read -p "Enter your Mnemonic: " MNEMONIC
        echo 'export MNEMONIC='$MNEMONIC >> $HOME/.bash_profile
fi

echo "\e[1;93m=========================================================================================================================="
echo "\e[1;92m=========================================================================================================================="
# set variable for validator address
if [ ! $VALOPER ]; then
        read -p "Enter your Valoper Address: " VALOPER
        echo 'export VALOPER='$VALOPER >> $HOME/.bash_profile
fi
echo "\e[1;92m=========================================================================================================================="
echo "\e[0m."


sudo tee ~/restake/.env << EOF
MNEMONIC=$MNEMONIC
EOF

echo "\e[1m\e[32m6. Starting... \e[0m" && sleep 2

# run docker
git pull
docker-compose run --rm app npm install
docker-compose build --no-cache
docker-compose run --rm app npm run autostake

# setup cron timer
sudo tee /var/spool/cron/crontabs/root << EOF
0 21 * * * /bin/bash -c "cd restake && docker compose run --rm app npm run autostake" > ./restake.log 2>&1
EOF

# create service file
sudo tee /etc/systemd/system/restake.service > dev/null <<EOF
[Unit]
Description=restake service with docker compose
Requires=docker.service
After=docker.service
Wants=restake.timer

[Service]
Type=oneshot
WorkingDirectory=/root/restake
ExecStart=/usr/bin/docker-compose run --rm app npm run autostake

[Install]
WantedBy=multi-user.target

[Timer]
AccuracySec=1min
OnBootSec=300
OnUnitActiveSec=300
EOF

sudo tee /etc/systemd/system/restake.timer > dev/null <<EOF
[Unit]
Description=Restake bot timer

[Timer]
AccuracySec=1min
OnBootSec=300
OnUnitActiveSec=300

[Install]
WantedBy=timers.target
EOF

# start the service (Scheduled by timer)
systemctl enable restake.service
systemctl enable restake.timer
systemctl start restake.timer

# create networks.local file
sudo tee ~/restake/src/networks.local.json <<EOF
{
  "planq": {
    "prettyName": "Planq",
    "restUrl": [
      "https://rest.planq.network/"
    ],
    "gasPrice": "0.025planq",
    "autostake": {
      "retries": 3,
      "batchPageSize": 100,
      "batchQueries": 25,
      "batchTxs": 50,
      "delegationsTimeout": 20000,
      "queryTimeout": 5000,
      "queryThrottle": 100,
      "gasModifier": 1.1
    },
    "healthCheck": {
      "uuid": "XXXXX-XXX-XXXX"
    }
  },
  "planq": {
    "prettyName": "Planq",
    "autostake": {
      "correctSlip44": true
    }
  },
  "cosmoshub": {
    "enabled": false
  }
}
EOF

# create network file
sudo tee ~/restake/src/network.json <<EOF
 {
    "name": "planq"
    "ownerAddress":"plqvaloperxxxxxxxxx"
 }
EOF

echo '================================================='
echo '                     \e[1m\e[1;95mDONE                        \e[0m'
echo "\e[1m\e[31mSilahkan lanjutkan ke step fork & pull github...\e[0m"
echo '================================================='
