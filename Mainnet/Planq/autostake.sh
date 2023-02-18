#!/bin/bash

GREEN_COLOR="\033[0;32m"
RED_COLOR="\033[0;31m"
WITHOUT_COLOR="\033[0m"

echo -n Password:
read -s password
echo

KEY_NAME=$(echo $password | planqd keys list --output json| jq -r ".[] .name")
DELEGATOR_ADDRESS=$(echo $password | planqd keys show ${KEY_NAME} --output json | jq -r '.address')
VALIDATOR_ADDRESS=$(echo $password | planqd keys show ${KEY_NAME} -a --bech val)
ONE_PLANQ="1000000000000000000"
DELAY=180 #in secs - how often restart the script
NODE=$(planqd status | jq -r .NodeInfo.other.rpc_address)

for (( ;; )); do
        echo -e "Get reward from Delegation"
        echo -e "${password}\ny\n" | planqd tx distribution withdraw-rewards ${VALIDATOR_ADDRESS} --commission --gas="1000000" --gas-adjustment="1.15" --gas-prices="30000000000aplanq" --chain-id planq_7070-2 --from ${KEY_NAME} --node ${NODE} --yes | grep "raw_log\|txhash"
for (( timer=10; timer>0; timer-- ))
        do
                printf "* sleep for ${RED_COLOR}%02d${WITHOUT_COLOR} sec\r" $timer
                sleep 1
        done
BALANCE=$(planqd query bank balances ${DELEGATOR_ADDRESS} --node ${NODE} -o json | jq -r '.balances | .[].amount')
echo -e "BALANCE: ${GREEN_COLOR}${BALANCE}${WITHOUT_COLOR} aplanq\n"
        echo -e "Claim rewards\n"
        echo -e "${password}\n${password}\n" | planqd tx distribution withdraw-all-rewards --gas="1000000" --gas-adjustment="1.15" --gas-prices="30000000000aplanq" --chain-id planq_7070-2 --from ${KEY_NAME} --node ${NODE} --yes | grep "raw_log\|txhash"
for (( timer=10; timer>0; timer-- ))
        do
                printf "* sleep for ${RED_COLOR}%02d${WITHOUT_COLOR} sec\r" $timer
                sleep 1
        done
BALANCE=$(planqd query bank balances ${DELEGATOR_ADDRESS} --node ${NODE} -o json | jq -r '.balances | .[].amount');
        TX_AMOUNT=$(bc <<< "$BALANCE - $ONE_PLANQ" )
echo -e "BALANCE: ${GREEN_COLOR}${BALANCE}${WITHOUT_COLOR} aplanq\n"
        echo -e "Stake ALL\n"
if awk "BEGIN {return_code=($BALANCE > $ONE_PLANQ) ? 0 : 1; exit} END {exit return_code}";then
            echo -e "${password}\n${password}\n" | planqd tx staking delegate ${VALIDATOR_ADDRESS} ${TX_AMOUNT}aplanq --gas="1000000" --gas-prices="30000000000aplanq" --gas-adjustment="1.15" --chain-id=planq_7070-2 --from ${KEY_NAME} --node ${NODE}  --yes | grep "raw_log\|txhash"
        else
                                echo -e "BALANCE: ${GREEN_COLOR}${BALANCE}${WITHOUT_COLOR} aplanq is lower than $ONE_PLANQ aplanq\n"
        fi
for (( timer=${DELAY}; timer>0; timer-- ))
        do
            printf "* sleep for ${RED_COLOR}%02d${WITHOUT_COLOR} sec\r" $timer
            sleep 1
        done
done
