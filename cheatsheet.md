# CHEATSHEET

```
BINARY=
CHAIN=
PORT=
NODENAME=
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
### 3. Check List of Wallet
```
sudo $BINARY keys list
```
### 4. Delete Wallet
```
sudo $BINARY keys delete <wallet_name>
```
### 5. Check Wallet Balances
```
sudo $BINARY query bank balances $($BINARY keys show <wallet_name> -a)
```
### 6. Check Wallet Address
```
sudo $BINARY keys show <wallet_name> -a
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
