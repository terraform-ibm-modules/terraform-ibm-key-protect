#!/bin/bash

set -e

echo "Starting Key Protect Dedicated Initialization..."

# ============================
# REQUIRED ENV VARIABLES
# ============================
# KP_INSTANCE_ID
# KP_TARGET_ADDR
# ADMIN_KEY_FILE
# ADMIN_PASS
# KEYSHARE_1
# KEYSHARE_2
# KEYSHARE_PASS_1
# KEYSHARE_PASS_2
# MASTER_KEY_NAME

# Validate inputs
: "${KP_INSTANCE_ID:?Need KP_INSTANCE_ID}"
: "${KP_TARGET_ADDR:?Need KP_TARGET_ADDR}"
: "${ADMIN_KEY_FILE:?Need ADMIN_KEY_FILE}"
: "${ADMIN_PASS:?Need ADMIN_PASS}"

export KP_INSTANCE_ID
export KP_TARGET_ADDR

echo "Target Instance: $KP_INSTANCE_ID"
echo "Endpoint: $KP_TARGET_ADDR"

# ============================
# WAIT FOR CRYPTO UNITS
# ============================
echo "Waiting for crypto units to be available..."
sleep 60

# ============================
# GENERATE ADMIN KEY (if not exists)
# ============================
if [ ! -f "$ADMIN_KEY_FILE" ]; then
  echo "Generating admin key..."
  ibmcloud kp crypto-unit sig-key generate \
    --file "$ADMIN_KEY_FILE" \
    --passphrase "$ADMIN_PASS" \
    --algo RSA-2048
else
  echo "Admin key already exists, skipping..."
fi

# ============================
# CLAIM CRYPTO UNITS
# ============================
echo "Claiming crypto units..."
ibmcloud kp crypto-unit claim \
  --credential "$ADMIN_KEY_FILE" || true

# ============================
# GENERATE MASTER KEY (if not exists)
# ============================
if [ ! -f "$KEYSHARE_1" ] || [ ! -f "$KEYSHARE_2" ]; then
  echo "Generating master key shares..."
  ibmcloud kp crypto-unit mk generate \
    --keyshare-files "[\"$KEYSHARE_1#$KEYSHARE_PASS_1\",\"$KEYSHARE_2#$KEYSHARE_PASS_2\"]" \
    --keyshare-minimum 2 \
    --algo AES-256 \
    --key-name "$MASTER_KEY_NAME" \
    --auth "[{\"ADMIN\":\"$ADMIN_KEY_FILE#$ADMIN_PASS\"}]"
else
  echo "Key shares already exist, skipping generation..."
fi

# ============================
# IMPORT MASTER KEY
# ============================
echo "Importing master key..."
ibmcloud kp crypto-unit mk import \
  --keyshare-files "[\"$KEYSHARE_1#$KEYSHARE_PASS_1\",\"$KEYSHARE_2#$KEYSHARE_PASS_2\"]" \
  --auth "[{\"ADMIN\":\"$ADMIN_KEY_FILE#$ADMIN_PASS\"}]" || true

# ============================
# ADD KMS CRYPTO USER
# ============================
echo "Adding kmsCryptoUser..."
ibmcloud kp crypto-unit user add \
  --type kmsCryptoUser \
  --auth "[{\"ADMIN\":\"$ADMIN_KEY_FILE#$ADMIN_PASS\"}]" || true

# ============================
# FINAL WAIT
# ============================
echo "Waiting for service to sync..."
sleep 300

echo "Checking crypto unit state..."
ibmcloud kp crypto-units

echo "Key Protect Dedicated initialization completed!"