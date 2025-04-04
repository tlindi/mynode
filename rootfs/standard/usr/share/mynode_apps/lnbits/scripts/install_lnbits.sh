#!/bin/bash

source /usr/share/mynode/mynode_device_info.sh
source /usr/share/mynode/mynode_app_versions.sh

set -x
set -e

echo "==================== INSTALLING APP ===================="

# The current directory is the app install folder and the app tarball from GitHub
# has already been downloaded and extracted. Any additional env variables specified
# in the JSON file are also present.

# TODO: Perform installation steps here

    # Upgrade LNbits
    if should_install_app "lnbits" ; then
        CURRENT=""
        if [ -f $LNBITS_VERSION_FILE ]; then
            CURRENT=$(cat $LNBITS_VERSION_FILE)
        fi
        if [ "$CURRENT" != "$LNBITS_VERSION" ]; then
            docker rmi $(docker images --format '{{.Repository}}:{{.Tag}}' | grep 'lnbits') || true

            mkdir /opt/mynode/lnbits
			
            docker pull lnbits/lnbits:$LNBITS_VERSION
            docker tag lnbits/lnbits:$LNBITS_VERSION lnbits

            echo $LNBITS_VERSION > $LNBITS_VERSION_FILE
        fi
    fi

    # handle /first_install if needed
	#
	# Step 1: Retrieve super_user ID and remove quotes
    export SUPER_USER_ID=$(sudo sqlite3 /mnt/hdd/mynode/lnbits/database.sqlite3 \
        "SELECT value FROM system_settings WHERE id='super_user';" | sed 's/\"//g')

    # Step 2: Check if first_install is done for the specific super_user ID
    export FIRST_INSTALL_STATUS=$(sudo sqlite3 /mnt/hdd/mynode/lnbits/database.sqlite3 \
        "SELECT COUNT(*) FROM accounts WHERE id = '$SUPER_USER_ID' \
        AND username IS NOT NULL;")

    if [[ $FIRST_INSTALL_STATUS -eq 0 ]]; then
        echo "FIRST_INSTALL not done"

        # Step 3: Make the first_install API call
        curl -v -X PUT https://127.0.0.1:5001/api/v1/auth/first_install \
            -H "Content-Type: application/json" \
            -d '{
                "username": "admin",
                "password": "securebolt",
                "password_repeat": "securebolt"
            }' \
            -k

        # Step 4: Update accounts table with correct username and password_hash
        sudo sqlite3 /mnt/hdd/mynode/lnbits/database.sqlite3 \
            "UPDATE accounts SET username = 'admin', \
            password_hash = '\$2b\$12\$GWNtn8GarOLpc5XKMcqFMuY05vIIKWkLtbPSjvqho0P2CLaiNCHHm' \
            WHERE id = '$SUPER_USER_ID';"
    else
        echo "FIRST_INSTALL done. Get admin details from Settings page."
    fi


echo "================== DONE INSTALLING APP ================="
