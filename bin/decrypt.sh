#!/usr/bin/env bash

# --- Passphrase Setup ---
# We ask for the passphrase once and store it in a variable (GPG_PASS)
# -s hides the typing for security
echo -n "Enter GPG Passphrase: "
read -s GPG_PASS
echo "" 

# --- Decrypt Function ---
function decrypt {
    local target_file="$1"
    local encrypted_file="$1.gpg"

    if [ ! -f "$encrypted_file" ]; then
        echo "Skipping: $encrypted_file not found."
        return
    fi

    # --passphrase-fd 0 tells GPG to read the password from the pipe (stdin)
    echo "$GPG_PASS" | gpg --batch --yes --pinentry-mode loopback --passphrase-fd 0 --decrypt --output "$target_file" "$encrypted_file" 2>/dev/null

    if [ "$?" -eq "0" ]; then
        echo "Successfully decrypted: $target_file"
    else
        echo "Error: Failed to decrypt $target_file. Check your passphrase."
        exit 1
    fi
}

# --- Execution ---

# 1. Decrypt the specific tfvars file
decrypt "india.tfvars"

# 2. Decrypt terraform state files
# Using a cleaner bash loop that avoids 'ls' and 'sed'
for f in terraform.tfstate*.gpg; do
    [ -e "$f" ] || continue  # Skip if no files match the pattern
    decrypt "${f%.gpg}"      # ${f%.gpg} strips the .gpg extension
done

# 3. Decrypt SSH keys
for f in ssh/oracle*.gpg; do
    [ -e "$f" ] || continue
    decrypt "${f%.gpg}"
done

# --- Cleanup ---
# Unset the variable so the password doesn't linger in memory
unset GPG_PASS
echo "All decryptions complete."
