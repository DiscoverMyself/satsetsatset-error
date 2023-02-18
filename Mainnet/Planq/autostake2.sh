#!/bin/bash

RED="\033[31m"
YELLOW="\033[33m"
GREEN="\033[32m"
NORMAL="\033[0m"

function setup {
  keyname "${1}"
  sleepTime "${2}"
}

function keyname {
  KEY_NAME=${1}
}

function sleepTime {
  STIME=${1:-"3m"}
}

function launch {
setup "${1}" "${2}"
echo "-------------------------------------------------------------------"
echo -e "$YELLOW Enter PASSWORD for your KEY $NORMAL"
echo "-------------------------------------------------------------------"
read -s PASS

RPC_ADDRESS=$(planqd status | jq -r .NodeInfo.other.rpc_address)
COIN=$(planqd query staking params --node ${RPC_ADDRESS} -o j | jq -r '.bond_denom')
BASE_DENOM=$(planqd query staking params --node ${RPC_ADDRESS} -o j | jq -r '.bond_denom' | sed -e 's/^.\{1\}//')
ADDRESS=$(echo $PASS | planqd keys show ${KEY_NAME} --output json | jq -r '.address')
VALOPER=$(echo $PASS | planqd keys show ${KEY_NAME} -a --bech val)
CHAIN=$(planqd status --node ${RPC_ADDRESS} 2>&1 | jq -r .NodeInfo.network)
ONE_PLANQ=1000000000000000000

echo "-------------------------------------------------------------------"
echo -e "$YELLOW Check you Validator and Chain data: $NORMAL"
echo -e "$GREEN Address: $ADDRESS $NORMAL"
echo -e "$GREEN Valoper: $VALOPER $NORMAL"
echo -e "$GREEN Chain: $CHAIN $NORMAL"
echo -e "$GREEN Coin: $COIN $NORMAL"
echo -e "$GREEN Key Name: $KEY_NAME $NORMAL"
echo -e "$GREEN Sleep Time: $STIME $NORMAL"
echo "-------------------------------------------------------------------"
echo -e "$YELLOW If your Data is right type$RED yes$NORMAL.$NORMAL"
echo -e "$YELLOW If your Data is wrong type$RED no$NORMAL$YELLOW and check it.$NORMAL $NORMAL"
read -p "Your answer: " ANSWER

if [ "$ANSWER" == "yes" ]; then
    while true
    do
    echo "-------------------------------------------------------------------"
    echo -e "$RED$(date +%F-%H-%M-%S)$NORMAL $YELLOW Withdraw commission and rewards $NORMAL"
    echo "-------------------------------------------------------------------"
    echo $PASS | planqd tx distribution withdraw-rewards ${VALOPER} --commission --gas="1000000" --gas-adjustment="1.15" --gas-prices="30000000000${COIN}" --chain-id=${CHAIN} --from ${KEY_NAME} --node ${RPC_ADDRESS} -y | grep "raw_log\|txhash"
    sleep 20s
    echo $PASS | planqd tx distribution withdraw-all-rewards --gas="1000000" --gas-adjustment="1.15" --gas-prices="30000000000${COIN}" --chain-id=${CHAIN} --from ${KEY_NAME} --node ${RPC_ADDRESS} -y | grep "raw_log\|txhash"
    sleep 20s

    AMOUNT=$(planqd query bank balances ${ADDRESS} --chain-id=${CHAIN} --node ${RPC_ADDRESS} --output json | jq -r '.balances[] | select(.denom=="'${COIN}'") | .amount')
    echo "-------------------------------------------------------------------"
    echo -e "$RED$(date +%F-%H-%M-%S)$NORMAL $YELLOW Balance = ${AMOUNT} ${COIN} $NORMAL"
    DELEGATE=$(bc <<< "$AMOUNT - $ONE_PLANQ" )

    if [[ $DELEGATE > 0 && $DELEGATE != "null" ]]; then
        echo "-------------------------------------------------------------------"
        echo -e "$RED$(date +%F-%H-%M-%S)$NORMAL $YELLOW To Stake = ${DELEGATE} ${COIN} $NORMAL"
        echo "-------------------------------------------------------------------"
        echo $PASS | planqd tx staking delegate ${VALOPER} ${DELEGATE}${COIN} --gas="1000000" --gas-adjustment="1.15" --gas-prices="30000000000aplanq" --chain-id=${CHAIN} --from ${KEY_NAME} --node ${RPC_ADDRESS} -y | grep "raw_log\|txhash"
        sleep 20s
        echo "-------------------------------------------------------------------"
        echo -e "$GREEN Balance after delegation:$NORMAL"
        BAL=$(planqd query bank balances ${ADDRESS} --chain-id=${CHAIN} --node ${RPC_ADDRESS} --output json | jq -r '.balances[] | select(.denom=="'${COIN}'") | .amount')
        echo -e "$YELLOW ${BAL} ${COIN} $NORMAL"
        MSG=$(echo -e "planqd | $(date +%F-%H-%M-%S) | Delegated: ${DELEGATE} ${COIN} | Balance after delegation: ${BAL} ${COIN}")
    else
        MSG=$(echo -e "planqd | $(date +%F-%H-%M-%S) | Insufficient balance for delegation")
        echo "-------------------------------------------------------------------"
        echo -e "$RED Insufficient balance for delegation $NORMAL"
        echo "-------------------------------------------------------------------"
    fi
        echo "-------------------------------------------------------------------"
        echo -e "$GREEN Sleep for ${STIME} $NORMAL"
        echo "-------------------------------------------------------------------"
        sleep ${STIME}
    done
elif [ "$ANSWER" == "no" ]; then
    echo -e "$RED Exited...$NORMAL"
    exit 0
else
    echo -e "$RED Answer wrong. Exited...$NORMAL"
    exit 0
fi
}

while getopts ":k:s:" o; do
  case "${o}" in
    k)
      k=${OPTARG}
      ;;
    s)
      s=${OPTARG}
      ;;
  esac
done
shift $((OPTIND-1))

launch "${k}" "${s}"
