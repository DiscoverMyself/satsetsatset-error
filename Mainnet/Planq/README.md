<div classname="logo">

<p align="center">
  <img height="300" height="auto" src="https://user-images.githubusercontent.com/78480857/208048940-257c3d9c-3dae-4f6d-ad0d-bba3f4ceb541.png">
</div>


# PLANQ MAINNET

- [Website](https://planq.network/)

- [Explorer](https://explorer.planq.network/)

- [Discord](https://discord.gg/zmjTn49k)

- [Reddit](https://www.reddit.com/r/planq_network)

- [Whitepaper](https://planq.network/whitepaper)

- [Twitter](https://twitter.com/PlanqFoundation)

## Hardware requirements
- OS : Ubuntu Linux 20.04 (LTS) x64

- Read Access Memory : 8 GB (higher better)

- CPU : 4 core (higher better)

- Disk: 250 GB SSD Storage (higher better)

- Bandwidth: 1 Gbps for Download / 100 Mbps for Upload


## Automatic Instalation:
```
wget -O planq.sh https://raw.githubusercontent.com/DiscoverMyself/Planq-Mainnet/main/planq.sh && chmod +x planq.sh && ./planq.sh
```

## Manual Instalation
Planq [Official Docs](https://docs.planq.network/)

or

```
cd ~/planq
git fetch --all && git checkout v1.0.2
make install 
planqd version
```

```
cat <<'EOF' >>$HOME/.profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
```
```
source $HOME/.profile
git clone https://github.com/planq-network/planq.git
cd planq
make install
```
```
planqd config chain-id planq_7070-2
planqd init "testnode" --chain-id planq_7070-2
wget https://raw.githubusercontent.com/planq-network/networks/main/mainnet/genesis.json
mv genesis.json ~/.planqd/config/
planqd validate-genesis
```

**start the node (prefer on the screen)**
```
planqd start
```


## Update v1.0.2

**Check `planqd start` PID**
```
ps auxfwww | grep planqd
```

**Kill those PID**
```
kill -9 <PID_number>
```

**Update Binaries**
```
cd planq
git fetch --all && git checkout v1.0.2
make install 
planqd version
```

**Start the Node (prefer run on the screen)**
```
planqd start
```

## State Sync
State Sync by lutasic
```
STATE_SYNC_RPC=https://planq-rpc.cagie.tech:443
STATE_SYNC_PEER=938f1720a3ec8a168553a9d5b3be5eee1d078108@planq-rpc.cagie.tech:14656
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 1000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  -e "s|^persistent_peers *=.*|persistent_peers = \"$STATE_SYNC_PEER\"|" \
  $HOME/.planqd/config/config.toml
sudo systemctl stop planqd
planqd tendermint unsafe-reset-all --home $HOME/.planqd && \
sudo systemctl restart planqd && journalctl -fu planqd -o cat
```

## Wallet Configuration
**Add new wallet**
```
planqd keys add $WALLET
```

**Recover wallet**
```
planqd keys add $WALLET --recover
```

**Wallet list**
```
planqd keys list
```

**Check Balance**
```
planqd query bank balances $(planqd keys show wallet -a)
```

**Delete Wallet**
```
planqd keys delete $WALLET
```


## Validator Configuration
**Create Validator**
```
planqd tx staking create-validator \
  --amount=1000000000000aplanq \
  --pubkey=$(planqd tendermint show-validator) \
  --moniker="$NODENAME" \
  --chain-id=$PLANQ_CHAIN_ID \
  --commission-rate="0.05" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1000000" \
  --gas="1000000" \
  --gas-prices="30000000000aplanq" \
  --gas-adjustment="1.15" \
  --from=$WALLET
```

**Check Validator address**

```
planqd keys show wallet --bech val -a
```

**Edit Validator**

```
planqd tx staking edit-validator \
  --website="YOUR_WEBSITE_LINK" \
  --identity=YOUR_KEYBASE_PGP \
  --details="YOUR_DETAILS" \
  --chain-id=$PLANQ_CHAIN_ID \
  --gas="1000000" \
  --gas-prices="30000000000aplanq" \
  --gas-adjustment="1.15" \
  --from=$WALLET \
  --commission-rate="0.10"
```
 
**Delegate to Validator**
```
planqd tx staking delegate $(planqd keys show wallet --bech val -a) 1000000000000000000aplanq --from $WALLET --chain-id $PLANQ_CHAIN_ID --gas 1000000 --gas-prices 30000000000aplanq --gas-adjustment 1.15
```

**Unjail Validator**
```
planqd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$PLANQ_CHAIN_ID \
  --gas="1000000" \
  --gas-prices="30000000000aplanq" \
  --gas-adjustment="1.15" 
```

**Re-stake your commision and reward automatically, using script (Auto Compound)**

1. Get the script:
```
cd
wget https://raw.githubusercontent.com/DiscoverMyself/Planq-Mainnet/main/autostake.sh
```

2. Allow access:
```
chmod +x autostake.sh
```
3. Run the script
```
screen -R autostake
```
```
./autostake.sh
```
  
**Useful Commands**
1. Synchronization info

`
planqd status 2>&1 | jq .SyncInfo
`

2. Validator Info

`
planqd status 2>&1 | jq .ValidatorInfo
`

3. Node Info

`
planqd status 2>&1 | jq .NodeInfo
`

4. Show Node ID

`
planqd tendermint show-node-id
`

5. Delete Node

```
systemctl stop planqd
systemctl disable planqd
rm -rvf .planqd
rm -rvf planq.sh
rm -rvf planq
```

**Port Connection**
```
lsof -i tcp:<port>
```

you can kill the process with
```
kill -9 <PID>
```
