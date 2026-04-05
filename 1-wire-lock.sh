#!/bin/bash

IFS=' ' read -r -a ALLOWED_KEYS <<< ${ALLOWED_KEY_LIST:-""}

KNXD_ADDRESS=${KNXD_ADDRESS:-"ip:localhost"}
KNX_UNLOCK_ADDRESS=${KNX_UNLOCK_ADDRESS:-""}

OW_ADDRESS=${OW_ADDRESS:-"localhost:4304"}
OW_BUS_ADDRESS=${OW_BUS_ADDRESS-""}
OW_BUS_FILTER=${OW_BUS_FILTER-""}
SLEEP_AFTER=7

# validation
if [ ! -n "$ALLOWED_KEY_LIST" ]; then
    echo "Allowed key list is empty, please set ALLOWED_KEY_LIST environment variable with space separated list of allowed keys"
    exit 1
elif [ -z "$KNX_LOCK_ADDRESS" ]; then
    echo "KNX lock address is not set, please set KNX_LOCK_ADDRESS environment variable"
    exit 1
elif [ -z "$OW_BUS_ADDRESS" ]; then
    echo "OW bus address is not set, please set OW_BUS_ADDRESS (e.g. /uncached/bus.1) environment variable"
    exit 1
else
   echo "Start watching following keys: ${ALLOWED_KEYS[*]}"
fi


start=$(date +%s%3N)
diff=0

while true; do
  end=$(date +%s%3N)
  diff=$(( ($end-$start) / 1000 ))
  if [ $diff -eq 0 ]; then
    sleep 1
  fi

  if [ $diff -ge 3 ]; then
    now=$(date)
    echo "${now} diff ${diff} is higher then expected!!"
  fi

  start=$(date +%s%3N)

  # echo "check keys after ${diff}"
  out=$(owdir -s ${OW_ADDRESS} ${OW_BUS_ADDRESS} | grep "${OW_BUS_FILTER}")

  for k in $out; do
    key=$(basename "$k")
    echo "Found key ${key}, checking"
    if [[ " ${ALLOWED_KEYS[*]} " =~ [[:space:]]${key}[[:space:]] ]]; then
      echo "Key ${key} granted access, opening door and sleep for ${SLEEP_AFTER} seconds"
      knxtool groupswrite ${KNXD_ADDRESS} "${KNX_UNLOCK_ADDRESS}" 1
      sleep ${SLEEP_AFTER}
    else
      echo "Access denied for key ${key}!"
    fi
  done

done