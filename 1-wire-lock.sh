#!/bin/bash

IFS=' ' read -r -a ALLOWED_KEYS <<< ${ALLOWED_KEY_LIST:-""}

KNXD_ADDRESS=${KNXD_ADDRESS:-"ip:localhost"}
KNX_LOCK_ADDRESS=${KNX_LOCK_ADDRESS:-""}

OW_HTTP_ADDRESS=${OW_HTTP_ADDRESS:-"http://localhost:2121"}
OW_BUS_ADDRESS=${OW_BUS_ADDRESS-""}
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
  DEVICE_OUTPUT=$(curl -s --retry 3 --retry-connrefused "${OW_HTTP_ADDRESS}${OW_BUS_ADDRESS}/")

  # Parse HTML output and extract 1-Wire device keys
  # Extract all device IDs from HTML href links (format: XX.XXXXXXXXXXXX)
  FOUND_KEYS=$(echo "$DEVICE_OUTPUT" | grep -o '[A-F0-9]\{2\}\.[A-F0-9]\{12\}' | sort -u)

  for key in $FOUND_KEYS; do
    echo "Found key ${key}, checking"
    if [[ " ${ALLOWED_KEYS[*]} " =~ [[:space:]]${key}[[:space:]] ]]; then
      echo "Key ${key} granted access, opening door and sleep for ${SLEEP_AFTER} seconds"
      # knxtool groupswrite ${KNXD_ADDRESS} "${KNX_LOCK_ADDRESS}" 1
      sleep ${SLEEP_AFTER}
    else
      echo "Access denied for key ${key}!"
    fi
  done

done