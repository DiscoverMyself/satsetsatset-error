# CHEATSHEET

```
BINARY=
CHAIN=
PORT=
NODENAME=
FOLDER=
PORT=
```


## A. Init Config
### 1. Init Chain
```
sudo $BINARY config chain-id $CHAIN
```
### 2. Init Keyring File
```
sudo $BINARY config keyring-backend file
```
### 3. Init RPC
```
sudo $BINARY config node tcp://localhost:${PORT}657
```
### 4. Init Nodename & Genesis file
```
sudo $BINARY init $NODENAME --chain-id $CHAIN
```
### 5. Validate Genesis
```
sudo $BINARY validate-genesis
```


## B. Wallet Configuration
### 1. Add New Wallet
```
sudo $BINARY keys add <wallet_name>
```
### 2. Recover Wallet
```
sudo $BINARY keys add <wallet_name> --recover
```
### 3. Import a Metamask private Key
```
$BINARY keys unsafe-import-eth-key <wallet_name>-imported <metamask_private-key>
```
### 4. Export to be a Private Key File
```
$BINARY keys unsafe-export-eth-key <wallet_name> > <wallet_name>-eth.export
```
### 5. Check List of Wallet
```
sudo $BINARY keys list
```
### 6. Delete Wallet
```
sudo $BINARY keys delete <wallet_name>
```
### 7. Check Wallet Balances
```
sudo $BINARY query bank balances $($BINARY keys show <wallet_name> -a)
```
### 8. Check Wallet Address
```
sudo $BINARY keys show <wallet_name> -a
```
### 9. Transfer Funds
```
$BINARY tx bank send <YOUR_WALLET_ADDRESS_OR_WALLET_NAME> <TO_ADDRESS> <AMOUNT>$DENOM --gas=auto --fees=<AMOUNT&DENOM> --chain-id $CHAIN --from <wallet_name>
```


## C. Validator Configuration
### 1. Check Validator Address
```
sudo $BINARY keys show <wallet_name> --bech val -a
```
### 2. Create Validator
```
sudo $BINARY tx staking create-validator \
  --amount= \ # amount & denom
  --pubkey=$($BINARY tendermint show-validator) \
  --moniker=$NODENAME \
  --chain-id=$CHAIN \
  --commission-rate= \ # 1% = 0.01 || 10% = 0.1 || 100% = 1
  --commission-max-rate= \ # 1% = 0.01 || 10% = 0.1 || 100% = 1
  --commission-max-change-rate= \ # 1% = 0.01 || 10% = 0.1 || 100% = 1
  --min-self-delegation= \ # just number
  --gas=auto \
  --fees= \ # amount & denom
  --from=<wallet_name>
```
### 3. Edit Validator
```
sudo $BINARY tx staking edit-validator \
  --website="YOUR_WEBSITE_LINK" \
  --identity=YOUR_KEYBASE_PGP \
  --details="YOUR_DETAILS" \
  --chain-id=$CHAIN \
  --gas=auto \
  --fees= \ # amount & denom
  --gas-adjustment= \ # 1% = 0.01 || 10% = 0.1 || 100% = 1
  --from=<wallet_name> \
  --commission-rate= \ # 1% = 0.01 || 10% = 0.1 || 100% = 1
  -y
```
### 4. Unjail Jailed Validator
```
  sudo $BINARY tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$CHAIN \
  --gas=auto \
  --fees= \ # amount & denom
  --from=<wallet_name>
```
### 5. Check Validator Status
```
$BINARY query tendermint-validator-set | grep "$($BINARY tendermint show-address)"
```
### 6. Check Validator Rewards
```
$BINARY query distribution rewards $($BINARY keys show <wallet_name> -a) $($BINARY keys show <wallet_name> --bech val -a)
```
### 7. Check Commission Rewards
```
$BINARY query distribution commission $($BINARY keys show <wallet_name> --bech val -a)
```
### 8. Withdraw Delegator Reward
```
$BINARY tx distribution withdraw-all-rewards --from <wallet_name> --chain-id $CHAIN --fees <amount&denom> --gas auto -y
```
### 9. Withdraw Commission Reward
```
$BINARY tx distribution withdraw-rewards $($BINARY keys show <wallet_name> --bech val -a) --commission --from <wallet_name> --chain-id $CHAIN --fees <amount&denom> --gas auto -y
```



## D. Info
### 1. Synchronize Information
```
sudo $BINARY status 2>&1 | jq .SyncInfo
```
**OR**
```
curl -s localhost:${PORT}657/status | jq .result.sync_info
```
### 2. Node Information
```
sudo $BINARY status 2>&1 | jq .NodeInfo
```
### 3. Show Node ID
```
sudo $BINARY tendermint show-node-id
```
### 4. Show Node Logs
```
journalctl -fu $BINARY -o cat
```
### 5. Get list of Connected Peers
```
curl -sS http://localhost:$PORT/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```
### 6. Get List of Validators
```
$BINARY query staking validators --limit 100 -o json | jq -r '.validators[] | [.operator_address, .status, (.tokens|tonumber / pow(10; 6)), .description.moniker] | @csv' | column -t -s"," | sort -k3 -n -r | nl
```
### 7. Check Peers ID & Port
```
echo $($BINARY tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/$FOLDER/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```

## E. Vote Governance
```
$BINARY tx gov vote 1 <yes/no> --from <wallet_name> --chain-id $CHAIN
```
