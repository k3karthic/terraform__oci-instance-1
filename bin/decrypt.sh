#!/usr/bin/env bash

function decrypt {
    gpg --decrypt --batch --yes --output "$1" "$1.gpg"
    if [ ! "$?" -eq "0" ]; then
        exit
    fi
}

decrypt "india.tfvars"

FILES=$(ls terraform.tfstate* | grep -v \.gpg)
for f in $FILES; do
    decrypt $f
done

FILES=$(ls ssh/oracle* | grep -v \.gpg)
for f in $FILES; do
    decrypt $f
done
