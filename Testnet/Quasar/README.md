<div classname="logo">

<p align="center">
  <img height="200" height="auto" src="https://user-images.githubusercontent.com/78480857/219823945-e0ac948a-c21e-4a0f-8a58-d9664abfa6f5.png">
</div>
<br>
<br>



# Quasar testnet


- [Website](https://www.quasar.fi/)

- [Explorer/Portal](https://explorer.kjnodes.com/quasar-testnet)

- [Discord](https://discord.gg/quasarfi)

- [Medium](https://medium.com/@quasar.fi)

- [Twitter](https://twitter.com/QuasarFi)

- [Roadmap](#)

- [Litepaper](#)

## Hardware requirements
- OS : Ubuntu Linux 20.04 (LTS) x64

- Read Access Memory : 16 GB (Recommended)

- CPU : 4 core (higher better)

- Disk: 500 GB SSD Storage (higher better)

- Bandwidth: 1 Gbps for Download / 100 Mbps for Upload

# Installation
## Automatic Instalation:
```
wget -O quasar.sh https://raw.githubusercontent.com/DiscoverMyself/Exorde-Labs/resources/src/quasar.sh && chmod +x quasar.sh && ./quasar.sh
```

## Manual Instalation
Quasar [Official Docs](https://testnet.quasar.fi/)

# Configurations
## State Sync (by: Nodexcapital)
```
quasard tendermint unsafe-reset-all --home $HOME/.quasarnode --keep-addr-book

SNAP_RPC="https://rpc.quasar.nodexcapital.com:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.quasarnode/config/config.toml

sudo systemctl start quasard && sudo journalctl -fu quasard -o cat
```

## Wallet Configuration
**Add new wallet**
```
quasard keys add $WALLET
```

**Recover wallet**
```
quasard keys add $WALLET --recover
```

**Wallet list**
```
quasard keys list
```

**Check Balance**
```
quasard query bank balances $(quasard keys show wallet -a)
```

**Delete Wallet**
```
quasard keys delete $WALLET
```


## Validator Configuration
**Create Validator**
```
quasard tx staking create-validator \
    --amount=500000000000$DENOM \
    --pubkey=$(dymd tendermint show-validator) \
    --moniker="$NODENAME" \
    --chain-id=$CHAIN \
    --from=$WALLET \
    --commission-rate="0.10" \
    --commission-max-rate="0.20" \
    --commission-max-change-rate="0.01" \
    --min-self-delegation="1"
```

**Check Validator address**

```
quasard keys show wallet --bech val -a
```

**Edit Validator**

```
quasard tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$CHAIN \
  --from=$WALLET
```
 
**Delegate to Validator**
```
quasard tx staking delegate $(dymd tendermint show-validator) 1000000uqsr --from $WALLET --chain-id qsr-questnet-04 --fees 5000uqsr
```

**Unjail Validator**
```
quasard tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=qsr-questnet-04 \
  --gas=auto --gas-adjustment 1.4
```
  
**Useful Commands**
1. Synchronization info

`
quasard status 2>&1 | jq .SyncInfo
`

2. Validator Info

`
quasard status 2>&1 | jq .ValidatorInfo
`

3. Node Info

`
quasard status 2>&1 | jq .NodeInfo
`

4. Show Node ID

`
quasard tendermint show-node-id
`

5. Delete Node

```
systemctl stop quasard
systemctl disable quasard
rm -rvf .quasarnode
rm -rvf quasar.sh
rm -rvf quasar
rm -rf ${which quasard}
```



