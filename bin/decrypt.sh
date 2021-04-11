#!/usr/bin/env bash

function decrypt {
    gpg --decrypt --batch --yes --output "$1" "$1.gpg"
    if [ ! "$?" -eq "0" ]; then
        exit
    fi
}

decrypt "india.tfvars"

FILES=$(ls terraform.tfstate*gpg)
for f in $FILES; do
    decrypt $( echo $f | sed 's/\.gpg//' )
done

FILES=$(ls ssh/oracle*.gpg)
for f in $FILES; do
    decrypt $( echo $f | sed 's/\.gpg//' )
done
