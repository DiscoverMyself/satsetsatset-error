#!/bin/bash
clear
echo ""
echo "Wait ..."
sleep 3
clear
       
echo -e "\033[0;35m"
echo "    :::     :::::::::  :::::::::      :::     ::::    ::::  :::::::::: "; 
echo "  :+: :+:   :+:    :+: :+:    :+:   :+: :+:   +:+:+: :+:+:+ :+:        ";
echo " +:+   +:+  +:+    +:+ +:+    +:+  +:+   +:+  +:+ +:+:+ +:+ +:+        ";
echo "+#++:++#++: +#++:++#+  +#++:++#:  +#++:++#++: +#+  +:+  +#+ +#++:++#   ";
echo "+#+     +#+ +#+        +#+    +#+ +#+     +#+ +#+       +#+ +#+        ";
echo "#+#     #+# #+#        #+#    #+# #+#     #+# #+#       #+# #+#        ";
echo "###     ### ###        ###    ### ###     ### ###       ### ########## ";
echo -e "\e[0m"
                                                                     
sleep 2


# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
PLANQ_PORT=26
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export PLANQ_CHAIN_ID=planq_7070-2" >> $HOME/.bash_profile
echo "export PLANQ_PORT=26" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$PLANQ_CHAIN_ID\e[0m"
echo -e "Your custom Port: \e[1m\e[32m$PLANQ_PORT\e[0m"
echo '================================================='

sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.19.4"
  cd $HOME
  wget "https://go.dev/dl/go1.19.4.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.4.linux-amd64.tar.gz
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

cat <<'EOF' >>$HOME/.profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download and build binaries
cd $HOME && rm -rf planq
rm -rf .planqd
rm -rf planq.sh
wget https://go.dev/dl/go1.19.4.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.4.linux-amd64.tar.gz

cat <<'EOF' >>$HOME/.profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF

source $HOME/.profile
git clone https://github.com/planq-network/planq.git
cd planq
make install
planqd config chain-id planq_7070-2
planqd init "testnode" --chain-id planq_7070-2
wget -O ${HOME}/.planqd/config/addrbook.json https://raw.githubusercontent.com/planq-network/networks/main/mainnet/addrbook.json
wget -O ${HOME}/.planqd/config/genesis.json https://raw.githubusercontent.com/planq-network/networks/main/mainnet/genesis.json
planqd validate-genesis

# peers
PEERS=$(curl -sL https://raw.githubusercontent.com/planq-network/networks/main/mainnet/peers.txt | sort -R | head -n 10 | awk '{print $1}' | paste -s -d, -)
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.planqd/config/config.toml

# pruning and indexer
sed -i -e "s%^indexer *=.*%indexer = \"null\"%; " $HOME/.planqd/config/config.toml
sed -i -e "s%^pruning *=.*%pruning = \"custom\"%; " $HOME/.planqd/config/app.toml
sed -i -e "s%^pruning-keep-recent *=.*%pruning-keep-recent = \"100\"%; " $HOME/.planqd/config/app.toml
sed -i -e "s%^pruning-interval *=.*%pruning-interval = \"10\"%; " $HOME/.planqd/config/app.toml

# set peers, gas prices and seeds
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025aplanq\"/;" ~/.planqd/config/app.toml
seeds=`curl -sL https://raw.githubusercontent.com/planq-network/networks/main/mainnet/seeds.txt | awk '{print $1}' | paste -s -d, -`
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" ~/.planqd/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $HOME/.planqd/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $HOME/.planqd/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PLANQ_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PLANQ_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PLANQ_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PLANQ_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PLANQ_PORT}660\"%" $HOME/.planqd/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PLANQ_PORT}317\"%; s%^address = \":8080\"%address = \":${PLANQ_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PLANQ_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PLANQ_PORT}091\"%" $HOME/.planqd/config/app.toml


echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1

# Create Service
sudo tee /etc/systemd/system/planqd.service > /dev/null <<EOF
[Unit]
Description=planq
After=network-online.target
[Service]
User=$USER
ExecStart=$(which planqd) start --home $HOME/.planqd
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable planqd
sudo systemctl restart planqd


echo '=============== SETUP COMPLETED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u planqd -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mplanqd status 2>&1 | jq .SyncInfo\e[0m"
sleep 5

